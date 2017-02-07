use threads;
use threads::shared;

# $Id: tSubdomainBruteForce.pm 411 2011-12-05 05:33:13Z jabra $
package tSubdomainBruteForce;
{
    use Object::InsideOut qw(:SHARED AttackObj);
    use Fierce::Base;
    use Fierce::Domain;
    use Socket;
    use Thread::Queue;

    ### required parameters
    # none

    ### optional parameters
    # prefixes to use during bruteforce
    my @prefix_list : Field : Arg(prefix_list) : Get(prefix_list) :
        Type(Array) : Default(['www','test','mail']);

    # subdomains to use during bruteforce
    my @subdomain_list : Field : Arg(subdomain_list) : Get(subdomain_list) :
        Type(Array) : Default(['spy','blue','red']);

   # contiue to perform bruteforce if a wildcard is being used (Either 0 or 1)
    my @test_with_wildcard : Field : Arg(test_with_wildcard) :
        All(test_with_wildcard) : Default(0);

  # max number of interation to use for bruteforce attempts (Must be positive)
    my @max_bruteforce : Field : Arg(max_bruteforce) : Get(max_bruteforce) :
        Default(5);

    # Base Configuration infomation
    my @base : Field : Arg(base) : All(base) : Type(Base);

    ### populated parameters
    # list of nodes found
    my @result : Field : Arg(result) : All(result) : Type(List(Node)) :
        Default([]);

    # list of wildcard subdomain found
    my @wildcard_subdomains : Field : Arg(wildcard_subdomains) :
        All(wildcard_subdomains) : Type(List(Node)) : Default([]);

    # domain object used
    my @domain_obj : Field : Arg(domain_obj) : All(domain_obj) : Type(Domain);

    # initialize the base obj
    sub _init : Init {
        my ($self) = @_;

        # Set default if needed
        if ( !exists( $base[$$self] ) ) {
            $self->set( \@base, Base->new() );
        }
    }

    # execute: Domain -> tSubdomainBruteForce
    # perform subdomain dns bruteforce with prefix and subdomain lists
    # side effect: adds the list of found nodes to result
    sub execute {
        my ( $self, $domain_obj ) = @_;

        $self->_setup;
        $self->domain_obj($domain_obj);
        my $base = $self->base;

        ## find all subdomain wildcards
        my $stream = Thread::Queue->new();

        foreach my $subdomain ( @{ $self->subdomain_list } ) {
            $stream->enqueue("$subdomain");
        }
        foreach ( 1 .. $base->threads ) {
            threads->new( \&thr_work_wildcards, $self, $stream );
            $stream->enqueue(undef);    # for each thread
        }
        foreach my $thr ( threads->list() ) {
            $thr->join();
        }

        ## prepare list of subdomain to tests
        my @subdomain_list_exec;
        foreach my $subdomain ( @{ $self->subdomain_list } ) {
            if (scalar(
                    grep( $_->hostname =~ /$subdomain/,
                        @{ $self->wildcard_subdomains } )
                ) > 0
                )
            {
                if ( $self->test_with_wildcard == 1 ) {

                    #print "test with wildcard: $subdomain\n";
                    push( @subdomain_list_exec, $subdomain );
                }
                else {

                    #print "test without\n";
                }
            }
            else {
                push( @subdomain_list_exec, $subdomain );
            }
        }

        ## enumerate subdomains if needed
        if ( scalar(@subdomain_list_exec) > 0 ) {
            my $stream_enum = Thread::Queue->new();

            foreach my $subdomain (@subdomain_list_exec) {
                foreach my $prefix ( @{ $self->prefix_list } ) {
                    $subdomain =~ s/,//g;
                    $prefix    =~ s/,//g;
                    $stream_enum->enqueue("$prefix,$subdomain");
                }
            }

            foreach ( 1 .. $base->threads ) {
                threads->new( \&thr_work_enum, $self, $stream_enum );
                $stream_enum->enqueue(undef);    # for each thread
            }
            foreach my $thr ( threads->list() ) {
                $thr->join();
            }
        }

        $self->_complete;
        return $self;
    }

    # {{{ thr_work_wildcards: Thread::Queue: ->
    # enumerate all the subdomains with wildcards
    sub thr_work_wildcards {
        my ( $self, $q ) = @_;

        my $domain = $self->domain_obj->domain;
        my $base   = $base[$$self];
        my $i      = 2;
        my $max    = $self->max_bruteforce + 2;
        my $res    = $base->new_dns_resolver();

        #print( 'Thread = ', threads->tid(), "\n" );
        sleep( $base->delay() );

        while ( my $subdomain = $q->dequeue() ) {
            my $wildcard_dns
                = 1e11 - int( rand(1e10) ) . "." . $subdomain . '.' . $domain;
            print "Searching for $wildcard_dns.\n" if $base->verbose == 1;
            my $packet = $base->lookup_hostname( $res, "$wildcard_dns." );
            if ( defined $packet and defined $packet->address ) {

            	print "Found Node! (" . $packet->address . " / " . $packet->name . ") based on a search of: $wildcard_dns.\n";
                my $node = Node->new(
                    hostname => $packet->name,
                    ip       => $packet->address,
                    type     => $packet->type,
                    ttl      => $packet->ttl,
                    from     => 'Check Wildcard'
                );
                push( @{ $wildcard_subdomains[$$self] }, $node );
            }
        }

    }    # }}}

    # {{{ thr_work_enum: Thread::Queue: ->
    # enumerate all the subdomains with wildcards
    sub thr_work_enum {
        my ( $self, $q ) = @_;

        my $domain = $self->domain_obj->domain;
        my $base   = $base[$$self];
        my $i      = 2;
        my $max    = $self->max_bruteforce + 2;
        my $res    = $base->new_dns_resolver();

        #print( 'Thread = ', threads->tid(), "\n" );
        sleep( $base->delay() );
        while ( my $item = $q->dequeue() ) {
            my ( $prefix, $subdomain ) = split( ',', $item );
            my $packet = $base->lookup_hostname( $res,
                "$prefix.$subdomain.$domain." );
			print "Searching for $prefix.$subdomain.$domain.\n" if $base->verbose == 1;
            # checking to see if subdomain1 resolves
            if ( !defined $packet ) {
                $subdomain .= "1";
                $packet = $base->lookup_hostname( $res,
                    "$prefix.$subdomain.$domain." );
            }

            # checking to see if subdomain01 resolves
            if ( !defined $packet ) {
                $subdomain =~ s/1$//g;
                $subdomain .= "01";
                $packet = $base->lookup_hostname( $res,
                    "$prefix.$subdomain.$domain." );
            }

            if ( defined $packet
                and ( $base->validip( $packet->address ) == 1 ) )
            {
            	print "Found Node! (" . $packet->address . " / " . $packet->name . ") based on a search of: $prefix.$subdomain.$domain.\n";
                my $node = Node->new(
                    hostname => $packet->name,
                    ip       => $packet->address,
                    ttl      => $packet->ttl,
                    type     => $packet->type,
                    from     => 'DNS Subdomain BruteForce'
                );
                push( @{ $result[$$self] }, $node );

				## remove trailing 1 or 01 if they exist...
				$subdomain =~ s/1$|01$//g;
                
                while ( $i <= $max ) {
                    my $num = $i;

         # checking to see if subdomain"NUMBER" or subdomain"0NUMBER" resolves
                    $packet = $base->lookup_hostname( $res,
                        "$prefix.$subdomain$num.$domain." );

                    if ( !defined $packet ) {
                        $num    = "0$i";
                        $packet = $base->lookup_hostname( $res,
                            "$prefix.$subdomain$num.$domain." );
                    }

                    if ( defined $packet
                        and ( $base->validip( $packet->address ) == 1 ) )
                    {
                    	print "Found Node! (" . $packet->address . " / " . $packet->name . ") based on a search of: $prefix.$subdomain$num.$domain.\n";
                        $node = Node->new(
                            hostname => $packet->name,
                            ip       => $packet->address,
                            ttl      => $packet->ttl,
                            type     => $packet->type,
                            from     => 'DNS Subdomain BruteForce'

                        );
                        push( @{ $result[$$self] }, $node );
                        $max++;
                    }
                    $i++;
                }
            }
        }
    }    # }}}
}

1;

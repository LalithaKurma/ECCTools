use threads;
use threads::shared;

# $Id: tVhost.pm 418 2012-04-28 17:06:17Z jabra $
package tVhost;
{
    use Object::InsideOut qw(:SHARED AttackObj);
    use Fierce::Base;
    use Fierce::Domain;
    use WWW::Mechanize;
    use Socket;
    use Thread::Queue;
    ## required parameters
    # none

    ## optional parameters
    # max page number of interation
    my @max_pagenum : Field : Arg(max_pagenum) : Get(max_pagenum) :
        Default(2);

    # Base Configuration infomation
    my @base : Field : Arg(base) : All(base) : Type(Base);

    ### populated parameters
    # list of nodes found
    my @result : Field : Arg(result) : All(result) : Type(List(Node)) :
        Default([]);

    # internal storage of links
    my @_links : Field : Arg(links) : All(links) : Type(List) : Default([]);

    # domain object from execute
    my @domain_obj : Field : Arg(domain_obj) : All(domain_obj) : Type(Domain);

    # initialize the base obj
    sub _init : Init {
        my ($self) = @_;

        # Set default if needed
        if ( !exists( $base[$$self] ) ) {
            $self->set( \@base, Base->new() );
        }

        BEGIN {
            $SIG{__WARN__} = sub { };
            $SIG{__DIE__}  = sub { };
        }

    }

    # execute: Domain -> Fierce::Domain::tBruteForceDNS
    # kicks off the dns bruteforce worker threads
    sub execute {
        my ( $self, $domain_obj ) = @_;

        $self->_setup;
        $self->domain_obj($domain_obj);

        my $stream = Thread::Queue->new();

        for ( 1 .. $self->max_pagenum ) {
            $stream->enqueue($_);
        }

        my $base = $self->base;
        foreach ( 1 .. $base->threads ) {
            threads->new( \&thr_work, $self, $stream );
            $stream->enqueue(undef);    # for each thread
        }

        foreach my $thr ( threads->list() ) {
            $thr->join();
        }

        my $reflinks = $self->_clean();
        $self->_populate($reflinks);

        $self->_complete;
        return $self;
    }
    
    # _msn_hosts: determine if the link is a microsoft host {{{
    sub _msn_hosts {
        my ($self,$link) = @_;
        if ( $link =~ /microsoft|msnscache|windowsliveformobile|msn|newmsntoolbar|live\.com/
                    or $link =~ /\w+\.bingj?\.com/i
                    or $link =~ /clk\.atdmt\.com/i ) {
            return 1;
        }
        else {
            return 0;
        }
    } # }}}

    sub _clean {
        my ( $self, $ref ) = @_;

        my %hash;
        foreach ( @{ $_links[$$self] } ) {
            if ( ( !defined($domain) ) or ( $_ =~ /$domain/ ) ) {
                $hash{ lc($_) }++;
            }
        }

        my @out = keys(%hash);
        return \@out;
    }    #}}}

    # _populate add the links to the result list {{{
    sub _populate {
        my ( $self, $reflinks ) = @_;

        my $base   = $base[$$self];
        my $res = $base->new_dns_resolver();

        foreach my $h (@{$reflinks} ) {
        	print "Searching for $h.\n" if $base->verbose == 1;
            my $packet = $base->lookup_hostname( $res, "$h." );
	    if ( defined $packet and defined $packet->address ) {
            	print "Found Node! (" . $packet->address . " / " . $h . ") based on a search of: $h.\n";
                my $node = Node->new(
                    hostname => $h,
                    ip       => $packet->address,
                    type     => $packet->type,
                    ttl      => $packet->ttl,
                    from     => 'Virtual Host'
                );
                push( @{ $result[$$self] }, $node );
            }
        }
    }    # }}}

    # thr_work: Thread::Queue ->
    # perform dns bruteforce using prefix and url
    sub thr_work {
        my ( $self, $q ) = @_;
        my $domain = $self->domain_obj->domain;
        my $base   = $base[$$self];
        my $ip;
        my $res = $base->new_dns_resolver();
        my $packet = $base->lookup_hostname( $res, $domain );
        if ( defined $packet->address ) {
            $ip = $packet->address;
        }
        else {
            return;
        }

        #print( 'Thread = ', threads->tid(), "\n" );
        sleep( $base->delay() );

        while ( my $num = $q->dequeue() ) {
            my $i = 1;
            
            my @links;
            my %hash;

            my $mech = WWW::Mechanize->new();
            if ( $num == 1 ) {
                $url
                    = "http://search.msn.com/results.aspx?q=ip%3A$ip&first=$i";
            }
            elsif ( $num == 2 ) {
                $i = int( $num - 1 ) . 1;
                $url
                    = "http://search.msn.com/results.aspx?q=ip%3A$ip&first=$i&FORM=PERE";
            }
            elsif ( $num < 10 ) {
                my $j = int( $num - 1 );
                $i = $j . 1;
                $url
                    = "http://search.msn.com/results.aspx?q=ip%3A$ip&first=$i&FORM=PERE$j";
            }
            $mech->get( $url);
            
            foreach( @{ $mech->links() } ) {
                my $i = $_;
                my $link = lc($$_[0]);
                if ($link =~ /http|https/ and _msn_hosts($link) == 0  and $link =~ /$domain/) {
                    $link =~ s/http:\/\///g;
                    $link =~ s/https:\/\///g;
                    $link =~ s/\/.*//g;
                    $hash{ $link }++;
                }
            }

            @links = keys(%hash);
            
            push( @{ $_links[$$self] }, @links );

            # Let others run
            threads->yield();
        }
    }
}

1;

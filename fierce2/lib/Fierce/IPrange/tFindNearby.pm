# $Id: tFindNearby.pm 411 2011-12-05 05:33:13Z jabra $
package tFindNearby;
{
    use Object::InsideOut qw(:SHARED AttackObj);
    use Socket;
    use Fierce::IPrange;
    use Fierce::Domain;
    use Fierce::Base;
    use Thread::Queue;

    # find nearby for whole class c
    my @wide : Field : Arg(wide) : Get(wide) : Default(0);

    # The number of IPs above and below which you are looking for
    my @traverse : Field : Arg(traverse) : Get(traverse) : Default(10);

# The number of IPs above and below whatever IP you have found to look for nearby IPs.
    my @bottom_traverse : Field : Arg(bottom_traverse) : Get(bottom_traverse)
        : Default(0);

    # search pattern when looking for nearby
    my @pattern : Field : Arg(pattern) : Get(pattern) : Default(0);

    # search scalar
    my @search : Field : Arg(search) : Get(search) : Default('');

    # Base Configuration infomation
    my @base : Field : Arg(base) : All(base) : Type(Base);

    ### populated parameters
    # list of nodes found
    my @result : Field : Arg(result) : All(result) : Type(List(PTR)) :
        Default([]);

    # list of additional hosts found (possibly additional domains)
    my @additional_hosts : Field : Arg(additional_hosts) :
        All(additional_hosts) : Type(List(PTR)) : Default([]);

    # iprange object from execute
    my @iprange_obj : Field : Arg(iprange_obj) : All(iprange_obj) :
        Type(IPrange);

    # domain object to use for searching
    my @domain_obj : Field : Arg(domain_obj) : All(domain_obj) : Type(Domain);

    # initialize the base obj
    sub _init : Init {
        my ($self) = @_;

        # Set default base, if needed
        if ( !exists( $base[$$self] ) ) {
            $self->set( \@base, Base->new() );
        }

        # Set default domain_obj, if needed
        if ( !exists( $domain_obj[$$self] ) ) {
            $self->set( \@domain_obj, Domain->new( domain => '', ) );
        }
    }

    # handle all the threading for this module
    sub spawn_threads {
        my ( $self, $group ) = @_;
        my $i = 1;

        my $stream = Thread::Queue->new();
        my $base   = $self->base;
        foreach my $ip ( @{$group} ) {

            #print "ip is $ip\n";
            if ( $base->validip("$ip") == 1 ) {

                #print "queue $ip\n";
                $stream->enqueue("$ip");
            }
        }
        foreach ( 1 .. $base->threads ) {

            #print "execute $_\n";
            threads->new( \&thr_work, $self, $stream );
            $stream->enqueue(undef);    # for each thread
            $i++;
        }
        foreach my $thr ( threads->list() ) {
            $thr->join();
        }
    }

    # execute: Domain -> Fierce::IPrange::tFindNearby
    # main function to find nearby hostnames
    sub execute {
        my ( $self, $iprange_obj ) = @_;

        $self->_setup;
        $self->iprange_obj($iprange_obj);
        my $base   = $self->base;
        my $stream = Thread::Queue->new();
        my $top    = 0;
        foreach my $cidr ( $self->iprange_obj->included_cidrs() ) {
            chomp($cidr);
            my ( $lowest, $highest );
            if ( $self->wide == 1 ) {
                $lowest  = 0;
                $highest = 255;
            }
            elsif ( $self->bottom_traverse ) {
                $lowest = $iprange_obj->bottom_classc($cidr);
                $highest
                    = $lowest > 255 - $self->traverse
                    ? 255
                    : $lowest + $self->traverse;
            }
            else {
                $lowest  = $iprange_obj->bottom_classc($cidr);
                $highest = $iprange_obj->top_classc($cidr);
            }

            my ( $low, $high ) = ( $lowest, $lowest + $self->traverse );
            while ( $high < $highest ) {
                my @group = $iprange_obj->group( $cidr, $low, $high );
                $self->spawn_threads( \@group );
                sleep( $base->delay );
                $low += $self->traverse;

                # +1 is to avoid overlapping the same address twice
                $high
                    = ( $high + $self->traverse + 1 ) < $highest
                    ? ( $high + $self->traverse + 1 )
                    : $highest;
            }
        }
        $self->_complete;
        return $self;
    }

    # worker thread
    sub thr_work {
        my ( $self, $q ) = @_;
        my $domain  = $self->domain_obj->domain;
        my $search  = $self->search;
        my $pattern = $self->pattern;
        my $base    = $base[$$self];

        #print( 'Thread = ', threads->tid(), "\n" );
        sleep( $base->delay() );
        my $resbf = $base->new_dns_resolver();
        while ( my $ip = $q->dequeue() ) {
            chomp($ip);
            print "Searching for $ip...\n" if ($base->verbose == 1);
            my $packet = $resbf->search("$ip");
            foreach my $answer (
                grep( ( $_->type eq 'A' or $_->type eq 'PTR' ),
                    $packet->answer )
                )
            {
                my $name = $answer->ptrdname;
                if (   $domain eq ''
                    or $answer->ptrdname =~ /\.$domain$/
                    or ( $pattern == 1 and grep( /$name/, $search ) ) )
                {
                    if ($base->isinlist_hostname( $result[$$self],
                            $answer->name ) == 0
                        )
                    {
                    	print "Found Node! ($ip / " . $answer->ptrdname . ")\n";
                        my $ptr = PTR->new(
                            hostname => $answer->name,
                            ptrdname => $answer->ptrdname,
                            from     => 'Find Nearby IPs',
                            ip       => $ip,
                        );
                        push( @{ $result[$$self] }, $ptr );
                    }
                }
                else {
                    if ($base->isinlist_hostname( $additional_hosts[$$self],
                            $answer->name ) == 0
                        )
                    {
                        my $additional_ptr = PTR->new(
                            hostname => $answer->name,
                            ptrdname => $answer->ptrdname,
                            from     => 'Find Nearby IPs',
                            ip       => $ip,
                        );
                        push(
                            @{ $additional_hosts[$$self] },
                            $additional_ptr
                        );
                    }

                }
            }

            # Let others run
            threads->yield();
        }
    }
}

1;

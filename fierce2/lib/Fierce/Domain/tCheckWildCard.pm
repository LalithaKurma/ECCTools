use threads;
use threads::shared;

# $Id: tCheckWildCard.pm 411 2011-12-05 05:33:13Z jabra $
package tCheckWildCard;
{
    use Object::InsideOut qw(:SHARED AttackObj);
    use Fierce::Base;
    use Socket;
    use Thread::Queue;

    ### required parameters
    # none

    ### optional parameters
    # subdomins to test
    my @subdomain : Field : Arg(subdomain) : Get(subdomain);

    # Base configuration information
    my @base : Field : Arg(base) : Get(base) : Type(Base);

    ### populated parameters
    # list of nodes found
    my @result : Field : Arg(result) : All(result) : Type(List(Node)) :
        Default([]);

    # was there a wildcard? ( 1 or 0)
    my @check : Field : Arg(check) : All(check) : Default(0);

    # domain object from execute
    my @domain_obj : Field : Arg(domain_obj) : All(domain_obj) : Type(Domain);

    # initialize the base obj
    sub _init : Init {
        my ($self) = @_;

        # Set default if needed
        if ( !exists( $base[$$self] ) ) {
            $self->set( \@base, Base->new() );
        }
    }

    # execute: Domain -> tCheckWildCard
    # check for a domain prefix or subdomain wildcard
    # side effect: adds the list of found nodes to result
    sub execute {
        my ( $self, $domain_obj ) = @_;

        $self->_setup;
        $self->domain_obj($domain_obj);

        my $stream = Thread::Queue->new();

        $wildcard_dns = 1e11 - int( rand(1e10) );
        if ( defined $self->subdomain ) {
            $wildcard_dns .= "." . $self->subdomain;
        }

        $stream->enqueue($wildcard_dns);

        my $base = $self->base;
        foreach ( 1 .. $base->threads ) {
            threads->new( \&thr_work, $self, $stream );
            $stream->enqueue(undef);    # for each thread
        }
        foreach my $thr ( threads->list() ) {
            $thr->join();
        }
        $self->_complete;
        return $self;
    }

    sub thr_work {
        my ( $self, $q ) = @_;

        my $domain = $self->domain_obj->domain;
        my $base   = $base[$$self];

        #print( 'Thread = ', threads->tid(), "\n" );
        sleep( $base->delay() );

        while ( my $wildcard_dns = $q->dequeue() ) {
        	print "Searching for $wildcard_dns.\n" if $base->verbose == 1;
            my $packet = $base->lookup_hostname( $res, "$h" );
            if ( defined $packet->address ) {
            	print "Found Node! (" . $packet->address . " / " . $packet->name . ") based on a search of: $h.\n";
                my $node = Node->new(
                    hostname => $packet->name,
                    ip       => $packet->address,
                    type     => $packet->type,
                    ttl      => $packet->ttl,
                    from     => 'Check Wildcard'
                );

                push( @{ $result[$$self] }, $node );
                $self->check(1);
            }

            # Let others run
            threads->yield();
        }
    }
}

1;

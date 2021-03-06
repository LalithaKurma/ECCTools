use threads;
use threads::shared;

# $Id: CheckWildCard.pm 321 2010-01-03 05:55:34Z jabra $
package CheckWildCard;
{
    use Object::InsideOut qw(AttackObj);
    use Fierce::Base;
    use Socket;

    # Base Configuration infomation
    my @base : Field : Arg(base) : All(base) : Type(Base);

    my @result : Field : Arg(result) : All(result) : Type(List(Node));

    # optional subdomain to use for testing
    my @subdomain : Field : Arg(subdomain) : All(subdomain);

    # true | false bit
    my @check : Field : Arg(check) : All(check) : Default(0);

    # initialize the base obj
    sub _init : Init {
        my ($self) = @_;

        # Set default if needed
        if ( !exists( $base[$$self] ) ) {
            $self->set( \@base, Base->new() );
        }
    }

    # execute: Domain ->  CheckWildCard
    # check for WildCards and returns the data in an Array
    sub execute {
        my ( $self, $domain_obj ) = @_;
        $self->_setup();
        my $domain = $domain_obj->domain;
        my $base   = $self->base;
        my @data;
        $wildcard_dns = 1e11 - int( rand(1e10) );
        if ( defined $self->subdomain ) {
            $wildcard_dns .= "." . $self->subdomain;
        }
        my $res = $base->new_dns_resolver();
        my $packet = $base->lookup_hostname( $res, "$wildcard_dns.$domain" );
        if ( defined $packet ) {
            push(
                @data,
                Node->new(
                    hostname => $packet->name,
                    ip       => $packet->address,
                    type     => $packet->type,
                    ttl      => $packet->ttl,
                    from     => 'Check Wildcard'
                )
            );
            $self->check(1);
        }
        $self->result(@data);
        $self->_complete();

        return $self;
    }
}

1;

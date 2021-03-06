# $Id: Domain.pm 320 2010-01-02 22:57:53Z jabra $
package Domain;
{
    use Object::InsideOut ':SHARED';
    my @domain : Field : Arg(domain) : Get(domain);
    my @ip : Field : Arg(ip) : All(ip);
    my @ttl : Field : Arg(ttl) : All(ttl);
    my @type : Field : Arg(type) : All(type);

    # set_ip: -> Fierce:Domain
    # return a new Fierce::Domain with the ip set.
    sub set_ip {
        my ( $self, $ip ) = @_;
        $self->ip($ip);
        return $self;
    }

    # set_ttl: -> Fierce:Domain
    # return a new Fierce::Domain with the ttl set.
    sub set_ttl {
        my ( $self, $ttl ) = @_;
        $self->ttl($ttl);
        return $self;
    }

    # set_type: -> Fierce:Domain
    # return a new Fierce::Domain with the type set.
    sub set_type {
        my ( $self, $type ) = @_;
        $self->type($type);
        return $self;
    }
}
1;

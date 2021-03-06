# $Id: ZoneTransfer.pm 320 2010-01-02 22:57:53Z jabra $

package ZoneTransfer;
{
    use Object::InsideOut qw(AttackObj);
    use Net::DNS;
    use Fierce::Base;

    # was there a zonetransfer? ( 1 or 0)
    my @check : Field : Arg(check) : All(check) : Default(0);

    my @result : Field : Arg(result) : All(result) :
        Type(List(ZoneTransferResult));

    # execute: Domain Net::DNS::Resolver -> ZoneTransfer
    # perform zone transfer domain
    sub execute {
        my ( $self, $domain_obj, $base_obj ) = @_;

        $self->_setup();
        my $domain       = $domain_obj->domain;
        my $res          = $base_obj->new_dns_resolver();
        my $name_servers = $base_obj->name_servers;

        my ( @data, @nodes, @zone );

        if ( scalar(@$name_servers) == 0 ) {
            my $query = $res->query( $domain, 'NS' );
            if ($query) {
                foreach my $rr ( grep { $_->type eq 'NS' } $query->answer ) {
                    my $dnssrv = $rr->nsdname;
                    push( @$name_servers, $rr->nsdname );
                    $base_obj->add_nameserver( $rr->nsdname );
                }
            }
        }
        if ( scalar(@$name_servers) > 0 ) {
            for my $ns (@$name_servers) {
                @nodes = ();
                $res->nameservers($ns);
                @zone = $res->axfr($domain);
                my $bool       = 0;
                my $raw_output = '';
                if ( scalar(@zone) > 0 ) {
                    $bool = 1;
                    foreach my $rr (@zone) {
                        if ( defined( $rr->string ) ) {
                            $raw_output .= $rr->string . "\n";
                        }
                        next if ( $rr->type eq 'CNAME' );

                        my ( $type, $hostname, $ip, $ttl );
                        $type     = defined( $rr->type ) ? $rr->type : '';
                        $hostname = defined( $rr->name ) ? $rr->name : '';
                        $ip  = defined( $rr->address ) ? $rr->address : '';
                        $ttl = defined( $rr->ttl )     ? $rr->ttl     : '';
                        push(
                            @nodes,
                            Node->new(
                                type     => $type,
                                hostname => $hostname,
                                ip       => $ip,
                                ttl      => $ttl,
                                from     => "Zone Transfer",
                            )
                        );
                    }
                    $self->check(1);
                }

                # add results even if there is no transfer
                push(
                    @data,
                    ZoneTransferResult->new(
                        name_server => $ns,
                        domain      => $domain,
                        bool        => $bool,
                        raw_output  => $raw_output,
                        nodes       => \@nodes,
                    )
                );
            }
        }
        $self->result(@data);
        $self->_complete();

        return $self;
    }
}

1;

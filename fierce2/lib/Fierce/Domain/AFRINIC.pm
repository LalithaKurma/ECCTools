# $Id: AFRINIC.pm 333 2010-02-10 03:06:01Z jabra $
package AFRINIC;
{
    use Object::InsideOut qw(AttackObj);
    use Fierce::Base;
    use Net::Whois::ARIN;

    ## optional
    my @query : Field : Arg(query) : All(query) : Default("");

    ## populate data
    my @result : Field : Arg(result) : All(result) : Type(List(RangeResult));

    # execute: Domain -> RangeResult
    # query AFRINIC server
    sub execute {
        my ( $self, $domain_obj ) = @_;

        $self->_setup();
        my $w = Net::Whois::ARIN->new(
            host    => 'whois.afrinic.net',
            port    => 43,
            timeout => 30,
            retries => 3,
        );
        my ( $qstr, @data, @arin_result, $query );
        if ( $self->query eq "" ) {
            $qstr = $domain_obj->domain;
            $qstr =~ s/\..*//g;
        }
        else {
            $qstr = $self->query;
        }
        eval { @arin_result = $w->query($qstr); };
        if ( !$@ and scalar(@arin_result) > 0 ) {
            foreach my $net (@arin_result) {
                my ( $net_handle, $net_range );
                if ( $net =~ /(NET-\d{1,3}-\d{1,3}-\d{1,3}-\d{1,3}-\d{1,3})/ )
                {
                    $net_handle = defined $1 ? $1 : 'undefined';
                }
                if ( $net
                    =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3} - \d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
                    )
                {
                    $net_range = defined $1 ? $1 : 'undefined';

                }
                if ( $net_handle ne undef and $net_range ne undef ) {
                    push(
                        @data,
                        RangeResult->new(
                            net_range  => $net_range,
                            net_handle => $net_handle,
                        )
                    );
                }
            }
        }
        $self->result(@data);
        $self->_complete();
        return $self;
    }
}

1;

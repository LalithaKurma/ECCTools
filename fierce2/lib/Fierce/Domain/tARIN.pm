# $Id: tARIN.pm 397 2010-07-19 00:51:48Z jabra $
package tARIN;
{
    use Object::InsideOut qw(:SHARED AttackObj);
    use Fierce::Base;
    use Thread::Queue;
    use Net::Whois::ARIN;

    ## optional
    my @query : Field : Arg(query) : All(query) : Default("");

    # Base Configuration infomation
    my @base : Field : Arg(base) : All(base) : Type(Base);

    ## populate data
    my @result : Field : Arg(result) : All(result) : Type(List(RangeResult)) :
        Default([]);

    # net_handle lookups
    my @net_handle_result : Field : Arg(net_handle_result) :
        All(net_handle_result) : Type(List(NetHandleResult)) : Default([]);

    # initialize the base obj
    sub _init : Init {
        my ($self) = @_;

        # Set default if needed
        if ( !exists( $base[$$self] ) ) {
            $self->set( \@base, Base->new() );
        }
    }

    # work thread for looking up net_handles
    sub thr_work {
        my ( $self, $q ) = @_;
        my $base = $base[$$self];

        my $arin_obj = $base->new_arin_lookup();

        #print( 'Thread = ', threads->tid(), "\n" );
        while ( my $net_handle = $q->dequeue() ) {

            # store result of raw query
            my @net_handle_output;

            # store temp results into hash
            my $net_handle_hash;

            # return result object
            my $net_handle_object;

            eval { @net_handle_output = $arin_obj->query($net_handle); };
            if ( !$@ and scalar(@net_handle_output) > 0 ) {
                foreach (@net_handle_output) {
                    chomp;
                    s/\s+/ /g;

                    $net_handle_hash{cust_name} = $1 if (/CustName: (.*)/);
                    $net_handle_hash{address}   = $1 if (/Address: (.*)/);
                    $net_handle_hash{city}      = $1 if (/City: (.*)/);

                    $net_handle_hash{state_prov} = $1 if (/StateProv: (.*)/);
                    $net_handle_hash{zip_code}   = $1 if (/PostalCode: (.*)/);
                    $net_handle_hash{country}    = $1 if (/Country: (.*)/);

                    $net_handle_hash{cidr}       = $1 if (/CIDR: (.*)/);
                    $net_handle_hash{net_type}   = $1 if (/NetType: (.*)/);
                    $net_handle_hash{net_handle} = $1 if (/NetHandle: (.*)/);
                    $net_handle_hash{net_range}  = $1 if (/NetRange: (.*)/);

                    $net_handle_hash{comment} = $1 if (/Comment: (.*)/);

                    $net_handle_hash{reg_date} = $1 if (/RegDate: (.*)/);
                    $net_handle_hash{updated}  = $1 if (/Updated: (.*)/);

                    $net_handle_hash{rtech_handle} = $1
                        if (/RTechHandle: (.*)/);
                    $net_handle_hash{rtech_name} = $1 if (/RTechName: (.*)/);
                    $net_handle_hash{rtech_phone} = $1
                        if (/RTechPhone: (.*)/);
                    $net_handle_hash{rtech_email} = $1
                        if (/RTechEmail: (.*)/);

                    $net_handle_hash{org_abuse_handle} = $1
                        if (/OrgAbuseHandle: (.*)/);
                    $net_handle_hash{org_abuse_name} = $1
                        if (/OrgAbuseName: (.*)/);
                    $net_handle_hash{org_abuse_phone} = $1
                        if (/OrgAbusePhone: (.*)/);
                    $net_handle_hash{org_abuse_email} = $1
                        if (/OrgAbuseEmail: (.*)/);

                    $net_handle_hash{org_noc_handle} = $1
                        if (/OrgNOCHandle: (.*)/);
                    $net_handle_hash{org_noc_name} = $1
                        if (/OrgNOCName: (.*)/);
                    $net_handle_hash{org_noc_phone} = $1
                        if (/OrgNOCPhone: (.*)/);
                    $net_handle_hash{org_noc_email} = $1
                        if (/OrgNOCEmail: (.*)/);

                    $net_handle_hash{org_tech_handle} = $1
                        if (/OrgTechHandle: (.*)/);
                    $net_handle_hash{org_tech_name} = $1
                        if (/OrgTechName: (.*)/);
                    $net_handle_hash{org_tech_phone} = $1
                        if (/OrgTechPhone: (.*)/);
                    $net_handle_hash{org_tech_email} = $1
                        if (/OrgTechEmail: (.*)/);
                }

                $net_handle_object = NetHandleResult->new(
                    net_range        => $net_handle_hash{net_range},
                    net_handle       => $net_handle_hash{net_handle},
                    cust_name        => $net_handle_hash{cust_name},
                    address          => $net_handle_hash{address},
                    city             => $net_handle_hash{city},
                    state_prov       => $net_handle_hash{state_prov},
                    zip_code         => $net_handle_hash{zip_code},
                    country          => $net_handle_hash{country},
                    cidr             => $net_handle_hash{cidr},
                    net_type         => $net_handle_hash{net_type},
                    comment          => $net_handle_hash{comment},
                    reg_date         => $net_handle_hash{reg_date},
                    updated          => $net_handle_hash{updated},
                    rtech_handle     => $net_handle_hash{rtech_handle},
                    rtech_name       => $net_handle_hash{rtech_name},
                    rtech_phone      => $net_handle_hash{rtech_phone},
                    rtech_email      => $net_handle_hash{rtech_email},
                    org_abuse_handle => $net_handle_hash{org_abuse_handle},
                    org_abuse_name   => $net_handle_hash{org_abuse_name},
                    org_abuse_phone  => $net_handle_hash{org_abuse_phone},
                    org_abuse_email  => $net_handle_hash{org_abuse_email},
                    org_tech_handle  => $net_handle_hash{org_tech_handle},
                    org_tech_name    => $net_handle_hash{org_tech_name},
                    org_tech_phone   => $net_handle_hash{org_tech_phone},
                    org_tech_email   => $net_handle_hash{org_tech_email},
                    org_noc_handle   => $net_handle_hash{org_noc_handle},
                    org_noc_name     => $net_handle_hash{org_noc_name},
                    org_noc_phone    => $net_handle_hash{org_noc_phone},
                    org_noc_email    => $net_handle_hash{org_noc_email},
                );

                push( @{ $net_handle_result[$$self] }, $net_handle_object );

            }
            else {

                #my $net_handle_object = NetHandleResult->new();

            }

            # Let others run
            threads->yield();
        }
    }

    # execute: Domain -> ARIN
    # perform zone transfer domain
    sub execute {
        my ( $self, $domain_obj ) = @_;

        $self->_setup();
        my $stream = Thread::Queue->new();

        my $w = Net::Whois::ARIN->new(
            host    => 'whois.arin.net',
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
                if ( defined($net_handle) and defined($net_range) ) {
                    next if ( $net_handle eq 'undefined' );
                    next if ( $net_range  eq 'undefined' );

                    $stream->enqueue($net_handle);
                    push(
                        @data,
                        RangeResult->new(
                            net_range  => $net_range,
                            net_handle => $net_handle,
                        )
                    );
                }
            }
            my $base = $self->base;
            foreach ( 1 .. $base->threads ) {
                threads->new( \&thr_work, $self, $stream );
                $stream->enqueue(undef);    # for each thread
            }
            foreach my $thr ( threads->list() ) {
                $thr->join();
            }
        }
        $self->result(@data);
        $self->_complete();
        return $self;
    }
}

1;

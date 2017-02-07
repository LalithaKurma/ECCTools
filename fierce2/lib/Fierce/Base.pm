# $Id: Base.pm 421 2012-04-28 18:22:42Z jabra $
package Fierce::Base;
use warnings;

use Carp;

=head1 NAME

Fierce::Base - base modules for building a network recon security tool
=cut

package Base;
{
    use Object::InsideOut ':SHARED';
    use Net::DNS;
    use Net::Whois::ARIN;
    use Net::CIDR ':all';

    my @name_servers : Field : Arg(name_servers) : All(name_servers) :
      Type(Array);
    my @log_file : Field : Arg(log_file) : Get(log_file);
    my @proto : Field : Arg(proto) : Get(proto) : Default('udp');
    my @threads : Field : Arg(threads) : Get(threads) : Default(5);
    my @delay : Field : Arg(delay) : Get(delay) : Default(3);
    my @port : Field : Arg(port) : Get(port) : Default(53);
    my @tcp_timeout : Field : Arg(tcp_timeout) : Get(tcp_timeout) : Default(10);
    my @udp_timeout : Field : Arg(udp_timeout) : Get(udp_timeout) : Default(5);
    my @verbose : Field : Arg(verbose) : Get(verbose) : Default(0);
    my @debug : Field : Arg(debug) : Get(debug) : Default(0);

    # new_arin_lookup: -> Net::Whois::ARIN
    # return a new whois arin lookup object
    sub new_arin_lookup {
        my ($self) = @_;
        my $arin_obj = Net::Whois::ARIN->new(
            host    => 'whois.arin.net',
            port    => 43,
            timeout => 30,
            retries => 3,
        );
        return $arin_obj;
    }

    # new_apnic_lookup: -> Net::Whois::ARIN
    # return a new whois apnic lookup object
    sub new_apnic_lookup {
        my ($self) = @_;
        my $arin_obj = Net::Whois::ARIN->new(
            host    => 'whois.apnic.net',
            port    => 43,
            timeout => 30,
            retries => 3,
        );
        return $arin_obj;
    }

    # new_afrinic_lookup: -> Net::Whois::ARIN
    # return a new whois afrinic lookup object
    sub new_afrinic_lookup {
        my ($self) = @_;
        my $arin_obj = Net::Whois::ARIN->new(
            host    => 'whois.afrinic.net',
            port    => 43,
            timeout => 30,
            retries => 3,
        );
        return $arin_obj;
    }

    # new_dns_resolver: -> Net::DNS::Resolver
    # return a new DNS resolver
    sub new_dns_resolver {
        my ($self) = @_;
        my $res = Net::DNS::Resolver->new;
        if ( $self->proto eq 'tcp' ) {
            $res->usevc( $self->proto );
        }
        $res->port( $self->port );
        $res->udp_timeout( $self->udp_timeout );
        $res->tcp_timeout( $self->tcp_timeout );

        if ( $self->name_servers and scalar( @{ $self->name_servers } ) > 0 ) {
            $res->nameservers( @{ $self->name_servers } );
        }

        return $res;
    }

    # add_nameservers: -> Net::DNS::Resolver
    # add a NS to the list
    sub add_nameserver {
        my ( $self, $ns ) = @_;

        my @a = @{ $self->name_servers };
        push( @a, $ns );
        $self->name_servers( \@a );
    }

    # validip: str -> bool (1 or 0)
    # determine if the invalid str is a valid public or private ip
    sub validip {
        my ( $self, $ip ) = @_;
        my $a = Net::CIDR::cidrvalidate($ip);
        if ( defined($a) ) {
            return 1;
        }
        else {
            return 0;
        }
    }

    # isinlist: List(Nodes) IP -> bool(1 or 0)
    # determine if the ip is in the List(Nodes)
    sub isinlist {
        my ( $self, $ary, $scalar ) = @_;
        my @a = grep( $_->ip eq $scalar, @{$ary} );
        if ( scalar(@a) > 0 ) {
            return 1;
        }
        else {
            return 0;
        }
    }

    # isinlist_hostname: List(Node) Hostname -> bool(1 or 0)
    # determine if the hostname is in the List(Nodes)
    sub isinlist_hostname {
        my ( $self, $ary, $scalar ) = @_;
        my @a = grep( $_->hostname eq $scalar, @{$ary} );
        if ( scalar(@a) > 0 ) {
            return 1;
        }
        else {
            return 0;
        }
    }

    # isinlist_domain: List(Domain) domain -> bool(1 or 0)
    # determine if the domain is in the List(Nodes)
    sub isinlist_domain {
        my ( $self, $ary, $scalar ) = @_;
        my @a = grep( $_->domain eq $scalar, @{$ary} );
        if ( scalar(@a) > 0 ) {
            return 1;
        }
        else {
            return 0;
        }
    }

    ## lookup_hostname: Net::DNS::Resolver Hostname -> ip or undef
    ## return the ip address of the hostname
    sub lookup_hostname {
        my ( $self, $res, $hostname ) = @_;
        my $query = $res->search("$hostname");
        my $ip;
        if ($query) {
            foreach my $rr ( $query->answer ) {

                #next unless defined $type and $rr->type eq $type;
                $ip = $rr->address;
                if ( defined($ip) and $self->validip($ip) == 1 ) {
                    return $rr;
                }
            }
        }
        return undef;
    }
}

package AttackObj;
{
    use Object::InsideOut;

    # times for the attack
    my @start : Field : Arg(start) : All(start);
    my @startstr : Field : Arg(startstr) : All(startstr);
    my @end : Field : Arg(end) : All(end);
    my @endstr : Field : Arg(endstr) : All(endstr);
    my @elapsed : Field : Arg(elapsed) : All(elapsed);

    # set the scan start times
    sub _setup {
        my ($self)   = @_;
        my $start    = time();
        my $startstr = localtime($start);
        $self->start($start);
        $self->startstr($startstr);
    }

    # set scan end times
    sub _complete {
        my ($self) = @_;
        my $end    = time();
        my $endstr = localtime($end);
        $self->end($end);
        $self->endstr($endstr);
        my $elapsed = $end - $self->start;
        $self->elapsed($elapsed);
    }
}

package Node;
{
    use Object::InsideOut ':SHARED';
    my @ip : Field : Arg(ip) : Get(ip) : Default('');
    my @hostname : Field : Arg(hostname) : Get(hostname) : Default('');
    my @type : Field : Arg(type) : Get(type) : Default('');
    my @ttl : Field : Arg(ttl) : Get(ttl) : Default('');
    my @from : Field : Arg(from) : Get(from) : Default('');
}

package PTR;
{
    use Object::InsideOut ':SHARED';
    my @ptrdname : Field : Arg(ptrdname) : Get(ptrdname);
    my @hostname : Field : Arg(hostname) : Get(hostname);
    my @from : Field : Arg(from) : Get(from);
    my @ip : Field : Arg(ip) : Get(ip);
}

package ZoneTransferResult;
{
    use Object::InsideOut ':SHARED';
    my @name_server : Field : Arg(name_server) : Get(name_server);
    my @domain : Field : Arg(domain) : Get(domain);
    my @bool : Field : Arg(bool) : Get(bool);
    my @raw_output : Field : Arg(raw_output) : Get(raw_output);
    my @nodes : Field : Arg(nodes) : Get(nodes);
}

package FindMXResult;
{
    use Object::InsideOut ':SHARED';
    my @preference : Field : Arg(preference) : Get(preference);
    my @exchange : Field : Arg(exchange) : Get(exchange);
}

package RangeResult;
{
    use Object::InsideOut ':SHARED';
    my @net_range : Field : Arg(net_range) : Get(net_range);
    my @net_handle : Field : Arg(net_handle) : Get(net_handle);
}

package NetHandleResult;
{
    use Object::InsideOut ':SHARED';
    my @net_handle : Field : Arg(net_handle) : Get(net_handle);
    my @net_range : Field : Arg(net_range) : Get(net_range);
    my @org_id : Field : Arg(org_id) : Get(org_id);

    my @cust_name : Field : Arg(cust_name) : Get(cust_name);
    my @address : Field : Arg(address) : Get(address);
    my @city : Field : Arg(city) : Get(city);
    my @state_prov : Field : Arg(state_prov) : Get(state_prov);
    my @zip_code : Field : Arg(zip_code) : Get(zip_code);
    my @country : Field : Arg(country) : Get(country);
    my @reg_data : Field : Arg(reg_date) : Get(reg_date);
    my @updated : Field : Arg(updated) : Get(updated);

    my @cidr : Field : Arg(cidr) : Get(cidr);
    my @net_name : Field : Arg(net_name) : Get(net_name);
    my @parent : Field : Arg(parent) : Get(parent);
    my @net_type : Field : Arg(net_type) : Get(net_type);
    my @comment : Field : Arg(comment) : Get(comment);

    my @rtech_handle : Field : Arg(rtech_handle) : Get(rtech_handle);
    my @rtech_name : Field : Arg(rtech_name) : Get(rtech_name);
    my @rtech_phone : Field : Arg(rtech_phone) : Get(rtech_phone);
    my @rtech_email : Field : Arg(rtech_email) : Get(rtech_email);

    my @org_abuse_handle : Field : Arg(org_abuse_handle) :
      Get(org_abuse_handle);
    my @org_abuse_name : Field : Arg(org_abuse_name) : Get(org_abuse_name);
    my @org_abuse_phone : Field : Arg(org_abuse_phone) : Get(org_abuse_phone);
    my @org_abuse_email : Field : Arg(org_abuse_email) : Get(org_abuse_email);

    my @org_noc_handle : Field : Arg(org_noc_handle) : Get(org_noc_handle);
    my @org_noc_name : Field : Arg(org_noc_name) : Get(org_noc_name);
    my @org_noc_phone : Field : Arg(org_noc_phone) : Get(org_noc_phone);
    my @org_noc_email : Field : Arg(org_noc_email) : Get(org_noc_email);

    my @org_tech_handle : Field : Arg(org_tech_handle) : Get(org_tech_handle);
    my @org_tech_name : Field : Arg(org_tech_name) : Get(org_tech_name);
    my @org_tech_phone : Field : Arg(org_tech_phone) : Get(org_tech_phone);
    my @org_tech_email : Field : Arg(org_tech_email) : Get(org_tech_email);
}

1;

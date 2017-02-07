#!/usr/bin/env perl
package t::Test;
use Fierce::Base;
use Fierce::Domain;
use Fierce::IPrange;
use Fierce::Domain::tBruteForceDNS;
use Fierce::Domain::ZoneTransfer;
use Fierce::Domain::tCheckWildCard;
use Fierce::Domain::tHostnameLookups;
use Fierce::Domain::tFindMX;
use Fierce::Domain::WhoisLookup;
use Fierce::Domain::tTLDBruteForce;
#use Fierce::Iprange::PingScan;
#use Fierce::IPrange::AliveHosts;
use base 'Test::Class';
use Test::More;

sub setup : Tests(setup => no_plan) {
    my ($self) = @_;

    $self->{base1}  = Base->new(    'name_servers'  => [],
                                    'log_file'      => 'FILE',
                                    'threads'       => 5,
                                    'delay'         => 10,
                            );

    $self->{domain1}  = Domain->new(  'domain'  => "google.com",
                            );
    $self->{domain2}  = Domain->new(  'domain'  => "aol.com",
                            );
 
    $self->{domain3}  = Domain->new(  'domain'  => "www.l.google.com.",
                            );

    $self->{domain4}  = Domain->new(  'domain'  => "ebay.com",
                                     );

    $self->{iprange1}  = IPrange->new(  'iprange'  => ["192.168.1.0/24"],
                            );
    $self->{iprange2}  = IPrange->new(  'iprange'  => ["10.0.0.0/24"],
                            );
    $self->{iprange3}  = IPrange->new(  'iprange'   => ["64.233.187.99"],
                            );
    $self->{iprange4}  = IPrange->new(  'iprange'  => ["10.0.0.1", "10.0.0.100", "10.0.0.101", "10.0.0.102"],
                            );
    my @array;
    foreach(1..50) { 
        push(@array,"192.168.1.$_\n");
    }
    foreach(1..50) { 
        push(@array,"10.0.1.$_\n");
    }

    $self->{iprange5}  = IPrange->new(  'iprange'  => \@array );
    $self->{iprange6}  = IPrange->new(  'iprange'  => ["10.0.0.50/32"] );
    $self->{iprange7}  = IPrange->new(  'iprange'  => ["10.0.0.10-20"] );
    $self->{iprange8}  = IPrange->new(  'iprange'  => ["10.0.0.30-50"] );
    $self->{iprange9}  = IPrange->new(  'iprange'  => ["10.0.0.30-10.0.0.50"] );
    $self->{iprange10}  = IPrange->new(  'iprange'  => ["10.0.0.0/24","192.168.1.0/24"] );

    $self->{bf1} = tBruteForceDNS->new(  'prefix_list' => [ 'imap','www', 'mail', 'files', 'file', 'ftp', 'dns',
                'smtp', 'ns', 'mx', 'dev', 'devel', 'svn', 'cvs', 'test', 'vpn',
                    'unix', 'webmail'],
                                        'max_bruteforce' => 5,
                                    );
    
     $self->{zt1} = ZoneTransfer->new(  );
     
     $self->{check_wildcard} = tCheckWildCard->new(  );
     $self->{hostname_lookups} = tHostnameLookups->new(  );
     $self->{find_mx} = tFindMX->new(  );
     $self->{whois_lookup} = WhoisLookup->new(  );
     
     #$self->{alive_hosts} = AliveHosts->new( 'ports' => ["21","22","23","25","80","8080"], 
     #                           'timeout' => '.60',
     #                                  );

    $self->{tld_bf} = tTLDBruteForce->new(  'extension_list' => [ 'com', 'edu','net', 'org', 'co.uk', 'au', 'de', 'xxx','info','tv',
        'biz','cc','cn','name','pro','us','la'],
                                    );
}
1;

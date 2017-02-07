#!/usr/bin/perl -w
use strict;
use Config;

BEGIN {
    if ( !$Config{useithreads} || $] < 5.008 ) {
        print("1..0 # Skip Threads not supported\n");
        exit(0);
    }
}
use Data::Dumper;
use threads;
use threads::shared;
use Thread::Queue;

my $thread_support = 1;
use Fierce::Base;
use Fierce::Domain::tFindMX;
use Fierce::Domain;
my $dns;
my $log_file;
my $threads     = 5;
my $tcp_timeout = 5;
my $udp_timeout = 5;
my @name_servers;
my $delay          = 5;
my $max_bruteforce = 5;

if ( defined( $ARGV[0] ) ) {
    $dns = $ARGV[0];
}
else {
    print "Usage: $0 [domain]\n";
    exit;
}

my $domain = Domain->new( domain => $dns, );

my $base = Base->new(
    'name_servers' => \@name_servers,
    'log_file'     => $log_file,
    'threads'      => $threads,
    'delay'        => $delay,
    'tcp_timeout'  => $tcp_timeout,
    'udp_timeout'  => $udp_timeout,
);
print "base threads is " . $base->threads . "\n";

my $findmx = tFindMX->new();
$findmx = $findmx->execute( $domain, $base->new_dns_resolver );
foreach ( @${ $findmx->result } ) {
    print "ip is " . $_->preference() . "\n";
    print "ip is " . $_->exchage() . "\n";

}

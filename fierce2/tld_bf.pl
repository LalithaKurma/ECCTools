#!/usr/bin/perl -w
use strict;
use Config;

BEGIN {
    if ( !$Config{useithreads} || $] < 5.008 ) {
        print("1..0 # Skip Threads not supported\n");
        exit(0);
    }
}
use threads;
use threads::shared;
use Thread::Queue;

my $thread_support = 1;
use Fierce::Base;
use Fierce::Domain::tTLDBruteForce;
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
my @extension_list = (
    'com', 'org', 'net', 'name',  'biz', 'xxx',
    'gov', 'de',  'tv',  'co.uk', 'jp'
);

my $base = Base->new(
    'name_servers' => \@name_servers,
    'log_file'     => $log_file,
    'threads'      => $threads,
    'delay'        => $delay,
    'tcp_timeout'  => $tcp_timeout,
    'udp_timeout'  => $udp_timeout,
);
my $tldbf
    = tTLDBruteForce->new( 'extension_list' => \@extension_list, );
$tldbf = $tldbf->execute($domain);
foreach my $node ( @{ $tldbf->result() } ) {
    print "hostname is " . $node->hostname . "\n";
    print "ip is " . $node->ip . "\n";
}

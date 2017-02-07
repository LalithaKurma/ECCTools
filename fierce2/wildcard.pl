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
print "thread_suport is $thread_support\n";
use Fierce::Base;
use Fierce::Domain::tCheckWildCard;
use Fierce::Domain;
my $dns;
my $log_file;
my $threads     = 3;
my $tcp_timeout = 5;
my $udp_timeout = 5;
my @name_servers;
my $delay          = 1;
my $max_bruteforce = 5;

if ( defined( $ARGV[0] ) ) {
    $dns = $ARGV[0];
}
else {
    print "Usage: $0 [domain]\n";
    exit;
}

my $domain = Domain->new( domain => $dns, );
my @prefix_list
    = ( 'www', 'mail', 'ftp', 'svn', 'foo', 'bar', 'ns', 'svn', 'test' );
my @subdomain_list = ( 'spy', 'red', 'blue', 'ccs', 'ece' );

my $base = Base->new(
    'name_servers' => \@name_servers,
    'log_file'     => $log_file,
    'threads'      => $threads,
    'delay'        => $delay,
    'tcp_timeout'  => $tcp_timeout,
    'udp_timeout'  => $udp_timeout,
);
print "base threads is " . $base->threads . "\n";

my $wildc = tCheckWildCard->new( 'subdomain' => 'spy', 'base' => $base, );
$wildc = $wildc->execute($domain);
print Dumper $wildc->result;
foreach my $node ( @{ $wildc->result() } ) {
    print "hostname is " . $node->hostname . "\n";
    print "ip is " . $node->ip . "\n";
}

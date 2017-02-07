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
use Fierce::Domain::tBruteForceDNS;
use Fierce::Domain;
my $dns;
my $log_file;
my $threads     = 2;
my $tcp_timeout = 5;
my $udp_timeout = 5;
my @name_servers;
my $delay          = 5;
my $max_bruteforce = 5;

if ( defined( $ARGV[0] ) ) {
    $dns = $ARGV[0];
}
else {
    print "Usage: $0 [domain] (wordlist)\n";
    exit;
}

my $domain = Domain->new( domain => $dns, );
my @prefix_list;
if ( defined( $ARGV[1] ) ) {
    open( IN, $ARGV[1] ) or die "nope\n";
    while (<IN>) { chomp; push( @prefix_list, $_ ); }
}
else {
    @prefix_list
        = ( 'svn', 'cvs', 'test', 'vpn', 'unix', 'webmail', 'ipv6', );
}

my $base = Base->new(
    'name_servers' => \@name_servers,
    'log_file'     => $log_file,
    'threads'      => $threads,
    'delay'        => $delay,
    'tcp_timeout'  => $tcp_timeout,
    'udp_timeout'  => $udp_timeout,
);
my $bf = tBruteForceDNS->new( prefix_list => \@prefix_list );
$bf = $bf->execute($domain);

foreach my $node ( @{ $bf->result() } ) {
    print $node->hostname() . ',' . $node->ip() . "\n";
}

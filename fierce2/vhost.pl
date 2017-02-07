#!/usr/bin/perl -w
# $Id: vhost.pl 290 2009-11-15 22:03:48Z jabra $
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
use Fierce::Domain::tVhost;
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
my $vhost = tVhost->new();
$vhost = $vhost->execute($domain);

foreach my $node ( @{ $vhost->result() } ) {
    print "hostname is " . $node->hostname() . "\n";
    print "ip is " . $node->ip() . "\n";
    print "from is " . $node->from() . "\n";
}

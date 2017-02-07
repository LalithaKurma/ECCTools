#!/usr/bin/perl
# Test the loadability of our modules
use Test::More qw(no_plan);
my @modules = qw(Test::More Test::Class Test::MockObject Net::DNS Net::CIDR Net::Whois::ARIN Template threads threads::shared Thread::Queue WWW::Mechanize);
for my $m (@modules){
    use_ok($m);
}

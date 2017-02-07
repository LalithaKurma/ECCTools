#!/usr/bin/env perl

package t::Test::IPrange;

use base 't::Test';
use Test::More;
sub fields : Tests {
    my ($self) = @_;

    is( ${$self->{iprange1}->iprange}[0], '192.168.1.0/24', 'iprange1' );
    is( ${$self->{iprange2}->iprange}[0], '10.0.0.0/24', 'iprange2' );
    is( ${$self->{iprange3}->iprange}[0], '64.233.187.99', 'iprange3' );
    
    my @ranges = @{ $self->{iprange1}->iprange };
    is($ranges[0], '192.168.1.0/24', 'iprange1->iprange');
    @ranges = @{ $self->{iprange2}->iprange }; 
    is($ranges[0], '10.0.0.0/24', 'iprange2->iprange');
    @ranges = @{ $self->{iprange3}->iprange };
    is($ranges[0], '64.233.187.99','iprange3->iprange');
    
    # convert_cidrs
    my @a = $self->{iprange8}->convert_ranges();
    is ($a[0],'10.0.0.30-10.0.0.50','convert_ranges');

    # convert_cidrs
    my @b = $self->{iprange8}->convert_cidrs();
    is($b[0], '10.0.0.30/31','range 8 convert_cidrs()');
    is($b[1], '10.0.0.32/28','range 8 convert_cidrs()');
    is($b[2], '10.0.0.48/31','range 8 convert_cidrs()');
    is($b[3], '10.0.0.50/32','range 8 convert_cidrs()');
   
    @b = $self->{iprange1}->convert_cidrs();
    is($b[0], '192.168.1.0/24','range 1 convert_cidrs()');

    @b = $self->{iprange9}->convert_cidrs();
    is($b[0], '10.0.0.30/31','range 9 convert_cidrs()');
    is($b[1], '10.0.0.32/28','range 9 convert_cidrs()');
    is($b[2], '10.0.0.48/31','range 9 convert_cidrs()');
    is($b[3], '10.0.0.50/32','range 9 convert_cidrs()');

    my @d = $self->{iprange1}->convert_cidrs();
    is($d[0], '192.168.1.0/24', 'convert_cidrs: whole range');
    
    ## convert_octets
    @d = $self->{iprange9}->convert_octets();
    is($d[0], '10.0.0.30', 'convert_octets: first');
    is($d[20], '10.0.0.50', 'convert_octets: last');

    my @e = $self->{iprange1}->convert_octets();
    is($e[0], '192.168.1.1', 'convert_octets: whole range');
    
    @e = $self->{iprange10}->convert_octets();
    is($e[0], '10.0.0.1', 'convert_octets: whole range');
    is($e[254], '192.168.1.1', 'convert_octets: whole range');
    
    ## included_cidrs
    my @f = $self->{iprange5}->included_cidrs(); 
    is ($f[0], '192.168.1', 'included cidrs');
    is ($f[1], '10.0.1', 'included cidrs');
    
    ## top_classc
    my $top = $self->{iprange5}->top_classc('192.168.1');
    is ($top,'50','top class c');
    $top = $self->{iprange5}->top_classc('10.0.1');
    is ($top,'50','top class c');

    ## bottom_classc
    my $bottom= $self->{iprange5}->bottom_classc('192.168.1');
    is ($bottom,'1','bottom class c');
    $bottom = $self->{iprange5}->bottom_classc('10.0.1');
    is ($bottom,'1','bottom class c');

    #is ($b[0],'10.0.0.30-10.0.0.50','convert_cidrs');
    #print Dumper $self->{iprange8}->bottom_classc();
    #print Dumper $self->{iprange6}->top_classc();
}
1;

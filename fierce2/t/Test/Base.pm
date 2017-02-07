#!/usr/bin/env perl

package t::Test::Base;

use base 't::Test';
use Test::More;

sub fields : Tests {
    my ($self) = @_;

    is( ${$self->{base1}->name_servers}[0], undef, 'name_servers' );
    is( $self->{base1}->log_file, 'FILE', 'log_file' );
    is( $self->{base1}->threads, '5', 'threads' );
    is( $self->{base1}->delay, '10', 'delay' );
}
1;

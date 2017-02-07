#!/usr/bin/env perl

package t::Test::Domain;

use base 't::Test';
use Test::More;
use Data::Dumper;
sub fields : Tests {
    my ($self) = @_;

    is( $self->{domain1}->domain, 'google.com', 'domain1' );
    is( $self->{domain2}->domain, 'aol.com', 'domain2' );
    is( $self->{domain3}->domain, 'www.l.google.com.', 'domain3' );
    is( $self->{domain4}->domain, 'ebay.com', 'domain4') ;
}
1;

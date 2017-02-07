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
    
    #############################################################################
    my $bf = $self->{bf1}->execute($self->{domain1});

    #is ( $bf->start, "Trying Brute Force ...\n", "Google\t-\tBruteForce"); 
    is ( scalar(@{$bf->result}) > 2, 1,"Google\t-\tBruteForce output > 2");
    foreach my $n (@{$bf->result}){
        is(ref($n), 'Node');
    }
    $bf = $self->{bf1}->execute($self->{domain2});
    is ( scalar(@{$bf->result}) > 2, 1,"Aol\t-\tBruteForce output > 2");
    foreach my $n (@{$bf->result}){
        is(ref($n), 'Node');
    }
    #############################################################################
    
    #my $zt = $self->{zt1}->execute($self->{domain1},$self->{base1});
    
    #is ($output[0],"DNS Servers for google.com:\n", "Google\t-\tZoneTranfer trying Servers for Google");
    #is ($zt->$output[$index],"\nUnsuccessful in zone transfer (it was worth a shot)\n", "Google\t-\tZoneTranfer failed");

    my $wildcard = $self->{check_wildcard}->execute($self->{domain1});
    is ( scalar(@{$wildcard->result}) == 0, 1, "Google\t-\tCheckWildcard failed");
   
    $wildcard = $self->{check_wildcard}->execute($self->{domain2});
    is ( scalar(@{$wildcard->result}) == 0, 1, "Aol\t-\tCheckWildcard failed");
    
    #@output = $self->{reverse_lookup}->execute($self->{domain3});
    #is ( scalar(@output) > 2, 1,"Google\t-\tCheckWildcard output > 2");

    #@output = $self->{find_mx}->execute($self->{domain1});
    #is ( scalar(@output) > 2, 1,"Google\t-\tFindMX output > 2");
    
    #@output = $self->{whois_lookup}->execute($self->{domain1});
    #is ( scalar(@output) > 2, 1,"Google\t-\tWhois Lookup output > 2");

    #@output = $self->{tld_bf}->execute($self->{domain4});
    #is ( scalar(@output) > 2, 1,"Google\t-\tWhois Lookup output > 2");
}
1;

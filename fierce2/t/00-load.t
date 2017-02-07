#!perl -T

use Test::More tests => 10;
BEGIN {
    use_ok( 'Fierce::Base' );
    use_ok( 'Fierce::Domain');
    use_ok( 'Fierce::Domain::NameServers');
    use_ok( 'Fierce::Domain::ZoneTransfer');
    use_ok( 'Fierce::Domain::tBruteForceDNS');
    use_ok( 'Fierce::Domain::tCheckWildCard');
    use_ok( 'Fierce::Domain::tHostnameLookups');
    use_ok( 'Fierce::Domain::tFindMX');
    use_ok( 'Fierce::Domain::WhoisLookup');
    use_ok( 'Fierce::Domain::tTLDBruteForce');
}

use Test::More tests => 7;
use strict;

use_ok( 'MARC::Record' );

my $r = MARC::Record->new();

# alphabetic indicators are legal in some dialects of MARC

$r->append_fields( MARC::Field->new( 245, 'z', 'Z', a => 'foo' ) );
is( $r->field(245)->indicator(1), 'z', 'indicator 1 can be non-numeric' );
is( $r->field(245)->indicator(2), 'Z', 'indicator 2 can be non-numeric' );

# rumor had it that invalid indicators sometimes invalidated other
# valid indicators, so these tests make sure that is not the case

$r->append_fields( MARC::Field->new( 100, 'dk', 2, a=> 'foo' ) );
is( $r->field(100)->indicator(1), ' ', 'invalid indicator squashed to space' );
is( $r->field(100)->indicator(2), 2, 'not disturbed' );
$r->append_fields( MARC::Field->new( 111, 2, '-didk', a=> 'foo' ) );
is ($r->field(111)->indicator(1), 2, 'not disturbed' );
is ($r->field(111)->indicator(2), ' ', 'invalid indicator squashed to space' );

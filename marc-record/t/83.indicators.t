use Test::More tests => 11;
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

## read a file which has an invalid indicator (a hyphen) and make sure it does 
## not affect a valid indicator

use_ok( 'MARC::Batch' );

my $batch = MARC::Batch->new( 'USMARC', 't/badind.usmarc' );
$batch->strict_off();
$batch->warnings_off();

$r = $batch->next();
my @warnings = $batch->warnings();
is( $warnings[0], 'Invalid indicator "-" forced to blank', 
    'got expected warning message' );

is( $r->field(245)->indicator(1),' ','hyphen forced to blank in indicator 1' );
is( $r->field(245)->indicator(2),'0','indicator 2 undisturbed' );

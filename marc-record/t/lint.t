
use strict;
use Test::More tests=>24;

BEGIN { use_ok( 'MARC::File::USMARC' ); }
BEGIN { use_ok( 'MARC::Lint' ); }

my @expected = ( (undef) x 9, [ q{100: Indicator 1 must be 0, 1 or 3 but it's "2"} ] );

my $lint = new MARC::Lint;
isa_ok( $lint, 'MARC::Lint' );

my $filename = "t/camel.usmarc";

my $file = MARC::File::USMARC->in( $filename );
while ( my $marc = $file->next() ) {
    isa_ok( $marc, 'MARC::Record' );
    my $title = $marc->title;
    $lint->check_record( $marc );

    my $expected = shift @expected;
    my @warnings = $lint->warnings;

    if ( $expected ) {
	ok( eq_array( \@warnings, $expected ), "Warnings match on $title" );
    } else {
	is( scalar @warnings, 0, "No warnings on $title" );
    }
} # while

is( scalar @expected, 0, "All expected messages have been exhausted." );

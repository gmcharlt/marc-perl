use Test::More tests=>1;

use strict;
use warnings;
use MARC::Record;

## this test is only appropriate for the first unicode friendly perl

SKIP: {

    skip "Perl 5.8 or greater required for Unicode tests", '1' if $] < 5.008;

    ## create marc data with a utf8 char
    my $r1 = MARC::Record->new();
    $r1->append_fields(
	MARC::Field->new( '245', '0', '', a => chr( 0x05D0 ) )
    );
    my $m1 = $r1->as_usmarc();

    ## determine byte length
    use bytes;
    my $length = sprintf( '%05i', length($m1) );

    ## verify that the leader correctly calculated the byte length
    like( $r1->leader(), qr/^$length/, 'utf8 record has proper length' );

}

use Test::More tests => 5;

use strict;

## make sure that MARC::Field::subfield() is aware of the context 
## in which it is called. In list context it returns *all* subfields
## and in scalar just the first.

use_ok( 'MARC::Field' );
my $field = MARC::Field->new( '245', '', '', a => 'foo', b => 'bar', 
    a => 'baz' );
isa_ok( $field, 'MARC::Field' );

my $subfieldA = $field->subfield( 'a' );
is( $subfieldA, 'foo', 'subfield() in scalar context' );

my @subfieldsA = $field->subfield( 'a' );
is( $subfieldsA[0], 'foo', 'subfield() in list context 1' );
is( $subfieldsA[1], 'baz', 'subfield() in list context 2' );

#!perl -Tw

use Test::More tests => 12; 

use strict;

## make sure that MARC::Field::subfield() is aware of the context 
## in which it is called. In list context it returns *all* subfields
## and in scalar just the first.

use_ok( 'MARC::Field' );
my $field = MARC::Field->new( '245', '', '', a=>'foo', b=>'bar', a=>'baz' );
isa_ok( $field, 'MARC::Field' );

my $subfieldA = $field->subfield( 'a' );
is( $subfieldA, 'foo', 'subfield() in scalar context' );

my @subfieldsA = $field->subfield( 'a' );
is( $subfieldsA[0], 'foo', 'subfield() in list context 1' );
is( $subfieldsA[1], 'baz', 'subfield() in list context 2' );

## should not be able to call subfield on field < 010
$field = MARC::Field->new( '000', 'foobar' );
eval { $field->subfield( 'a' ) };
like( 
    $@, qr/Fields below 010 do not have subfields/, 
    'subfield cannot be called on fields < 010' 
);

## make sure we can delete subfields
$field = MARC::Field->new( '245', '', '', a=>'foo', b=>'bar', c=>'bez' );
is( $field->delete_subfields( 'b' ), 1, 'delete_subfields() return one field' );
is ( $field->as_string(), 'foo bez', 'delete_subfields() one field' );

## make sure we can delete multiple subfields
$field = MARC::Field->new( '245', '', '', a=>'foo', b=>'bar', c=>'bez' );
is( $field->delete_subfields( 'b', 'c' ), 2,
    'delete_subfields() return two fields');
is ( $field->as_string(), 'foo', 'delete_subfields() two fields' );

## and that all repeated subfields are removed
$field = MARC::Field->new( '245', '', '', a=>'foo', a=>'bar', c=>'bez' );
is( $field->delete_subfields( 'a' ), 2, 'delete_subfields() repeats return' );
is ( $field->as_string(), 'bez', 'delete_subfields() repeats' );




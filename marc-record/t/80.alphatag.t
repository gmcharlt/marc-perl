use Test::More tests => 16;

use strict;
use MARC::Record;
use MARC::Field;
use MARC::File;
use Data::Dumper;

## According to the MARC spec tags can have alphanumeric
## characters in them. They are rarely seen, but they are 
## allowed...and believe it or not some people actually use them!
## Tags must be alphanumeric, and three characters long.

my $record = MARC::Record->new();
my $field;

## this should fail since it is four chars long 
eval {
    $field = MARC::Field->new( '245A', '', '', 'a' => 'Test' );
};
like($@ ,qr/Tag "245A" is not a valid tag/, 'caught invalid tag "245A"' );

## this should fail since it is a four digit number
eval { 
    $field = MARC::Field->new( '2456', '', '', 'a' => 'Test' );
};
like($@, qr/Tag "2456" is not a valid tag/, 'caught invalid tag "2456"' );

## this should work be ok
$field = MARC::Field->new( 'RAZ', '1', '2', 'a' => 'Test' );
isa_ok( $field, 'MARC::Field', 'field with alphanumeric tag' );

is ( $field->subfield('a'), 'Test', 'subfield()' );

$field->update( 'a' => '123' );
is ( $field->subfield('a'), '123', 'update()' );

is_deeply( $field->subfields(), [ 'a' => 123 ], 'subfields()' );
is( $field->tag(), 'RAZ', 'tag()' );

eval { $field->data() };
like( $@, qr/data\(\) is only for tags less than 010/, 'data()' );

is( $field->indicator(1), '1', 'indicator(1)' );
is( $field->indicator(2), '2', 'indicator(2)' );

$field->add_subfields( 'b' => 'Freak' );
is( $field->subfield('b'), 'Freak', 'add_subfields()' );
is( $field->as_string(), '123 Freak', 'as_string()' );

my $text = "RAZ 12 _a123\n       _bFreak";
is( $field->as_formatted(), $text, 'as_formatted()' );

## make sure we can add a field with an alphanumeric tag to 
## a MARC::Record object

$record->append_fields( $field );
my $new = $record->field('RAZ');
isa_ok( $new, 'MARC::Field', 'able to grab field with alpha tag' );

$new = MARC::Field->new('100', '', '', 'a' => 'Gumble, Seth');
$record->append_fields( $new );

$new = MARC::Field->new('110', '', '', 'a' => 'Follett Library Resources');
$record->append_fields( $new );

my @fields = $record->field( '1..' );
is( scalar(@fields), 2, 'field(regex)' );

## test output as USMARC

my $marc = $record->as_usmarc();

open(OUT,">$0.usmarc");
print OUT $record->as_usmarc();
close(OUT);

my $file = MARC::File::USMARC->in( "$0.usmarc" );
my $newRec = $file->next();

is( $newRec->as_usmarc(), $marc, 'as_usmarc()' );
unlink( "$0.usmarc" );


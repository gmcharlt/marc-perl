use strict;
use warnings;
use Test::More tests => 4;
use MARC::Field;

my $field = MARC::Field->new('245', '0', '1', a=>'foo', b=>'bar', a=>'baz');
$field->delete_subfield(code => 'a');
is $field->as_string, 'bar', 'delete all subfield a';

$field = MARC::Field->new('245', '0', '1', a=>'foo', b=>'bar', a=>'baz');
$field->delete_subfield(code => 'a', count => 1);
is $field->as_string, 'bar baz', 'delete only first subfield a';

$field = MARC::Field->new('245', '0', '1', a=>'foo', b=>'bar', a=>'baz');
$field->delete_subfield(code => 'a', match => qr/baz/);
is $field->as_string, 'foo bar', 'delete all subfield a that match /baz/';

$field = MARC::Field->new('245', '0', '1', a=>'foo', b=>'bar', a=>'baz');
$field->delete_subfield(code => 'a', match => qr/bar/);
is $field->as_string, 'foo bar baz', 'do not delete wrong subfield match';


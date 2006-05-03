use strict;
use warnings;
use Test::More tests => 10;
use MARC::Field;

my $field = MARC::Field->new('245', '0', '1', a=>'foo', b=>'bar', a=>'baz');
$field->delete_subfield(code => 'a');
is $field->as_string, 'bar', 'delete by subfield code';

$field = MARC::Field->new('245', '0', '1', a=>'foo', b=>'bar', c=>'baz');
$field->delete_subfield(code => ['a','c']);
is $field->as_string, 'bar', 'delete by multiple subfield codes';

$field = MARC::Field->new('245', '0', '1', a=>'foo', b=>'bar', a=>'baz');
$field->delete_subfield(pos => 0);
is $field->as_string, 'bar baz', 'delete by pos';

$field = MARC::Field->new('245', '0', '1', a=>'foo', b=>'bar', a=>'baz');
$field->delete_subfield(pos => [0,2]);
is $field->as_string, 'bar', 'delete by multiple pos';

$field = MARC::Field->new('245', '0', '1', a=>'foo', b=>'bar', a=>'baz');
$field->delete_subfield(code => 'a', pos => [0,2]);
is $field->as_string, 'bar', 'delete by multiple pos with code';

$field = MARC::Field->new('245', '0', '1', a=>'foo', b=>'bar', a=>'baz');
$field->delete_subfield(code => 'b', pos => [0,2]);
is $field->as_string, 'foo bar baz', 'delete by multiple pos with wrong code';

$field = MARC::Field->new('245', '0', '1', a=>'foo', b=>'bar', a=>'baz');
$field->delete_subfield(code => 'a', match => qr/baz/);
is $field->as_string, 'foo bar', 'delete all subfield a that match /baz/';

$field = MARC::Field->new('245', '0', '1', a=>'foo', b=>'bar', a=>'baz');
$field->delete_subfield(code => 'a', match => qr/bar/);
is $field->as_string, 'foo bar baz', 'do not delete wrong subfield match';

eval { $field->delete_subfield(match => 'uhoh'); };
like $@, qr/match must be a compiled regex/, 'exception if match is not regex'; 


# update.t - Test updating a MARC record for the Camel book
#
# Bugs, comments, suggestions welcome: marc@petdance.com

use strict;
use integer;

use Test::More tests=>3;

BEGIN {
    use_ok( 'MARC::File::USMARC' );
}

my $file = MARC::File::USMARC->in( 't/camel.usmarc' );
my $marc = $file->next();
$file->close;

my $field = $marc->field('245');
$field->update('a' => 'Programming Python /');
is( $marc->subfield('245','a') => 'Programming Python /',
  'Updated 1 subfield' );

$field->update('a' => 'Programming Python /', 'c' => 'Mark Lutz');
is( $field->as_string() => 'Programming Python / Mark Lutz', 
  'Updated 2 subfields');


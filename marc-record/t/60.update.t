# $Id: 60.update.t,v 1.5 2002/08/25 21:27:59 petdance Exp $
# Test updating a MARC record for the Camel book

use strict;
use integer;
eval 'use warnings' if $] >= 5.006;

use Test::More tests=>9;

BEGIN {
    use_ok( 'MARC::File::USMARC' );
}

my $file = MARC::File::USMARC->in( 't/camel.usmarc' );
isa_ok( $file, 'MARC::File::USMARC', 'USMARC file' );

my $marc = $file->next();
isa_ok( $marc, 'MARC::Record' ) or die "Can't read the test record";
$file->close;

my $field = $marc->field('245');
isa_ok( $field, 'MARC::Field', 'new 245' );

my $nchanges = $field->update('a' => 'Programming Python /', 'ind1' => '4' );
is( $marc->subfield('245','a') => 'Programming Python /',
  'Updated 1 subfield' );
is( $field->indicator(1) => '4', 'Indicator 1 changed' );
is( $nchanges, 2 );

$nchanges = $field->update('a' => 'Programming Python /', 'c' => 'Mark Lutz');
is( $field->as_string() => 'Programming Python / Mark Lutz', 
  'Updated 2 subfields');
is( $nchanges, 2 );

# $Id: 60.update.t,v 1.6 2002/08/26 17:34:13 edsummers Exp $
# Test updating a MARC record for the Camel book

use strict;
use integer;
use Data::Dumper;
eval 'use warnings' if $] >= 5.006;

use Test::More tests=>10;

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


## make sure we can update fields with no subfields or indicators (000-009)

my $f003 = $marc->field('003');
$f003->update('XXXX');

$f003 = $marc->field('003');
is ( $f003->as_string(), 'XXXX', 'Update for fields 000-009 works' ); 


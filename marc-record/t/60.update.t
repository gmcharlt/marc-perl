# $Id: 60.update.t,v 1.8 2003/02/26 05:30:45 petdance Exp $
# Test updating a MARC record for the Camel book

use strict;
use integer;
use Data::Dumper;

use Test::More tests=>13;

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
isa_ok( $f003, 'MARC::Field' );
my $n = $f003->update('XXXX');
is( $n, 1 );

$f003 = $marc->field('003');
isa_ok( $f003, 'MARC::Field' );
is( $f003->as_string(), 'XXXX', 'Update for fields 000-009 works' ); 


# $Id: 61.replace.t,v 1.3 2002/08/25 21:27:59 petdance Exp $
# Test updating a MARC record for the Camel book

use strict;
use integer;
eval 'use warnings' if $] >= 5.006;

use Test::More tests=>8;

BEGIN {
    use_ok( 'MARC::File::USMARC' );
    use_ok( 'MARC::Field' );
}

my $file = MARC::File::USMARC->in( 't/camel.usmarc' );
isa_ok( $file, 'MARC::File', 'MARC input file' ) or die;
my $marc = $file->next();
isa_ok( $marc, 'MARC::Record', 'Read from file' );
$file->close;

my $cur_245 = $marc->field('245');
isa_ok( $cur_245, 'MARC::Field' );
my $new_245 = MARC::Field->new(
  '245','0','0',
  a => 'Programming Python /',
  c => 'Mark Lutz'
);
isa_ok( $new_245, 'MARC::Field' );

$cur_245->replace_with($new_245);
my $latest_245 = $marc->field('245');
isa_ok( $latest_245, 'MARC::Field' );

is( $latest_245->as_string() => 'Programming Python / Mark Lutz', 
  'Replaced a field');


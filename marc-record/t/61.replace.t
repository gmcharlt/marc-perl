# update.t - Test updating a MARC record for the Camel book
#
# Bugs, comments, suggestions welcome: marc@petdance.com

use strict;
use integer;

use Test::More tests=>2;

BEGIN {
    use_ok( 'MARC::File::USMARC','MARC::Field');
}

my $file = MARC::File::USMARC->in( 't/camel.usmarc' );
my $marc = $file->next();
$file->close;

my $cur_245 = $marc->field('245');
my $new_245 = MARC::Field->new(
  '245','0','0',
  a => 'Programming Python /',
  c => 'Mark Lutz'
);

$cur_245->replace_with($new_245);
my $latest_245 = $marc->field('245');

is( $latest_245->as_string() => 'Programming Python / Mark Lutz', 
  'Replaced a field');


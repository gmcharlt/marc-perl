use Test::More tests=>3;

## when MARC::Batch encounters errors in reading USMARC warnings 
## should be stored internally and be able to be retrieved with the
## warnings() method. MARC::Batch should *not* stop dead.

use strict;
eval 'use warnings' if $] >= 5.006;

use_ok( 'MARC::Batch' );

my $batch = MARC::Batch->new('USMARC','t/badsubf.usmarc');
my $count = 0;

while (defined ( my $record = $batch->next() ) ) {
    $count++;
}

my @warnings = $batch->warnings();
is( scalar(@warnings), 1, 'batch can retrieve warnings' );
is($count,1,'able to read a record with missing subfield data');


use Test::More tests=>3;

## badldr.usmarc is a batch of records that contains bad data between
## records, which corrupts the record length. We need to make sure that
## we get warnings on the bad records, and that we are able to continue
## processing the batch.

use strict;
eval 'use warnings' if $] >= 5.006;

use_ok( 'MARC::Batch' );

my $batch = MARC::Batch->new('USMARC','t/badldr.usmarc');
my $count = 0;

while (defined ( my $record = $batch->next() ) ) {
    $count++;
}

my @warnings = $batch->warnings();
is( scalar(@warnings),6,'should have gotten 5 warnings');

is($count,8,'able to read batch with corrupted records');


use Test::More tests=>2;

## badldr.usmarc is a batch of records that contains bad data between
## records, which corrupts the record length. We are going to make sure
## that we are able to ignore the bad record and  keep reading in the batch 
## and check that we get an appropriate warning

use strict;
eval 'use warnings' if $] >= 5.006;

use_ok( 'MARC::Batch' );

my $batch = MARC::Batch->new('USMARC','t/badldr.usmarc');
my $count = 0;

## there is a bad leader in one of 7 records, we should be able to read
## right past it

while (defined ( my $record = $batch->next() ) ) {
    $count++;
}

is($count,6,'able to skip corrupted records');


use Test::More 'no_plan'; # This should go back to # of tests.

## badldr.usmarc is a batch of records that contains bad data between
## records, which corrupts the record length. We are going to make sure
## that we are able to ignore the bad record and  keep reading in the batch 
## and check that we get an appropriate warning

use strict;
eval 'use warnings' if $] >= 5.006;

use_ok( 'MARC::Batch' );

my $batch = MARC::Batch->new('USMARC','t/badldr.usmarc');
my $count = 0;

## this should change once we decide how to signal bad records 

while (defined ( my $record = $batch->next() ) ) {
    if ($record == 0) {
	my @warnings = $batch->warnings();
	is( $warnings[0],"Couldn't find record length", 'correct warning');
	next;
    }
    $count++;
}

TODO: {
    local $TODO = "Not yet able to skip corrupted records.";

    is($count,6,'able to skip corrupted records');
}


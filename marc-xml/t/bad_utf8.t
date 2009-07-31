use strict;
use warnings;
use Test::More tests => 1;
use MARC::Batch;
use MARC::File::XML;

my $batch = MARC::Batch->new('USMARC', 't/bad_utf8.dat');
my $record = $batch->next();

print $record->as_xml();



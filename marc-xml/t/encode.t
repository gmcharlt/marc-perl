use strict;
use warnings;

use MARC::File::XML;
use MARC::Record;
use MARC::Batch;
use Test::More tests => 1;

## create a MARC::Record object from some MARC data on disk
my $batch = MARC::Batch->new( 'USMARC', 't/record.dat' );
my $r1 = $batch->next();

## serialize the record as XML
my $xml = $r1->as_xml();

## parse the XML into another MARC::Record object
my $r2 = MARC::File::XML::decode( $xml ); 

## make sure both MARC::Record objects are the same
is( $r1->as_formatted(), $r2->as_formatted(), 'xml encode/decode works' );

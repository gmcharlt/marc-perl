use strict;
use warnings;

use MARC::File::XML;
use MARC::Record;
use MARC::Batch;
use Test::More tests => 3;

## create a MARC::Record object from some MARC data on disk
my $batch = MARC::Batch->new( 'USMARC', 't/record.dat' );
my $r1 = $batch->next();

## serialize the record as XML
my $xml = $r1->as_xml();

## parse the XML into another MARC::Record object
my $r2 = MARC::Record->new_from_xml( $xml ); 

## make sure both MARC::Record objects are the same
is( $r1->as_formatted(), $r2->as_formatted(), 'xml encode/decode style 1' );

## try alternate calling style
my $r3 = MARC::Record::new_from_xml( $xml );
is( $r1->as_formatted(), $r3->as_formatted(), 'xml encode/decode style 2' );

my $xml2 = join( "\n", 
    MARC::File::XML::xml_header(),
    MARC::File::XML::xml_record( $r1 ),
    MARC::File::XML::xml_footer()
);

is ( $xml, $xml2, 'xml encode/decode style 3' );

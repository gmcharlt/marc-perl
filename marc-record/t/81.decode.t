use Test::More tests => 22;

use strict;
use MARC::Record;
use MARC::File::MicroLIF;
use MARC::File::USMARC;

## decode can be called in a variety of ways
##
## $obj->decode()
## MARC::File::MicroLIF->decode()
## MARC::File::MicroLIF::decode()
##
## $obj->decode()
## MARC::File::USMARC->decode()
## MARC::File::USMARC::decode()
##
## these tests make sure we don't break any of them

## slurp up some microlif
open(IN, 't/sample1.lif' );
my $str = join( '', <IN> );

## attempt to use decode() on it

my $rec = MARC::File::MicroLIF->decode( $str );
isa_ok( $rec, 'MARC::Record' );
like( $rec->title(), qr/all about whales/i, 'retrieved title' );

$rec = MARC::File::MicroLIF::decode( $str );
isa_ok( $rec, 'MARC::Record' );
like( $rec->title(), qr/all about whales/i, 'retrieved title' );

## slurp up some usmarc
open(IN, 't/sample1.usmarc' );
$str = join( '', <IN> );

## attempt to use decode on it

$rec = MARC::File::USMARC->decode( $str );
isa_ok( $rec, 'MARC::Record' );
like( $rec->title(), qr/all about whales/i, 'retrieved title' );

$rec = MARC::File::USMARC::decode( $str );
isa_ok( $rec, 'MARC::Record' );
like( $rec->title(), qr/all about whales/i, 'retrieved title' );


#
# make sure that MARC decode() can handle gaps in the record
# body and data in the body not being in directory order
# 
my @fragments = (
    "00214nam  22000978a 4500",
    "001001500000",
    "010000900015",
    "100002000024",
    "245001100044",   # length is 11
    "260003300059", 
    "650002400092", 
    "\x1e",
    "control number\x1e",
    "  \x1f" . "aLCCN\x1e",
    "1 \x1f" . "aName, Inverted.\x1e",
    # '@@@@' here is dead space after then end of the field.
    # The directory is set up so that the 245 field consists just
    # of two indicators, \x1f, 'a', 'Title.', and \x1e.  The four
    # characters after the \x1e constitute an (allowed) unused gap in the
    # record body.
    "10\x1f" . "aTitle.\x1e@@@@",
    "3 \x1f" . "aPlace : \x1f" . "bPublisher, \x1f" . "cYear.\x1e",
    " 0\x1f" . "aLC subject heading.\x1e",
    "\x1d"
);

$rec = MARC::File::USMARC->decode( join('', @fragments) );
my @w = $rec->warnings();
is( scalar @w, 0, 'should be no warnings' );
is( $rec->field('245')->as_usmarc(), "10\x1f" . "aTitle.\x1e", 'gap after field data should not be returned' );
my $the260 = $rec->field('260');
isa_ok( $the260, "MARC::Field" );
is( $the260->indicator(1), '3', 'indicators in tag after gap should be OK' );
is( $the260->subfield('a'), "Place : ", 'subfield a in tag after gap should be OK' );
is( $the260->subfield('b'), "Publisher, ", 'subfield b in tag after gap should be OK' );
is( $the260->subfield('c'), "Year.", 'subfield c in tag after gap should be OK' );

# rearrange the directory for next test
@fragments[1,6] = @fragments[6,1];
@fragments[2,5] = @fragments[5,2];

$rec = MARC::File::USMARC->decode( join('', @fragments) );
isa_ok( $rec, "MARC::Record" );
is( $rec->field('001')->as_string(), 'control number', '001 field correct' );
is( $rec->field('010')->as_string(), 'LCCN', '010 field correct' );
is( $rec->field('100')->as_string(), 'Name, Inverted.', '100 field correct' );
is( $rec->field('245')->as_string(), 'Title.', '245 field correct' );
is( $rec->field('260')->as_string(), 'Place :  Publisher,  Year.', '260 field correct' );
is( $rec->field('650')->as_string(), 'LC subject heading.', '650 field correct' );


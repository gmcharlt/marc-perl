use Test::More tests => 8;

use strict;
use MARC::Record;
use MARC::File::MicroLIF;
use MARC::File::USMARC;

my ( $str, $rec );

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
$str = join( '', <IN> );

## attempt to use decode() on it

$rec = MARC::File::MicroLIF->decode( $str );
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



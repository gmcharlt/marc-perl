#!/usr/bin/perl -w
# $Id: 60.insert.t,v 1.4 2002/07/01 15:45:27 petdance Exp $

use strict;
use integer;

use Test::More tests=>12;

BEGIN {
    use_ok( 'MARC::Batch' );
    use_ok( 'MARC::Field' );
}

my $batch = new MARC::Batch( 'MARC::File::USMARC', 't/camel.usmarc' );
isa_ok( $batch, 'MARC::Batch', 'Batch object creation' );

my $record = $batch->next();
isa_ok( $record, 'MARC::Record', 'Record object creation' );

my $f650 = $record->field('650');
isa_ok( $f650, 'MARC::Field', 'Field retrieval' );

my $new = MARC::Field->new('650','','0','a','World Wide Web.');
isa_ok( $new, 'MARC::Field', 'Field creation' );

my $newagain = MARC::Field->new('650','','0','a','Hockey etiquette.');
isa_ok( $newagain, 'MARC::Field', 'Field creation' );

## test append_fields()

$record->append_fields($new);

my $expected = 
<<MARC_DATA;
LDR 00755cam  22002414a 4500
001     fol05731351 
003     IMchF
005     20000613133448.0
008     000107s2000    nyua          001 0 eng  
010    _a   00020737 
020    _a0471383147 (paper/cd-rom : alk. paper)
040    _aDLC
       _cDLC
       _dDLC
042    _apcc
050 00 _aQA76.73.P22
       _bM33 2000
082 00 _a005.13/3
       _221
100 1  _aMartinsson, Tobias,
       _d1976-
245 10 _aActivePerl with ASP and ADO /
       _cTobias Martinsson.
260    _aNew York :
       _bJohn Wiley & Sons,
       _c2000.
300    _axxi, 289 p. :
       _bill. ;
       _c23 cm. +
       _e1 computer  laser disc (4 3/4 in.)
500    _a"Wiley Computer Publishing."
650  0 _aPerl (Computer program language)
630 00 _aActive server pages.
630 00 _aActiveX.
650  0 _aWorld Wide Web.
MARC_DATA
chomp($expected);

is($record->as_formatted, $expected, "append_fields");
$record->delete_field($new);

## test insert_fields_after

my $nadds = $record->insert_fields_after($f650,$new,$newagain);
is( $nadds, 2, 'Added 2 fields' );

$expected = 
<<MARC_DATA;
LDR 00755cam  22002414a 4500
001     fol05731351 
003     IMchF
005     20000613133448.0
008     000107s2000    nyua          001 0 eng  
010    _a   00020737 
020    _a0471383147 (paper/cd-rom : alk. paper)
040    _aDLC
       _cDLC
       _dDLC
042    _apcc
050 00 _aQA76.73.P22
       _bM33 2000
082 00 _a005.13/3
       _221
100 1  _aMartinsson, Tobias,
       _d1976-
245 10 _aActivePerl with ASP and ADO /
       _cTobias Martinsson.
260    _aNew York :
       _bJohn Wiley & Sons,
       _c2000.
300    _axxi, 289 p. :
       _bill. ;
       _c23 cm. +
       _e1 computer  laser disc (4 3/4 in.)
500    _a"Wiley Computer Publishing."
650  0 _aPerl (Computer program language)
650  0 _aWorld Wide Web.
650  0 _aHockey etiquette.
630 00 _aActive server pages.
630 00 _aActiveX.
MARC_DATA
chomp($expected);

is($record->as_formatted,$expected,'insert_fields_after');
$record->delete_field($new);
$record->delete_field($newagain);


## test insert_record_before

$nadds = $record->insert_fields_before($f650, MARC::Field->new('650','4','3','a','House painting.'), $new );
is( $nadds, 2, 'Added 2 more fields' );

$expected = 
<<MARC_DATA;
LDR 00755cam  22002414a 4500
001     fol05731351 
003     IMchF
005     20000613133448.0
008     000107s2000    nyua          001 0 eng  
010    _a   00020737 
020    _a0471383147 (paper/cd-rom : alk. paper)
040    _aDLC
       _cDLC
       _dDLC
042    _apcc
050 00 _aQA76.73.P22
       _bM33 2000
082 00 _a005.13/3
       _221
100 1  _aMartinsson, Tobias,
       _d1976-
245 10 _aActivePerl with ASP and ADO /
       _cTobias Martinsson.
260    _aNew York :
       _bJohn Wiley & Sons,
       _c2000.
300    _axxi, 289 p. :
       _bill. ;
       _c23 cm. +
       _e1 computer  laser disc (4 3/4 in.)
500    _a"Wiley Computer Publishing."
650 43 _aHouse painting.
650  0 _aWorld Wide Web.
650  0 _aPerl (Computer program language)
630 00 _aActive server pages.
630 00 _aActiveX.
MARC_DATA
chomp($expected);

is($record->as_formatted,$expected,'insert_fields_before');


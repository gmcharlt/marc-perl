#!/usr/bin/perl -w

use strict;
use integer;

use Test::More tests=>6;

BEGIN {
    use_ok( 'MARC::Record');
    use_ok( 'MARC::Field');
}

my $record = MARC::Record->new();
ok( defined $record, 'Record object creation' );

my $f245 = MARC::Field->new('245','1','0','a','Test create.');
ok( defined $f245, '245 creation');

my $f650 = MARC::Field->new('650','','0','a','World Wide Web.');
ok( defined $f650, '650 creation');

$record->append_fields($f245,$f650);
$record->as_usmarc(); ## side effect is that leader offsets are calculated  

my $expected = 
<<MARC_DATA;
LDR 00087       00049       
245 10 _aTest create.
650  0 _aWorld Wide Web.
MARC_DATA
chomp($expected);

is($record->as_formatted,$expected,'New record matches');

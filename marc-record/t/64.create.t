# $Id: 64.create.t,v 1.5 2002/08/25 21:27:59 petdance Exp $

use strict;
use integer;
eval 'use warnings' if $] >= 5.006;

use Test::More tests=>6;

BEGIN {
    use_ok( 'MARC::Record');
    use_ok( 'MARC::Field');
}

my $record = MARC::Record->new();
isa_ok( $record, 'MARC::Record', 'Record object creation' );

my $f245 = MARC::Field->new('245','1','0','a','Test create.');
isa_ok( $f245, 'MARC::Field', '245 creation');

my $f650 = MARC::Field->new('650','','0','a','World Wide Web.');
isa_ok( $f650, 'MARC::Field', '650 creation');

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

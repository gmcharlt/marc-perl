use Test::More ( tests => 4 );

use strict;
use MARC::Batch;

my $b = MARC::Batch->new( 'USMARC', 't/camel.usmarc' );
isa_ok( $b, 'MARC::Batch' );

my $r = $b->next();
isa_ok( $r, 'MARC::Record' );

my $f245 = $r->field( '245' );
is( 
    $f245->as_string( 'a' ), 
    'ActivePerl with ASP and ADO /',
    'as_string() with one subfield'
);
is( 
    $f245->as_string( 'ac' ), 
    'ActivePerl with ASP and ADO / Tobias Martinsson.',
    'as_string() with two subfields'
);


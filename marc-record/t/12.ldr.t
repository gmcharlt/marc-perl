#!/usr/bin/perl

# test to make sure leader is being populated properly

use strict;
use Test::More tests => 7;

use_ok( 'MARC::Record' );

my $r = MARC::Record->new();
isa_ok( $r, 'MARC::Record' );
$r->append_fields( 
    MARC::Field->new( 
	245, 0, 0, a => 'Curious George battles the MARC leader'
    )
);

my $marc = $r->as_usmarc();
like( substr( $marc,0, 5 ), qr/^\d+$/, 'leader length' );
is( substr( $marc, 10, 1 ), '2', 'indicator count' );
is( substr( $marc, 11, 1 ), '2', 'subfield code count' );
like( substr( $marc, 12, 5 ), qr/^\d+$/, 'base address' );
is( substr( $marc, 20, 4 ), '4500', 'entry map' );



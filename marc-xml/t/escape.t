use strict;
use warnings;
use Test::More tests => 10; 

# test escaping of < > and & for XML

use_ok( 'MARC::File::XML' );

is( MARC::File::XML::escape( 'foo&bar&baz' ), 'foo&amp;bar&amp;baz', '&' );
is( MARC::File::XML::escape( 'foo>bar>baz' ), 'foo&gt;bar&gt;baz', '>' );
is( MARC::File::XML::escape( 'foo<bar<baz' ), 'foo&lt;bar&lt;baz', '<' );

use_ok( 'MARC::Record' );
use_ok( 'MARC::Field' );

my $r = MARC::Record->new();
isa_ok( $r, 'MARC::Record' );

$r->leader( '&xyz<123>' );
$r->append_fields(
    MARC::Field->new( '005', '&abc<def>' ),
    MARC::Field->new( '245', 0, 1, a => 'Foo&Bar<Baz>' )
);

my $xml = $r->as_xml();
like( $xml, qr/&amp;xyz&lt;123&gt;/, 'escaped leader' );
like( $xml, qr/&amp;abc&lt;def&gt;/, 'escape control field' );
like( $xml, qr/Foo&amp;Bar&lt;Baz&gt;/, 'escaped field' );

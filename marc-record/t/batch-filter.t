#!perl -Tw

use strict;
use Test::More;

plan( tests => 5 );

use_ok( 'MARC::Batch' );

my $b = MARC::Batch->new( 'USMARC', 't/camel.usmarc' );
isa_ok( $b, 'MARC::Batch' );

my $r = $b->next( \&wanted );
isa_ok( $r, 'MARC::Record' );

my @fields = $r->fields();
is( scalar( @fields ), 1, 'filter worked' );

eval { $r = $b->next( 'barf' ); };
like( $@, qr/filter function in next\(\)/, 'error message' );


sub wanted {
    my ( $tag, $data ) = @_;
    if ( $tag ne '245' ) { return ( 0 ); }
    return( 1 );
}

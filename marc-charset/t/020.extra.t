use Test::More tests=>37;

BEGIN {
    use_ok('MARC::Charset');
    use_ok('MARC::Charset::Subscripts');
    use_ok('MARC::Charset::Superscripts');
    use_ok('MARC::Charset::GreekSymbols');
}

my $cs = MARC::Charset->new();

## Subscripts

$cs->g0( MARC::Charset::Subscripts->new() );
isa_ok( $cs->g0, 'MARC::Charset::Subscripts' );

%valid = (

chr(0x28)=>chr(0x208D), 
chr(0x29)=>chr(0x208E),
chr(0x2B)=>chr(0x208A), 
chr(0x2D)=>chr(0x208B), 
chr(0x30)=>chr(0x2080), 
chr(0x31)=>chr(0x2081), 
chr(0x32)=>chr(0x2082), 
chr(0x33)=>chr(0x2083), 
chr(0x34)=>chr(0x2084), 
chr(0x35)=>chr(0x2085), 
chr(0x36)=>chr(0x2086), 
chr(0x37)=>chr(0x2087), 
chr(0x38)=>chr(0x2088), 
chr(0x39)=>chr(0x2089), 
 
);

testValid(\%valid,'subscript');

## Superscripts 

$cs->g0( MARC::Charset::Superscripts->new() ); 
isa_ok( $cs->g0(), 'MARC::Charset::Superscripts' );

%valid = (

chr(0x28)=>chr(0x207D), 
chr(0x29)=>chr(0x207E),
chr(0x2B)=>chr(0x207A), 
chr(0x2D)=>chr(0x207B), 
chr(0x30)=>chr(0x2070), 
chr(0x31)=>chr(0x00B9), 
chr(0x32)=>chr(0x00B2), 
chr(0x33)=>chr(0x00B3), 
chr(0x34)=>chr(0x2074), 
chr(0x35)=>chr(0x2075), 
chr(0x36)=>chr(0x2076), 
chr(0x37)=>chr(0x2077), 
chr(0x38)=>chr(0x2078), 
chr(0x39)=>chr(0x2079), 

);

testValid(\%valid,'superscript');


## Greek Symbols

$cs->g0( MARC::Charset::GreekSymbols->new() );

%valid = (
chr(0x61)=>chr(0x03B1),  
chr(0x62)=>chr(0x03B2),  
chr(0x63)=>chr(0x03B3),  
);

testValid(\%valid,'GreekSymbol');

###

sub testValid {
    my ($valid,$type) = @_;
    while ( my($test,$expected) = each %$valid ) {
	is( $cs->to_utf8($test), $expected,
	    "valid $type character chr(0x".sprintf("%2x",ord($test)).')'
	); 
    }
}


1;

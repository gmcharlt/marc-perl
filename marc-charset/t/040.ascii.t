use Test::More tests => 95;
use strict;
use MARC::Charset;
my $cs = MARC::Charset->new();

## see if we can use valid ASCII characters

foreach my $hex ( 0x21 .. 0x7E ) {
    my $char = chr($hex);
    my $converted = $cs->to_utf8($char);
    is( $converted => $char,
	'valid ASCII character chr(0x'.sprintf("%2x",$hex).')'
    ); 
}

is($cs->to_utf8('the rain in spain'),'the rain in spain','ASCII string');


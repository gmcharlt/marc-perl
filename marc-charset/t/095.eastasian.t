use strict;
use Test::More;
use MARC::Charset;
use MARC::Charset::Generic qw( :all );

BEGIN: {
    eval ( "use DB_File" ); 
    if ( $@ ) { 
	plan skip_all => "DB_File required for testing East Asian characters";
    }
}

plan tests => 15741;

my $c = MARC::Charset->new();
isa_ok( $c, 'MARC::Charset' );

## I have no idea what these characters are, but I know they are
## from the EastAsian set

my $marc8 = 
    "here are some ideographs: ".    
    ESCAPE .  MULTI_G0_A . CJK .
    chr(0x21).chr(0x30).chr(0x35) .
    chr(0x21).chr(0x30).chr(0x64) .
    ESCAPE .  SINGLE_G0_A . BASIC_LATIN .
    " wasn't that fun";

my $utf8 =
    "here are some ideographs: " .
    chr(0x4E32) .
    chr(0x4EBA) .
    " wasn't that fun";

is ( $c->to_utf8( $marc8 ), $utf8, 'to_utf8() with escapes' );

## lets be bold and check everything

## make EastAsian our G0 character set
$c->g0( MARC::Charset::EastAsian->new() );

open( IN, "data/EastAsian.txt" )
    || die "couldn't find data/EastAsian.txt: $!";

while ( my $line = <IN> ) {
    next if $line =~ /^#/;
    my @cols = split/,/,$line;
    my @from = ( $cols[0] =~ /(..)(..)(..)/ );
    my $marc8;
    foreach ( @from ) { $marc8 .= chr( hex($_) ); }
    my $utf8 = chr( hex($cols[1]) );
    is ( $c->to_utf8( $marc8 ), $utf8, "to_utf8() $marc8" );
}


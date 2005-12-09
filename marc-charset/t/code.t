use Test::More no_plan;
use strict;
use warnings;

use_ok('MARC::Charset::Code');

ONE_BYTE_CHAR: 
{
    my $code = MARC::Charset::Code->new();
    $code->name('UPPERCASE POLISH L');
    $code->marc('A1');
    $code->ucs('0141');
    $code->charset('45');

    is(chr(0x45). ':' . chr(0xA1), $code->marc8_hash_code(), 'hash_code()');
    is('EXTENDED_LATIN', $code->charset_name(), 'charset_name()');
}

THREE_BYTE_CHAR:
{
    my $code = MARC::Charset::Code->new();
    $code->name('EACC component character');
    $code->marc('212A45');
    $code->ucs('E8F2');
    $code->charset('31');

    is(chr(0x31).':'.chr(0x21).chr(0x2A).chr(0x45), $code->marc8_hash_code(), 
        'three byte hash_code()');
    is('CJK', $code->charset_name(), 'three byte charset_name()');
}


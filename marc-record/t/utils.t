use Test::More tests => 4;
use strict;
use warnings;

use_ok( 'MARC::File' );
use_ok( 'MARC::File::Utils' );

SKIP: {

    skip 'need to have modern perl for utf8 testing', 2
        if ! MARC::File::utf8_safe();

    is( 
        MARC::File::Utils::byte_length( chr( 0x05D0 ) ), 
        2, 
        'safe_length() utf8' 
    );
    is( 
        MARC::File::Utils::byte_substr( chr( 0x05D0 ), 0, 2 ), 
        chr( 0x05D0 ),
        'safe_substr() utf8' 
    );

} 


package MARC::File::Utils;

# these are utility functions that need to live in a separate namespace
# from MARC::File::USMARC since they use the Encode module, which exports
# encode() and decode() by default, and interfere with functions of the
# same name in MARC::File::USMARC and friends.

use strict;

sub safe_substr {
    my ( $str, $pos, $len ) = @_;
    return( substr( $str, $pos, $len ) ) if ! utf8_safe(); 
    eval( "use Encode" );
    use bytes;
    my $utf8 = substr( $str, $pos, $len );
    return( decode( 'utf8', $utf8 ) );
}

sub safe_length {
    my $str = shift;
    return( length( $str ) ) if ! utf8_safe();
    use bytes;
    return( length( $str ) );
}

sub utf8_safe {
    return( 1 ) if $] >= 5.008001;
    return( 0 );
}

1;

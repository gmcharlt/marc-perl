package MARC::File::Utils;

sub byte_substr {
    use Encode;
    use bytes;
    my ( $str, $pos, $len ) = @_;
    my $utf8 = substr( $str, $pos, $len );
    return( decode( 'utf8', $utf8 ) );
}

sub byte_length {
    use bytes;
    my $str = shift;
    return( length( $str ) );
}

1;

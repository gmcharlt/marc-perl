package MARC::File::Utils;

=head1 Functions

=head2 byte_substr( $str, $pos, $len )

A utf8-safe version of C<substr()>.

=cut

sub byte_substr {
    use Encode;
    use bytes;
    my ( $str, $pos, $len ) = @_;
    my $utf8 = substr( $str, $pos, $len );
    return decode( 'utf8', $utf8 );
}

=head2 byte_length

A utf8-safe version of C<length()>.

=cut

sub byte_length {
    use bytes;
    my $str = shift;
    return length( $str );
}

1;

package MARC::File::Utils;

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

__END__

=head1 RELATED MODULES

L<MARC::Record>

=head1 TODO

Make some sort of autodispatch so that you don't have to explicitly
specify the MARC::File::X subclass, sort of like how DBI knows to
use DBD::Oracle or DBD::Mysql.

Create a toggle-able option to check inside the field data for
end of field characters.  Presumably it would be good to have
it turned on all the time, but it's nice to be able to opt out
if you don't want to take the performance hit.

=head1 LICENSE

This code may be distributed under the same terms as Perl itself.

Please note that these modules are not products of or supported by the
employers of the various contributors to the code.

=head1 AUTHOR

Andy Lester, C<< <andy@petdance.com> >>

=cut


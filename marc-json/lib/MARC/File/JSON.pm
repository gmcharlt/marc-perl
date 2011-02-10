package MARC::File::JSON;

=head1 NAME

MARC::File::JSON - express MARC as JSON

=cut

use strict;
use warnings;

use vars qw( $VERSION $ERROR );

use MARC::File;
use vars qw( @ISA ); @ISA = qw( MARC::File );

use MARC::Record qw( LEADER_LEN );
use MARC::Field;
use JSON;

$VERSION = '0.01';

=head1 SYNOPSIS

    use MARC::File::JSON;

    my $file = MARC::File::JSON->in( $filename );

    while ( my $marc = $file->next() ) {
        # Do something
    }
    $file->close();
    undef $file;

=head1 EXPORT

None.

=head1 METHODS

=cut

sub _next {
    my $self = shift;
    my $fh = $self->{fh};

    return if eof($fh);

    return; # FIXME not yet implemented
}

=head2 decode( $string [, \&filter_func ] )

Constructor for handling MARC record encoded as a JSON string.  The JSON
object is expected to conform to the following schema:

L<http://dilettantes.code4lib.org/files/marc-schema.json>

Further details can be found at:

L<http://dilettantes.code4lib.org/blog/2010/09/a-proposal-to-serialize-marc-in-json/>

Any warnings or coercions can be checked in the C<warnings()> function.

The C<$filter_func> is an optional reference to a user-supplied function
that determines on a tag-by-tag basis if you want the tag passed to it
to be put into the MARC record.  The function is passed the tag number
and and the data, and must return a boolean.  The return of a true
value tells MARC::File::JSON::decode that the tag should get put into
the resulting MARC record.  Note that unlike L<MARC::File::USMARC>, the tag
data is not a string grabbed from a raw ISO2709 record; instead, it is a
hashref representing the JSON object for the field.

=cut

sub decode {

    my $text;
    my $location = '';

    ## decode can be called in a variety of ways
    ## $object->decode( $string )
    ## MARC::File::JSON->decode( $string )
    ## MARC::File::JSON::decode( $string )
    ## this bit of code covers all three

    my $self = shift;
    if ( ref($self) =~ /^MARC::File/ ) {
        $location = 'in record '.$self->{recnum};
        $text = shift;
    } else {
        $location = 'in record 1';
        $text = $self=~/MARC::File/ ? shift : $self;
    }
    my $filter_func = shift;

    # ok this the empty shell we will fill
    my $marc = MARC::Record->new();

    my $obj = decode_json($text); # FIXME failure?
    $marc->leader($obj->{leader})
        or return $marc->_warn( "No leader supplied in JSON record" );

    my @fields = ();
    foreach my $field ( @{ $obj->{fields} } ) {
        my @tags = keys( %$field );
        return $marc->_warn( 'Invalid JSON - field has no tag' ) if @tags == 0;
        return $marc->_warn( 'Invalid JSON - field has multiple tags: ' . join(', ', @tags) ) if @tags > 1;
        my $tag = $tags[0];
        if ( ref($field->{$tag}) eq '' ) {
            if ( !$filter_func || $filter_func->( $tag, $field->{$tag} ) ) {
                push @fields, MARC::Field->new( $tag, $field->{$tag} ); 
            }
        } else {
            if  ( !$filter_func || $filter_func->( $tag, $field ) ) {
                push @fields, MARC::Field->new( $tag,
                                                $field->{$tag}->{ind1},
                                                $field->{$tag}->{ind2},
                                                map { keys(%$_) => values(%$_) } @{ $field->{$tag}->{subfields} }
                                            );
            }
        }
    }
    $marc->append_fields(@fields);

    return $marc;
}

=head2 encode()

Returns a string of characters suitable for writing out to a JSON file,
including the leader, directory and all the fields.

=cut

sub encode {
    my $marc = shift;
    $marc = shift if (ref($marc)||$marc) =~ /^MARC::File/;

    # make data structure which we'll emit as JSON
    my $obj = {
        leader => $marc->leader(),
        fields => [
            map { {
                $_->tag() => $_->is_control_field() ?
                    $_->data() :
                    {
                        ind1 => $_->indicator(1),
                        ind2 => $_->indicator(2),
                        subfields => [
                            map { {
                                $_->[0] => $_->[1]
                            } } $_->subfields()
                        ], 
                    }
            } } $marc->fields()
        ],
    };

    return encode_json($obj);
}

1;

__END__

=head1 RELATED MODULES

L<MARC::Record>

=head1 LICENSE

This code may be distributed under the same terms as Perl itself.

Please note that these modules are not products of or supported by the
employers of the various contributors to the code.

=head1 ACKNOWLEDGEMENTS

A tip of the hat to Bill Dueber, Ross Singer, and others for paving
the way.

=head1 AUTHORS

=over 4 

=item * Galen Charlton E<lt>gmcharlt@gmail.comE<gt>

=back

=cut


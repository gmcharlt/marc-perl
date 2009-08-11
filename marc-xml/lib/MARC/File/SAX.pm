package MARC::File::SAX;

=head1 NAME

MARC::File::SAX - SAX handler for parsing MARCXML

=cut 

use strict;
use XML::SAX;
use base qw( XML::SAX::Base );
use Data::Dumper;
use MARC::Record;
use MARC::Charset qw(utf8_to_marc8);
use Carp qw(croak);

=head2 new()

Create the handler.

=cut

sub new {
    my $class = shift;
    return bless {records => []}, ref($class) || $class;
}

=head2 records()

Get all the MARC::Records that were parsed out of the XML.

=cut

sub records {
    return shift->{records};
}

=head2 record()

In some contexts you might only expect there to be one record parsed. This
is a shorthand for getting it.

=cut 

sub record {
    return shift->{records}[0];
}

sub start_element {
    my ( $self, $element ) = @_;
    my $name = $element->{ LocalName };
    if ( $name eq 'record' ) {
        $self->{ record } = MARC::Record->new();
    } elsif ( $name eq 'collection' ) {
        # ignore collection wrappers
    } elsif ( defined $self->{ record } ) {
        if ( $name eq 'leader' ) { 
            $self->{ tag } = 'LDR';
        } elsif ( $name eq 'controlfield' ) {
            $self->{ tag } = $element->{ Attributes }{ '{}tag' }{ Value };
        } elsif ( $name eq 'datafield' ) { 
            $self->{ tag } = $element->{ Attributes }{ '{}tag' }{ Value };
            $self->{ i1 } = $element->{ Attributes }{ '{}ind1' }{ Value };
            $self->{ i2 } = $element->{ Attributes }{ '{}ind2' }{ Value };
        } elsif ( $name eq 'subfield' ) { 
            $self->{ subcode } = $element->{ Attributes }{ '{}code' }{ Value };
        }
    } else {
        # we've reached a new element but haven't started populating
        # a MARC::Record yet.  This either means that we've encountered
        # some non-MARC21slim stuff or the caller's given us an invalid
        # doc that doesn't include a <record> element.
        # In the first case, we'll just ignore the element; in the second
        # case, we'll thow an exception with a better description.
        #
        # TODO: to be more consistent with how MARC::File::USMARC handles
        #        parse errors, rather than throwing an exception we could
        #        instantiate an empty MARC::Record and set its warnings
        #        array.
        #
        if ( $name eq 'leader' || $name eq 'controlfield' || $name eq 'datafield' || $name eq 'subfield' ) {
            croak("found MARCXML element $name, but the <record> wrapper is missing");
        }
    }
}

sub end_element { 
    my ( $self, $element ) = @_;
    my $name = $element->{ LocalName };
    if ( $name eq 'subfield' ) { 
        push @{ $self->{ subfields } }, $self->{ subcode };

        if ($self->{ transcode }) {
            push @{ $self->{ subfields } }, utf8_to_marc8($self->{ chars });
        } else {
            push @{ $self->{ subfields } }, $self->{ chars } ;
        }

        $self->{ chars } = '';
        $self->{ subcode } = '';
    } elsif ( $name eq 'controlfield' ) { 
        $self->{ record }->append_fields(
            MARC::Field->new( $self->{ tag }, $self->{ chars } )
        );
        $self->{ chars } = '';
        $self->{ tag } = '';
    } elsif ( $name eq 'datafield' ) { 
        $self->{ record }->append_fields( 
            MARC::Field->new( 
                $self->{ tag }, 
                $self->{ i1 }, 
                $self->{ i2 },
                @{ $self->{ subfields } }
            )
        );
        $self->{ tag } = '';
        $self->{ i1 } = '';
        $self->{ i2 } = '';
        $self->{ subfields } = [];
        $self->{ chars } = '';
    } elsif ( $name eq 'leader' ) { 
        my $ldr = $self->{ chars };

        $self->{ transcode }++
            if (substr($ldr,9,1) eq 'a' and $self->{toMARC8});

        substr($ldr,9,1,' ') if ($self->{ transcode });

        $self->{ record }->leader( $ldr );
        $self->{ chars } = '';
        $self->{ tag } = '';
    } elsif ( $name eq 'record' ) {
        push(@{ $self->{ records } }, $self->{ record });
        undef $self->{ record };
    }
}

sub characters {
    my ( $self, $chars ) = @_;
    if (
        ( exists $self->{ subcode } && $self->{ subcode } ne '')
        || ( $self->{ tag } && ( $self->{ tag } eq 'LDR' || $self->{ tag } < 10 ))
    ) { 
        $self->{ chars } .= $chars->{ Data };
    } 
}

1;

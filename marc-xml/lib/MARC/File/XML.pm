package MARC::File::XML;

use warnings;
use strict;
use base qw( MARC::File );
use MARC::Record;
use MARC::Field;
use MARC::File::SAX;

our $VERSION = '0.6';

my $handler = MARC::File::SAX->new();
my $parser = XML::SAX::ParserFactory->parser( Handler => $handler );

=head1 NAME

MARC::File::XML - Work with MARC data encoded as XML 

=head1 SYNOPSIS

    ## reading with MARC::Batch
    my $batch = MARC::Batch->new( 'XML', $filename );
    my $record = $batch->next();

    ## or reading with MARC::File::XML explicitly
    my $file = MARC::File::XML::in( $filename );
    my $record = $file->next();

    ## serialize a single MARC::Record object as XML
    print $record->as_xml();

    ## or serializing more than one MARC::Record objects as XML
    print MARC::File::XML::xml_header();
    print MARC::File::XML::xml_record( $record1 );
    print MARC::File::XML::xml_record( $record2 );
    print MARC::File::XML::xml_footer();

=head1 DESCRIPTION

The MARC-XML distribution is an extension to the MARC-Record distribution for 
working with MARC21 data that is encoded as XML. The XML encoding used is the
MARC21slim schema supplied by the Library of Congress. More information may 
be obtained here: http://www.loc.gov/standards/marcxml/

You must have MARC::Record installed to use MARC::File::XML. In fact 
once you install the MARC-XML distribution you will most likely not use it 
directly, but will have an additional file format available to you when you
use MARC::Batch.

This version of MARC-XML supersedes an the versions ending with 0.25 which 
were used with the MARC.pm framework. MARC-XML now uses MARC::Record 
exclusively.

If you have any questions or would like to contribute to this module please
sign on to the perl4lib list. More information about perl4lib is available
at L<http://perl4lib.perl.org>.

=head1 METHODS

When you use MARC::File::XML your MARC::Record objects will have two new
additional methods available to them: 

=head2 new_from_xml()

=cut 

sub MARC::Record::new_from_xml {
    my $xml = shift;
    ## to allow calling as MARC::Record::new_from_xml()
    ## or MARC::Record->new_from_xml()
    $xml = shift if ( ref($xml) || ($xml eq "MARC::Record") );
    return( MARC::File::XML::decode( $xml ) );
}


=head2 as_xml()

=cut 

sub MARC::Record::as_xml {
    my $record = shift;
    return(  MARC::File::XML::encode( $record ) );
}

=pod

If you end up building batches of records in XML files you will probably want 
to use these functions instead:

=head2 xml_header() 

=cut 

sub xml_header {
    return( <<MARC_XML_HEADER );
<?xml version="1.0" encoding="UTF-8"?>
<collection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd" xmlns="http://www.loc.gov/MARC21/slim">
MARC_XML_HEADER
}

=head2 xml_footer()

=cut

sub xml_footer {
    return( "</collection>" );
}

=head2 xml_record()

=cut

sub xml_record {
    my $record = shift;
    my @xml = ();
    push( @xml, "<record>" );
    push( @xml, "  <leader>" . $record->leader() . "</leader>" );
    foreach my $field ( $record->fields() ) {
        my $tag = $field->tag();
        if ( $field->is_control_tag() ) { 
            my $data = $field->data();
            push( @xml, qq(  <controlfield tag="$tag">$data</controlfield>) );
        } else {
            my $i1 = $field->indicator( 1 );
            my $i2 = $field->indicator( 2 );
            push( @xml, qq(  <datafield tag="$tag" ind1="$i1" ind2="$i2">) );
            foreach my $subfield ( $field->subfields() ) { 
                my ( $code, $data ) = @$subfield;
                push( @xml, qq(    <subfield code="$code">$data</subfield>) );
            }
            push( @xml, "  </datafield>" );
        }
    }
    push( @xml, "</record>\n" );
    return( join( "\n", @xml ) );
}

sub _next {
    my $self = shift;
    my $xml = $self->{ xml } || '';
    my $fh = $self->{ fh };

    ## return undef at the end of the file
    return if eof($fh);

    ## get a chunk of xml for a record
    my $found = 0;
    while ( ! $found ) { 
	my $line = <$fh>;
	last if ! defined( $line );
	my ( $pre, $end, $post ) = $line =~ m{^ (.*) (</record.*?>) (.*) $}ix;
	if ( ! $end ) { 
	    $xml .= $line;
	} else {
	    $found = 1;
	    $xml .= $pre;
	    $self->{ xml } = $post;
	}
    }

    ## trim stuff before the start record element 
    $xml =~ s/.*<record.*?>/<record>/s;

    ## return undef if there isn't a good chunk of xml
    return if ( $xml !~ m|<record>.*</record>|s );
    
    ## return the chunk of xml
    return( $xml );
}

=head2 decode()

You probably don't ever want to call this method directly. If you do 
you should pass in a chunk of XML as the argument. 

It is normally invoked by a call to next(), see L<MARC::Batch> or L<MARC::File>.

=cut

sub decode { 

    my $text; 
    my $location = '';
    my $self = shift;

    ## see MARC::File::USMARC::decode for explanation of what's going on
    ## here
    if ( ref($self) =~ /^MARC::File/ ) {
	$location = 'in record '.$self->{recnum};
	$text = shift;
    } else {
	$location = 'in record 1';
	$text = $self=~/MARC::File/ ? shift : $self;
    }

    $parser->{ tagStack } = [];
    $parser->{ subfields } = [];
    $parser->{ Handler }{ record } = MARC::Record->new();
    $parser->parse_string( $text );

    return( $parser->{ Handler }{ record } );
    
}

=head2 encode()

You probably want to use the as_marc() method on your MARC::Record object
instead of calling this directly. But if you want to you just need to 
pass in the MARC::Record object you wish to encode as XML, and you will be
returned the XML as a scalar.

=cut

sub encode {
    my $record = shift;
    my @xml = ();
    push( @xml, xml_header() );
    push( @xml, xml_record( $record ) );
    push( @xml, xml_footer() );
    return( join( "\n", @xml ) );
}

=head1 TODO

=over 4

=item * Implement MARC::File::XML::encode() for encoding as XML.

=item * Support for character translation using MARC::Charset.

=item * Support for callback filters in decode().

=item * Command line utilities marc2xml, etc.

=back

=head1 SEE ALSO

=over 4

=item L<http://www.loc.gov/standards/marcxml/>

=item L<MARC::File::USMARC>

=item L<MARC::Batch>

=item L<MARC::Record>

=back

=head1 AUTHORS

=over 4 

=item * Ed Summers <ehs@pobox.com>

=back

=cut

1;

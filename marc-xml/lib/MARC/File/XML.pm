package MARC::File::XML;

use warnings;
use strict;
use vars qw( $VERSION %_load_args );
use base qw( MARC::File );
use MARC::Record;
use MARC::Field;
use MARC::File::SAX;
use XML::SAX qw(Namespaces Validation);

use MARC::Charset qw( marc8_to_utf8 utf8_to_marc8 );
use IO::File;
use Carp qw( croak );
use Encode ();

$VERSION = '0.86';

my $handler = MARC::File::SAX->new();

my $factory = XML::SAX::ParserFactory->new();
$factory->require_feature(Namespaces);

my $parser = $factory->parser( Handler => $handler, ProtocolEncoding => 'UTF-8' );

sub import {
	my $class = shift;
	%_load_args = @_;
	$_load_args{ DefaultEncoding } ||= 'UTF-8';
	$_load_args{ RecordFormat } ||= 'USMARC';

 	$parser = $factory->parser( Handler => $handler, ProtocolEncoding => $_load_args{DefaultEncoding} );
}

=head1 NAME

MARC::File::XML - Work with MARC data encoded as XML 

=head1 SYNOPSIS

    ## Loading with USE options
    use MARC::File::XML ( BinaryEncoding => 'utf8', RecordFormat => 'UNIMARC' );

    ## Setting the record format without USE options
    MARC::File::XML->default_record_format('USMARC');
    
    ## reading with MARC::Batch
    my $batch = MARC::Batch->new( 'XML', $filename );
    my $record = $batch->next();

    ## or reading with MARC::File::XML explicitly
    my $file = MARC::File::XML->in( $filename );
    my $record = $file->next();

    ## serialize a single MARC::Record object as XML
    print $record->as_xml();

    ## write a bunch of records to a file
    my $file = MARC::File::XML->out( 'myfile.xml' );
    $file->write( $record1 );
    $file->write( $record2 );
    $file->write( $record3 );
    $file->close();

    ## instead of writing to disk, get the xml directly 
    my $xml = join( "\n", 
        MARC::File::XML::header(),
        MARC::File::XML::record( $record1 ),
        MARC::File::XML::record( $record2 ),
        MARC::File::XML::footer()
    );

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

=head2 MARC::File::XML->default_record_format([$format])

Sets or returns the default record format used by MARC::File::XML.  Valid
formats are B<MARC21>, B<USMARC>, B<UNIMARC> and B<UNIMARCAUTH>.

    MARC::File::XML->default_record_format('UNIMARC');

=cut

sub default_record_format {
	my $self = shift;
	my $format = shift;

	$_load_args{RecordFormat} = $format if ($format);

	return $_load_args{RecordFormat};
}


=head2 as_xml()

Returns a MARC::Record object serialized in XML. You can pass an optional format
parameter to tell MARC::File::XML what type of record (USMARC, UNIMARC, UNIMARCAUTH) you are
serializing.

    print $record->as_xml([$format]);

=cut 

sub MARC::Record::as_xml {
    my $record = shift;
    my $format = shift || $_load_args{RecordFormat};
    return(  MARC::File::XML::encode( $record, $format ) );
}

=head2 as_xml_record([$format])

Returns a MARC::Record object serialized in XML without a collection wrapper.
You can pass an optional format parameter to tell MARC::File::XML what type of
record (USMARC, UNIMARC, UNIMARCAUTH) you are serializing.

    print $record->as_xml_record('UNIMARC');

=cut 

sub MARC::Record::as_xml_record {
    my $record = shift;
    my $format = shift || $_load_args{RecordFormat};
    return(  MARC::File::XML::encode( $record, $format, 1 ) );
}

=head2 new_from_xml([$encoding, $format])

If you have a chunk of XML and you want a record object for it you can use 
this method to generate a MARC::Record object.  You can pass an optional
encoding parameter to specify which encoding (UTF-8 or MARC-8) you would like
the resulting record to be in.  You can also pass a format parameter to specify
the source record type, such as UNIMARC, UNIMARCAUTH, USMARC or MARC21.

    my $record = MARC::Record->new_from_xml( $xml, $encoding, $format );

Note: only works for single record XML chunks.

=cut 

sub MARC::Record::new_from_xml {
    my $xml = shift;
    ## to allow calling as MARC::Record::new_from_xml()
    ## or MARC::Record->new_from_xml()
    $xml = shift if ( ref($xml) || ($xml eq "MARC::Record") );

    my $enc = shift || $_load_args{BinaryEncoding};
    my $format = shift || $_load_args{RecordFormat};
    return( MARC::File::XML::decode( $xml, $enc, $format ) );
}

=pod 

If you want to write records as XML to a file you can use out() with write()
to serialize more than one record as XML.

=head2 out()

A constructor for creating a MARC::File::XML object that can write XML to a
file. You must pass in the name of a file to write XML to.

    my $file = MARC::File::XML->out( $filename );

=cut

sub out {
    my ( $class, $filename ) = @_;
    my $fh = IO::File->new( ">$filename" ) or croak( $! );
    my %self = ( 
        filename    => $filename,
        fh          => $fh, 
        header      => 0
    );
    return( bless \%self, ref( $class ) || $class );
}

=head2 write()

Used in tandem with out() to write records to a file. 

    my $file = MARC::File::XML->out( $filename );
    $file->write( $record1 );
    $file->write( $record2 );

=cut

sub write {
    my ( $self, $record, $enc ) = @_;
    if ( ! $self->{ fh } ) { 
        croak( "MARC::File::XML object not open for writing" );
    }
    if ( ! $record ) { 
        croak( "must pass write() a MARC::Record object" );
    }
    ## print the XML header if we haven't already
    if ( ! $self->{ header } ) { 
    	$enc ||= $_load_args{DefaultEncoding};
        $self->{ fh }->print( header( $enc ) );
        $self->{ header } = 1;
    } 
    ## print out the record
    $self->{ fh }->print( record( $record ) ) || croak( $! );
    return( 1 );
}

=head2 close()

When writing records to disk the filehandle is automatically closed when you
the MARC::File::XML object goes out of scope. If you want to close it explicitly
use the close() method.

=cut

sub close {
    my $self = shift;
    if ( $self->{ fh } ) {
        $self->{ fh }->print( footer() ) if $self->{ header };
        $self->{ fh } = undef;
        $self->{ filename } = undef;
        $self->{ header } = undef;
    }
    return( 1 );
}

## makes sure that the XML file is closed off

sub DESTROY {
    shift->close();
}

=pod

If you want to generate batches of records as XML, but don't want to write to
disk you'll have to use header(), record() and footer() to generate the
different portions.  

    $xml = join( "\n",
        MARC::File::XML::header(),
        MARC::File::XML::record( $record1 ),
        MARC::File::XML::record( $record2 ),
        MARC::File::XML::record( $record3 ),
        MARC::File::XML::footer()
    );

=head2 header() 

Returns a string of XML to use as the header to your XML file.

=cut 

sub header {
    my $enc = shift; 
    $enc = shift if ( $enc && (ref($enc) || ($enc eq "MARC::File::XML")) );
    $enc ||= 'UTF-8';
    return( <<MARC_XML_HEADER );
<?xml version="1.0" encoding="$enc"?>
<collection
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
  xmlns="http://www.loc.gov/MARC21/slim">
MARC_XML_HEADER
}

=head2 footer()

Returns a string of XML to use at the end of your XML file.

=cut

sub footer {
    return( "</collection>" );
}

=head2 record()

Returns a chunk of XML suitable for placement between the header and the footer.

=cut

sub record {
    my $record = shift;
    my $format = shift;
    my $without_header = shift;
    my $enc = shift;

    $format ||= $_load_args{RecordFormat};

    my $_transcode = 0;
    my $ldr = $record->leader;
    my $original_charset;
    my $original_encoding = substr($ldr,9,1);

    # Does the record think it is already Unicode?
    if ($original_encoding ne 'a' && lc($format) ne 'unimarc') {
    	# If not, we'll make it so
        $_transcode++;
	
    	# XXX Need to generat a '066' field here, but I don't understand how yet.

	substr($ldr,9,1,'a');
	$record->leader( $ldr );
	if ( ($original_charset) = $record->field('066') ) {
		$record->delete_field( $original_charset );
	}
	
    }

    my @xml = ();

    if ($without_header) {
        push @xml, <<HEADER
<?xml version="1.0" encoding="$enc"?>
<record
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/ standards/marcxml/schema/MARC21slim.xsd"
  xmlns="http://www.loc.gov/MARC21/slim">
HEADER

    } else {
        push( @xml, "<record>" );
    }
    
    push( @xml, "  <leader>" . escape( $record->leader ) . "</leader>" );

    foreach my $field ( $record->fields() ) {
        my $tag = $field->tag();
        if ( $field->is_control_field() ) { 
	    my $data = $field->data;
            push( @xml, qq(  <controlfield tag="$tag">) .
                escape( ($_transcode ? marc8_to_utf8($data) : $data) ). qq(</controlfield>) );
        } else {
            my $i1 = $field->indicator( 1 );
            my $i2 = $field->indicator( 2 );
            push( @xml, qq(  <datafield tag="$tag" ind1="$i1" ind2="$i2">) );
            foreach my $subfield ( $field->subfields() ) { 
                my ( $code, $data ) = @$subfield;
                push( @xml, qq(    <subfield code="$code">).
                    escape( ($_transcode ? marc8_to_utf8($data) : $data) ).qq(</subfield>) );
            }
            push( @xml, "  </datafield>" );
        }
    }
    push( @xml, "</record>\n" );

    if ($_transcode) {
    	if (defined $original_charset) {
        	$record->insert_fields_ordered($original_charset);
	}
	substr($ldr,9,1,$original_encoding);
	$record->leader( $ldr );
    }

    return( join( "\n", @xml ) );
}

my %ESCAPES = (
    '&'     => '&amp;',
    '<'     => '&lt;',
    '>'     => '&gt;',
);
my $ESCAPE_REGEX = 
    eval 'qr/' . 
    join( '|', map { $_ = "\Q$_\E" } keys %ESCAPES ) .
    '/;'
    ;

sub escape {
    my $string = shift;
    return '' if ! defined $string or $string eq '';
    $string =~ s/($ESCAPE_REGEX)/$ESCAPES{$1}/oge;
    return( $string );
}

sub _next {
    my $self = shift;
    my $fh = $self->{ fh };

    ## return undef at the end of the file
    return if eof($fh);

    ## get a chunk of xml for a record
    local $/ = '</record>';
    my $xml = <$fh>;

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

    my $enc = shift || $_load_args{BinaryEncoding};
    my $format = shift || $_load_args{RecordFormat};

    $parser->{ tagStack } = [];
    $parser->{ subfields } = [];
    $parser->{ Handler }{ record } = MARC::Record->new();
    $parser->{ Handler }{ toMARC8 } = decideMARC8Binary($format,$enc);

    $parser->parse_string( $text );

    return( $parser->{ Handler }{ record } );
    
}

sub decideMARC8Binary {
	my $format = shift;
	my $enc = shift;

	return 0 if (defined($format) && lc($format) =~ /^unimarc/o);
	return 0 if (defined($enc) && lc($enc) =~ /^utf-?8/o);
	return 1;
}


=head2 encode()

You probably want to use the as_xml() method on your MARC::Record object
instead of calling this directly. But if you want to you just need to 
pass in the MARC::Record object you wish to encode as XML, and you will be
returned the XML as a scalar.

=cut

sub encode {
    my $record = shift;
    my $format = shift || $_load_args{RecordFormat};
    my $without_header = shift;
    my $enc = shift || $_load_args{DefaultEncoding};

    if (lc($format) =~ /^unimarc/o) {
        $enc = _unimarc_encoding( $format => $record );
    }

    my @xml = ();
    push( @xml, header( $enc ) ) unless ($without_header);
    push( @xml, record( $record, $format, $without_header, $enc ) );
    push( @xml, footer() ) unless ($without_header);

    return( join( "\n", @xml ) );
}

sub _unimarc_encoding {
	my $f = shift;
	my $r = shift;

	my $pos = 26;
	$pos = 13 if (lc($f) eq 'unimarcauth');

	my $enc = substr( $r->subfield(100 => 'a'), $pos, 2 );

	if ($enc eq '01' || $enc eq '03') {
		return 'ISO-8859-1';
	} elsif ($enc eq '50') {
		return 'UTF-8';
	} else {
		die "Unsupported UNIMARC charater encoding [$enc] for XML output";
	}
}

=head1 TODO

=over 4

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

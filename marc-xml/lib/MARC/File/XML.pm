package MARC::File::XML;

use strict;
use base qw( MARC::File );
use MARC::Record;
use MARC::File::SAX;

our $VERSION = '0.53';

my $handler = MARC::File::SAX->new();
my $parser = XML::SAX::ParserFactory->parser( Handler => $handler );

=head1 NAME

MARC::File::XML - Work with MARC data encoded as XML 

=head1 SYNOPSIS

    my $batch = MARC::Batch->new( 'XML', $filename );
    my $record = $batch->next();

    my $file = MARC::File::XML::in( $filename );
    my $record = $file->next();

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

=cut

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
you should pass in a MARC::Record as the first argument, and a chunk of XML 
text as the second.

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

sub encode {
    # not implemented yet
    # interested? let me know ehs@pobox.com
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

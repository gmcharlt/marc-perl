package MARC::Batch;

=head1 NAME

MARC::Batch - Perl module for handling files of MARC::Record objects

=cut

use strict;
use integer;
eval 'use warnings' if $] >= 5.006;

=head1 VERSION

Version 1.11

    $Id: Batch.pm,v 1.16 2002/09/12 16:25:53 edsummers Exp $

=cut

use vars '$VERSION'; $VERSION = '1.11';

=head1 SYNOPSIS

MARC::Batch hides all the file handling of files of C<MARC::Record>s.
C<MARC::Record> still does the file I/O, but C<MARC::Batch> handles the
multiple-file aspects.

    use MARC::Batch;

    my $batch = new MARC::Batch( 'USMARC', @files );
    while ( my $marc = $batch->next ) {
	print $marc->subfield(245,"a"), "\n";
    }

=head1 EXPORT

None.  Everything is a class method.

=head1 METHODS

=head2 new( $type, @files )

Create a C<MARC::Batch> object that will process C<@files>.

C<$type> must be either "USMARC" or "MicroLIF".  If you want to specify 
"MARC::File::USMARC" or "MARC::File::MicroLIF", that's OK, too.

=cut

sub new {
    my $class = shift;
    my $type = shift;

    my $marcclass = ($type =~ /^MARC::File/) ? $type : "MARC::File::$type";

    eval "require $marcclass";
    die $@ if $@;

    my @files = @_;

    my $self = {
	filelist =>	[@files],
	filestack =>	[@files],
	filename =>	undef,
	marcclass =>	$marcclass,
	file =>		undef,
	_warnings =>	[],
    };

    bless $self, $class;

    return $self;
} # new()


=head2 next()

Read the next record from the files.  If the current file is at EOF, close
it and open the next one.

=cut

sub next {
    my $self = shift;

    if ( $self->{file} ) {

	# get the next record
	my $rec = $self->{file}->next();

	# collect warnings from MARC::File::* object
	my @warnings = $self->{file}->warnings();
	push(@{ $self->{_warnings} }, @warnings ) if @warnings;

	if ($rec) {

	    # collect warnings from the MARC::Record object
	    my @warnings = $rec->warnings();
	    push(@{ $self->{_warnings} }, @warnings ) if @warnings;

	    # return the MARC::Record object
	    return($rec);

	}

    }

    # Get the next file off the stack, if there is one
    $self->{filename} = shift @{$self->{filestack}} or return undef;

    # Instantiate a filename for it
    my $marcclass = $self->{marcclass};
    $self->{file} = $marcclass->in( $self->{filename} ) or return undef;

    # call this method again now that we've got a file open
    return( $self->next() );

}

=head2 filename()

Returns the currently open filename

=cut

sub filename {
    my $self = shift;

    return $self->{filename};
}

=head2 warnings() 

Returns a list of warnings that have accumulated while processing a particular 
batch file. As a side effect the warning buffer will be cleared.

    my @warnings = $batch->warnings();

=cut

sub warnings {
    my $self = shift;
    my @warnings = @{ $self->{_warnings} };
    $self->{_warnings} = [];
    return(@warnings);
}


1;

__END__

=head1 RELATED MODULES

L<MARC::Record>, L<MARC::Lint>

=head1 TODO

None yet.  Send me your ideas and needs.

=head1 LICENSE

This code may be distributed under the same terms as Perl itself. 

Please note that these modules are not products of or supported by the
employers of the various contributors to the code.

=head1 AUTHOR

Andy Lester, E<lt>marc@petdance.comE<gt> or E<lt>alester@flr.follett.comE<gt>

=cut


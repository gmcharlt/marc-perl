package MARC::Batch;

=head1 NAME

MARC::Batch - Perl module for handling files of MARC::Record objects

=cut

use 5.6.0;
use strict;
use integer;

=head1 VERSION

Version 0.94

    $Id: Batch.pm,v 1.7 2002/06/11 18:45:16 petdance Exp $

=cut

our $VERSION = '0.94';

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

=head2 new( $type, [@files] )

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

    # If we have an open file, just use it and go.
    if ( $self->{file} ) {
	my $rec = $self->{file}->next();
	return $rec if $rec;
    }

    $self->{file} = undef;

    # Get the next file off the stack, if there is one
    $self->{filename} = shift @{$self->{filestack}} or return undef;

    # Instantiate a filename for it
    my $marcclass = $self->{marcclass};
    $self->{file} = $marcclass->in( $self->{filename} ) or return undef;

    return $self->{file}->next();
}

=head2 filename()

Returns the currently open filename

=cut

sub filename {
    my $self = shift;

    return $self->{filename};
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


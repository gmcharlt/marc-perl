package MARC::Batch;

=head1 NAME

MARC::Batch - Perl module for handling files of MARC::Record objects

=cut

use 5.6.0;
use strict;
use integer;

use MARC::File;

=head1 VERSION

Version 0.90

    $Id: Batch.pm,v 1.2 2002/04/01 20:34:24 petdance Exp $

=cut

our $VERSION = '0.90';

1;

# EVerything below is in flux until I figure out the file handling stuff

__DATA__

=head1 SYNOPSIS

MARC::Batch hides all the file handling of files of C<MARC::Record>s.
C<MARC::Record> still does the file I/O, but C<MARC::Batch> handles the
multiple-file aspects.

    use MARC::Batch;

    my $batch = new MARC::Batch( @files );
    while ( my $marc = $batch->next ) {
	print $marc->subfield(245,"a"), "\n";
    }

=head1 EXPORT

None.  Everything is a class method.

=head1 METHODS

=head2 new( [@files] )

Create a C<MARC::Batch> object that will process C<@files>.

=cut

sub new {
    my $class = shift;
    my @files = @_;

    my $self = {
	files =>	[@files],
	filestack =>	[@files],
	currfile =>	undef
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

    my $file = $self->_file or return undef;

    return $self->{file}->next();
}

=for internal

Opens the next file if necessary 

=cut

sub _fh {
    my $self = shift;

    my $fh = $self->{fh};

    if ( !$fh || eof($fh) ) {
	close $fh if $fh;

	my $nextfile = $self->{currfile} = shift @{$self->{filestack}} or return undef;
	open( $fh, "<", $nextfile ) or die "Can't open $nextfile: $!";
    }

    return ($self->{fh} = $fh);
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


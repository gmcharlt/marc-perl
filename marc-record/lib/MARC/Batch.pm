package MARC::Batch;

=head1 NAME

MARC::Batch - Perl module for handling files of MARC::Record objects

=cut

use strict;
use integer;
eval 'use warnings' if $] >= 5.006;

use constant STRICT_ON		=> 1;
use constant STRICT_OFF		=> 2;
use constant WARNINGS_ON	=> 1;
use constant WARNINGS_OFF	=> 2;

=head1 VERSION

Version 1.17

    $Id: Batch.pm,v 1.24 2003/01/29 18:16:06 petdance Exp $

=cut

use vars '$VERSION'; $VERSION = '1.17';

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
"MARC::File::USMARC" or "MARC::File::MicroLIF", that's OK, too. new() returns a
new MARC::Batch object.

=cut

sub new {
    my $class = shift;
    my $type = shift;

    my $marcclass = ($type =~ /^MARC::File/) ? $type : "MARC::File::$type";

    eval "require $marcclass";
    die $@ if $@;

    my @files = @_;

    my $self = {
	filelist    =>	[@files],
	filestack   =>	[@files],
	filename    =>	undef,
	marcclass   =>	$marcclass,
	file	    =>  undef,
	warnings    =>  [],
	warn	    =>  WARNINGS_ON,
	strict	    =>  STRICT_ON,
    };

    bless $self, $class;

    return $self;
} # new()


=head2 next()

Read the next record from that batch, and return it as a MARC::Record object.  
If the current file is at EOF, close it and open the next one. next() will 
return C<undef> when there is no more data to be read from any batch files.

By default, next() also will return C<undef> if an error is encountered while
reading from the batch. If not checked for this can cause your iteration to
terminate prematurely. To alter this behavior see strict_off(). You can 
retrieve warning messages using the warnings() method.

=cut

sub next {
    my $self = shift;

    if ( $self->{file} ) {
    
	# get the next record
	my $rec = $self->{file}->next();

	# collect warnings from MARC::File::* object
	my @warnings = $self->{file}->warnings();
	if ( @warnings ) {
	    $self->warnings( @warnings );
	    return( undef ) if $self->{ strict } == STRICT_ON; 
	}

	if ($rec) {

	    # collect warnings from the MARC::Record object
	    my @warnings = $rec->warnings();

	    if (@warnings) {
		$self->warnings( @warnings );
		return( undef ) if $self->{ strict } == STRICT_ON;
	    }

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

=head2 strict_off()

If you would like MARC::Batch to continue after it has encountered what 
it believes to be bad MARC data then use this method to turn strict B<OFF>.
A call to strict_off() always returns true (1).

strict_off() can be handy when you don't care about the quality of your MARC
data, and just want to plow through it. For safety MARC::Batch strict is B<ON> 
by default. 

=cut

sub strict_off {
    my $self = shift;
    $self->{ strict } = STRICT_OFF;
    return(1);
}

=head2 strict_on()

The opposite of strict_off(), and the default state. You shouldn't have to use
this method unless you've previously used strict_off(), and want it back on
again.  When strict is B<ON> calls to next() will return undef when an error is
encountered while reading MARC data. strict_on() always returns true (1).

=cut

sub strict_on {
    my $self = shift;
    $self->{ strict } = STRICT_ON;
    return(1);
}

=head2 warnings() 

Returns a list of warnings that have accumulated while processing a particular 
batch file. As a side effect the warning buffer will be cleared. 

    my @warnings = $batch->warnings();

This method is also used internally to set warnings, so you probably don't
want to be passing in anything as this will set warnings on your batch object.

warnings() will return the empty list when there are no warnings.

=cut

sub warnings {
    my ($self,@new) = @_;
    if ( @new ) {
	push( @{ $self->{warnings} }, @new );
	print STDERR join( "\n", @new ) if $self->{ warn } == WARNINGS_ON;
    } else {
	my @old = @{ $self->{warnings} };
	$self->{warnings} = [];
	return(@old);
    }
}


=head2 warnings_off() 

Turns off the default behavior of printing warnings to STDERR. However, even
with warnings off the messages can still be retrieved using the warnings() 
method if you wish to check for them.

warnings_off() always returns true (1).

=cut

sub warnings_off {
    my $self = shift;
    $self->{ warn } = WARNINGS_OFF;
}

=head2 warnings_on()

Turns on warnings so that diagnostic information is printed to STDERR. This 
is on by default so you shouldn't have to use it unless you've previously
turned off warnings using warnings_off(). 

warnings_on() always returns true (1).

=cut 

sub warnings_on {
    my $self = shift;
    $self->{ warn } = WARNINGS_ON;
}

=head2 filename()

Returns the currently open filename or C<undef> if there is not currently a file
open on this batch object.

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


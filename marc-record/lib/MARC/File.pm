package MARC::File;

=head1 NAME

MARC::File - Base class for files of MARC records

=cut

use strict;
use integer;
eval 'use warnings' if $] >= 5.006;

use vars qw( $ERROR );

=head1 VERSION

Version 1.00

    $Id: File.pm,v 1.17 2002/08/30 22:32:06 edsummers Exp $

=cut

use vars '$VERSION'; $VERSION = '1.00';

=head1 SYNOPSIS

    use MARC::File::USMARC;

    my $file = MARC::File::USMARC->in( $filename );
    
    while ( my $marc = $file->next() ) {
	# Do something
    }
    $file->close();
    undef $file;

=head1 EXPORT

None.  

=head1 METHODS

=head2 in()

Opens a file for input.

=cut

sub in {
    my $class = shift;
    my $filename = shift;

    my $self = {
	filename => $filename,
	_warnings => [],
    };

    bless $self, $class;

    my $fh = eval { local *FH; open( FH, $filename ) or die; *FH{IO}; };

    if ( $@ ) {
	undef $self;
	$MARC::File::ERROR = "Couldn't open $filename: $@";
    } else {
	$self->{fh} = $fh;
    }
	

    return $self;
} # new()

sub out {
    die "Not yet written";
}

=head2 next()

Reads the next record from the file handle passed in. 

=cut

sub next {
    my $self = shift;
    my $rec = $self->_next();
    return $rec ? $self->decode($rec) : undef;
}

=head2 skip()

Skips over the next record in the file.  Same as C<next()>,
without the overhead of parsing a record you're going to throw away
anyway.

Returns 1 or undef.

=cut

sub skip {
    my $self = shift;

    my $rec = $self->_next();

    return $rec ? 1 : undef;
}

=head2 warnings()

Simlilar to MARC::Record and MARC::Batch, warnings() will return any 
warnings that have accumulated while processing this file; and as a 
side-effect will clear the warnings buffer.

=cut 

sub warnings {
    my $self = shift;
    my @warnings = @{ $self->{_warnings} };
    $self->{_warnings} = [];
    return(@warnings);
}

sub close {
    my $self = shift;

    close( $self->{fh} );
    delete $self->{fh};
    delete $self->{filename};

    return;
}

sub _unimplemented() {
    my $self = shift;
    my $method = shift;

    warn "Method $method must be overridden";
}

sub write   { $_[0]->_unimplemented("write"); }
sub decode  { $_[0]->_unimplemented("decode"); }

# NOTE: _warn must be called as an object method

sub _warn {
    my ($self,$warning) = @_;
    push( @{ $self->{_warnings} }, $warning );
    return(undef);
}

# NOTE: _gripe can be called as an object method, or not.  Your choice.
sub _gripe(@) {
    my @parms = @_;
    if ( @parms ) {
	my $self = shift @parms;

	if ( ref($self) =~ /^MARC::File/ ) {
	    push( @parms, " at byte ", tell($self->{fh}) ) if $self->{fh};
	    push( @parms, " in file ", $self->{filename} ) if $self->{filename};
	} else {
	    unshift( @parms, $self );
	}

	$ERROR = join( "", @parms );
	warn $ERROR;
    }

    return(undef);
}

1;

__END__

=head1 RELATED MODULES

L<MARC::Record>

=head1 TODO

=over 4

=item * C<out()> method

We only handle files for input right now.

=back

=cut

=head1 LICENSE

This code may be distributed under the same terms as Perl itself. 

Please note that these modules are not products of or supported by the
employers of the various contributors to the code.

=head1 AUTHOR

Andy Lester, E<lt>marc@petdance.comE<gt> or E<lt>alester@flr.follett.comE<gt>

=cut


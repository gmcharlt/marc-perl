package MARC::Field;

use 5.6.0;
use strict;
use integer;

use constant SUBFIELD_INDICATOR => "\x1F";
use constant END_OF_FIELD       => "\x1E";

use vars qw( $ERROR );

=head1 NAME

MARC::Field - Perl extension for handling MARC fields

=head1 VERSION

Version 1.00

    $Id: Field.pm,v 1.12 2002/07/03 20:17:14 petdance Exp $

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

  use MARC::Field;

  my $field = 
  	MARC::Field->new( 
		245, '1', '0',
			'a' => 'Raccoons and ripe corn / ',
			'c' => 'Jim Arnosky.'
		);
  $field->add_subfields( "a", "1st ed." );

=head1 DESCRIPTION

Defines MARC fields for use in the MARC::Record module.  I suppose
you could use them on their own, but that wouldn't be very interesting.

=head1 EXPORT

None by default.  Any errors are stored in C<$MARC::Field::ERROR>, which
C<$MARC::Record> usually bubbles up to C<$MARC::Record::ERROR>.

=head1 METHODS

=head2 C<new(tag,indicator1,indicator2,code,data[,code,data...])>

  my $record = 
  	MARC::Field->new( 
		245, '1', '0',
			'a' => 'Raccoons and ripe corn / ',
			'c' => 'Jim Arnosky.'
		);

=cut

sub new($) {
	my $class = shift;
	$class = ref($class) || $class;

	my $tagno = shift;
	($tagno =~ /^\d\d\d$/)
		or return _gripe( "Tag \"$tagno\" is not a valid tag number." );

	my $self = bless {
		_tag => $tagno,
		_warnings => [],
		}, $class;
	
	if ( $tagno < 10 ) { 
		$self->{_data} = shift;
	} else {
		for my $indcode ( qw( _ind1 _ind2 ) ) {
			my $indicator = shift;
			if ( $indicator !~ /^[0-9 ]$/ ) {
				$self->_warn( "Invalid indicator \"$indicator\" forced to blank" ) unless ($indicator eq "");
				$indicator = " ";
			}
			$self->{$indcode} = $indicator;
		} # for
		
		(@_ >= 2)
			or return _gripe( "Field $tagno must have at least one subfield" );

		# Normally, we go thru add_subfields(), but internally we can cheat
		$self->{_subfields} = [@_];
	}

	return $self;
} # new()

=head2 C<clone()>

Makes a copy of the field.  Note that this is not just the same as saying

    my $newfield = $field;

since that just makes a copy of the reference.  To get a new object, you must

    my $newfield = $field->clone;

=cut

sub clone {
    my $self = shift;

    my $tagno = $self->tag;

    my $clone = 
	bless {
	    _tag => $tagno,
	    _warnings => [],
	}, ref($self);

    if ( $tagno < 10 ) {
	$clone->{_data} = $self->{_data};
    } else {
	$clone->{_ind1} = $self->{_ind1};
	$clone->{_ind2} = $self->{_ind2};
	$clone->{_subfields} = [@{$self->{_subfields}}]; 
    }

    return $clone;
}

=head2 C<update()>

Allows you to change the values of the field. You can update indicators
and subfields like this:

  $field->update( ind2 => '4', a => 'The ballad of Abe Lincoln');

The amount of items modified will be returned to you as a result of the
method call.

Note: when doing subfield updates be aware that C<update()> will only 
update the first occurrence. If you need to do anything more complicated
you need to create a new field and use C<replace_with()>. 

=cut

sub update {

  my $self = shift;
  my @data = @{$self->{_subfields}}; 
  my $changes = 0;

  while ( @_ ) {
    my $arg = shift;
    my $val = shift;

    ## indicator update
    if ($arg =~ /^ind[12]$/) {
      $self->{"_$arg"} = $val;
      $changes++;
    }
    ## subfield update
    else {
      for (my $i=0; $i<@data; $i=$i+2) {
	if ($data[$i] eq $arg) {
	  $data[$i+1] = $val;
	  $changes++;
	  last;
	}
      }
    }

  }

  ## synchronize our subfields 
  $self->{_subfields} = \@data;
  return($changes);

}

=head2 C<replace_with()> 

Allows you to replace an existing field with a new one. You need to pass 
C<replace()> a MARC::Field object to replace the existing field with. For 
example:

  $field = $record->field('245');
  my $new_field = new MARC::Field('245','0','4','The ballad of Abe Lincoln.');
  $field->replace_with($new_field);

=cut 

sub replace_with {

  my ($self,$new) = @_;
  ref($new) =~ /^MARC::Field$/ 
    or return _gripe("Must pass a MARC::Field object");

  %$self = %$new;
    
}


=head2 C<tag()>

Returns the three digit tag for the field.

=cut

sub tag {
	my $self = shift;
	return $self->{_tag};
}

=head2 C<indicator(indno)>

Returns the specified indicator.  Returns C<undef> and sets 
C<$MARC::Field::ERROR> if the I<indno> is not 1 or 2, or if 
the tag doesn't have indicators.

=cut

sub indicator($) {
	my $self = shift;
	my $indno = shift;

	($self->tag >= 10)
		or return _gripe( "Fields below 010 do not have indicators" );

	if ( $indno == 1 ) {
		return $self->{_ind1};
	} elsif ( $indno == 2 ) {
		return $self->{_ind2};
	} else {
		return _gripe( "Indicator number must be 1 or 2" );
	}
}



=head2 C<subfield(code)>

Returns the text from the first subfield matching the subfield code.
If no matching subfields are found, C<undef> is returned.

If the tag is less than an 010, C<undef> is returned and
C<$MARC::Field::ERROR> is set.

=cut

sub subfield {
	my $self = shift;
	my $code_wanted = shift;

	($self->tag >= 10)
		or return _gripe( "Fields below 010 do not have subfields" );

	my @data = @{$self->{_subfields}};
	while ( defined( my $code = shift @data ) ) {
		return shift @data if ( $code eq $code_wanted );
		shift @data;
	}

	return undef;
}

=head2 C<subfields()>

Returns all the subfields in the field.  What's returned is a list of 
lists, where the inner list is a subfield code and the subfield data. 

For example, this might be the subfields from a 245 field:

	[
	  [ 'a', 'Perl in a nutshell :' ],
	  [ 'b', 'A desktop quick reference.' ],
	]

=cut

sub subfields {
	my $self = shift;

	($self->tag >= 10)
		or return _gripe( "Fields below 010 do not have subfields" );

	my @list;
	my @data = @{$self->{_subfields}};
	while ( defined( my $code = shift @data ) ) {
		push( @list, [$code, shift @data] );
	}
	return @list;
}

sub _gripe(@) {
	$ERROR = join( "", @_ );

	warn $ERROR;

	return undef;
}

=head2 C<data()>

Returns the data part of the field, if the tag number is less than 10.

=cut

sub data($) {
	my $self = shift;

	($self->{_tag} < 10)
		or return _gripe( "data() is only for tags less than 10" );
		
	my $data = shift;
	$self->{_data} = $data if defined( $data );

	return $self->{_data};
}

=head2 C<add_subfields(code,text[,code,text ...])>

Adds subfields to the end of the subfield list.

Returns the number of subfields added, or C<undef> if there was an error.

=cut

sub add_subfields(@) {
	my $self = shift;

	($self->{_tag} >= 10)
		or return _gripe( "Subfields are only for tags >= 10" );

	push( @{$self->{_subfields}}, @_ );
	return @_/2;
}

=head2 C<as_string()>

Returns a string of all subfields run together, without the tag number.

=cut

sub as_string() {
	my $self = shift;

	return $self->{_data} if $self->tag < 10;

	my @subs;

	my @subdata = @{$self->{_subfields}};
	while ( @subdata ) {
		my $code = shift @subdata;
		my $text = shift @subdata;
		push( @subs, $text );
	} # for

	return join( " ", @subs );
}


=head2 C<as_formatted()>

Returns a pretty string for printing in a MARC dump.

=cut

sub as_formatted() {
	my $self = shift;

	my @lines;

	if ( $self->tag < 10 ) {
		push( @lines, sprintf( "%03d     %s", $self->{_tag}, $self->{_data} ) );
	} else {
		my $hanger = sprintf( "%03d %1.1s%1.1s", $self->{_tag}, $self->{_ind1}, $self->{_ind2} );

		my @subdata = @{$self->{_subfields}};
		while ( @subdata ) {
			my $code = shift @subdata;
			my $text = shift @subdata;
			push( @lines, sprintf( "%-6.6s _%1.1s%s", $hanger, $code, $text ) );
			$hanger = "";
		} # for
	}



	return join( "\n", @lines );
}


=head2 C<as_usmarc()>

Returns a string for putting into a USMARC file.  It's really only
useful by C<MARC::Record::as_usmarc()>.

=cut

sub as_usmarc() {
	my $self = shift;

	# Tags < 010 are pretty easy
	if ( $self->tag < 10 ) {
		return $self->data . END_OF_FIELD;
	} else {
		my @subs;
		my @subdata = @{$self->{_subfields}};
		while ( @subdata ) {
			push( @subs, join( "", SUBFIELD_INDICATOR, shift @subdata, shift @subdata ) );
		} # while

		return join( "", 
			$self->indicator(1),
			$self->indicator(2),
			@subs,
			END_OF_FIELD,
			);
	}
}

=head2 C<warnings()>

Returns the warnings that were created when the record was read.
These are things like "Invalid indicators converted to blanks".

The warnings are items that you might be interested in, or might
not.  It depends on how stringently you're checking data.  If
you're doing some grunt data analysis, you probably don't care.

=cut

sub warnings() {
	my $self = shift;

	return @{$self->{_warnings}};
}

# NOTE: _warn is an object method
sub _warn($) {
	my $self = shift;

	push( @{$self->{_warnings}}, join( "", @_ ) );
}

1;

__END__

=head1 SEE ALSO

See the "SEE ALSO" section for L<MARC::Record>.

=head1 TODO

See the "TODO" section for L<MARC::Record>.

=cut

=head1 LICENSE

This code may be distributed under the same terms as Perl itself. 

Please note that these modules are not products of or supported by the
employers of the various contributors to the code.

=head1 AUTHOR

Andy Lester, E<lt>marc@petdance.comE<gt> or E<lt>alester@flr.follett.comE<gt>

=cut

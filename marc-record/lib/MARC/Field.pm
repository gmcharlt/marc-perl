package MARC::Field;

use strict;
use integer;
use Carp;

use constant SUBFIELD_INDICATOR => "\x1F";
use constant END_OF_FIELD       => "\x1E";

use vars qw( $ERROR );

=head1 NAME

MARC::Field - Perl extension for handling MARC fields

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

=head2 new(tag,indicator1,indicator2,code,data[,code,data...])

  my $record = 
  	MARC::Field->new( 
		245, '1', '0',
			'a' => 'Raccoons and ripe corn / ',
			'c' => 'Jim Arnosky.'
		);

Returns a MARC::Field record.

=cut

sub new($) {
	my $class = shift;
	$class = ref($class) || $class;

	## MARC spec indicates that tags can have alphabetical 
	## characters in them! If they do appear we assume that 
	## they have indicators like tags > 010
	my $tagno = shift;
	($tagno =~ /^[0-9A-Za-z]{3}$/)
		or croak( "Tag \"$tagno\" is not a valid tag." );

	my $self = bless {
		_tag => $tagno,
		_warnings => [],
		}, $class;
	
	if ( $self->is_control_tag() ) {
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
			or croak( "Field $tagno must have at least one subfield" );

		# Normally, we go thru add_subfields(), but internally we can cheat
		$self->{_subfields} = [@_];
	}

	return $self;
} # new()


=head2 tag()

Returns the three digit tag for the field.

=cut

sub tag {
	my $self = shift;
	return $self->{_tag};
}

=head2 indicator(indno)

Returns the specified indicator.  Returns C<undef> and sets 
C<$MARC::Field::ERROR> if the I<indno> is not 1 or 2, or if 
the tag doesn't have indicators.

=cut

sub indicator($) {
	my $self = shift;
	my $indno = shift;

	croak( "Fields below 010 do not have indicators" )
	    if $self->is_control_tag(); 

	if ( $indno == 1 ) {
		return $self->{_ind1};
	} elsif ( $indno == 2 ) {
		return $self->{_ind2};
	} else {
		croak( "Indicator number must be 1 or 2" );
	}
}

=head2 subfield(code)

Returns the text from the first subfield matching the subfield code.
If no matching subfields are found, C<undef> is returned.

If the tag is less than an 010, C<undef> is returned and
C<$MARC::Field::ERROR> is set.

    my $subA = $field->subfield('a');

=cut

sub subfield {
	my $self = shift;
	my $code_wanted = shift;

	croak( "Fields below 010 do not have subfields" )
	    if $self->is_control_tag();

	my @data = @{$self->{_subfields}};
	while ( defined( my $code = shift @data ) ) {
		return shift @data if ( $code eq $code_wanted );
		shift @data;
	}

	return;
}

=head2 subfields()

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

	croak( "Fields below 010 do not have subfields" )
	    if $self->is_control_tag();

	my @list;
	my @data = @{$self->{_subfields}};
	while ( defined( my $code = shift @data ) ) {
		push( @list, [$code, shift @data] );
	}
	return @list;
}

=head2 data()

Returns the data part of the field, if the tag number is less than 10.

=cut

sub data($) {
	my $self = shift;

	croak( "data() is only for tags less than 010" )
	    unless $self->is_control_tag();
		
	$self->{_data} = $_[0] if @_;

	return $self->{_data};
}

=head2 add_subfields(code,text[,code,text ...])

Adds subfields to the end of the subfield list.

    $field->add_subfields( 'c' => '1985' );

Returns the number of subfields added, or C<undef> if there was an error.

=cut

sub add_subfields(@) {
	my $self = shift;

	croak( "Subfields are only for tags >= 10" )
	    if $self->is_control_tag();

	push( @{$self->{_subfields}}, @_ );
	return @_/2;
}



=head2 update()

Allows you to change the values of the field. You can update indicators
and subfields like this:

  $field->update( ind2 => '4', a => 'The ballad of Abe Lincoln');

If you attempt to update a subfield which does not currently exist in the field,
then a new subfield will be appended to the field. If you don't like this
auto-vivification you must check for the existence of the subfield prior to
update.

  if ( $field->subfield( 'a' ) ) {
    $field->update( 'a' => 'Cryptonomicon' );
  }

If you want to update a field that has no indicators or subfields (000-009)
just call update() with one argument, the string that you would like to 
set the field to. 

  $field = $record->field( '003' );
  $field->update('IMchF');

Note: when doing subfield updates be aware that C<update()> will only 
update the first occurrence. If you need to do anything more complicated
you will probably need to create a new field and use C<replace_with()>. 

Returns the number of items modified.

=cut

sub update {

  my $self = shift;

  ## tags 000 - 009 don't have indicators or subfields
  if ( $self->is_control_tag() ) {
    $self->{_data} = shift;
    return(1);
  }
  
  ## otherwise we need to update subfields and indicators
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
      my $found = 0;
      ## update existing subfield
      for (my $i=0; $i<@data; $i=$i+2) {
	if ($data[$i] eq $arg) {
	  $data[$i+1] = $val;
	  $found = 1;
	  $changes++;
	  last;
	}
      }
      ## append new subfield
      if ( !$found ) { 
	push( @data, $arg, $val );
	$changes++;
      }
    }

  }

  ## synchronize our subfields 
  $self->{_subfields} = \@data;
  return($changes);

}

=head2 replace_with() 

Allows you to replace an existing field with a new one. You need to pass 
C<replace()> a MARC::Field object to replace the existing field with. For 
example:

  $field = $record->field('245');
  my $new_field = new MARC::Field('245','0','4','The ballad of Abe Lincoln.');
  $field->replace_with($new_field);

Doesn't return a meaningful or reliable value.

=cut 

sub replace_with {

  my ($self,$new) = @_;
  ref($new) =~ /^MARC::Field$/ 
    or croak("Must pass a MARC::Field object");

  %$self = %$new;
    
}


=head2 as_string( [$subfields] )

Returns a string of all subfields run together.  A space is added to
the result between each subfield.  The tag number and subfield 
character are not included.

Subfields appear in the output string in the order in which they
occur in the field. 

If C<$subfields> is specified, then only those subfields will be included.

  my $field = MARC::Field->new( 
		245, '1', '0',
			'a' => 'Abraham Lincoln',
			'h' => '[videorecording] :',
			'b' => 'preserving the union /',
			'c' => 'A&E Home Video.'
		);
  print $field->as_string( 'abh' ); # Only those three subfields
  # prints 'Abraham Lincoln [videorecording] : preserving the union /'.

Note that subfield h comes before subfield b in the output.

=cut

sub as_string() {
	my $self = shift;
	my $subfields = shift;

	if ( $self->is_control_tag() ) {
	    return $self->{_data};
	}

	my @subs;

	my @subdata = @{$self->{_subfields}};
	while ( @subdata ) {
		my $code = shift @subdata;
		my $text = shift @subdata;
		push( @subs, $text ) if !$subfields || $code =~ /^[$subfields]$/;
	} # for

	return join( " ", @subs );
}


=head2 as_formatted()

Returns a pretty string for printing in a MARC dump.

=cut

sub as_formatted() {
	my $self = shift;

	my @lines;

	if ( $self->is_control_tag() ) {
		push( @lines, sprintf( "%03s     %s", $self->{_tag}, $self->{_data} ) );
	} else {
		my $hanger = sprintf( "%03s %1.1s%1.1s", $self->{_tag}, $self->{_ind1}, $self->{_ind2} );

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


=head2 as_usmarc()

Returns a string for putting into a USMARC file.  It's really only
useful by C<MARC::Record::as_usmarc()>.

=cut

sub as_usmarc() {
	my $self = shift;

	# Tags < 010 are pretty easy
	if ( $self->is_control_tag() ) {
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

=head2 clone()

Makes a copy of the field.  Note that this is not just the same as saying

    my $newfield = $field;

since that just makes a copy of the reference.  To get a new object, you must

    my $newfield = $field->clone;

Returns a MARC::Field record.

=cut

sub clone {
    my $self = shift;

    my $tagno = $self->{_tag};

    my $clone = 
	bless {
	    _tag => $tagno,
	    _warnings => [],
	}, ref($self);

    if ( $self->is_control_tag() ) {
	$clone->{_data} = $self->{_data};
    } else {
	$clone->{_ind1} = $self->{_ind1};
	$clone->{_ind2} = $self->{_ind2};
	$clone->{_subfields} = [@{$self->{_subfields}}]; 
    }

    return $clone;
}
=head2 warnings()

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

sub is_control_tag {
    my $self = shift;
    return ($self->{_tag} =~ /^\d+$/) && ($self->{_tag} < 10);
}

sub _gripe(@) {
	$ERROR = join( "", @_ );

	warn $ERROR;

	return;
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

Andy Lester, E<lt>marc@petdance.comE<gt>

=cut

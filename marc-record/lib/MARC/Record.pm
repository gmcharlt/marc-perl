package MARC::Record;

=head1 NAME

MARC::Record - Perl extension for handling MARC records

=cut

use strict;
use integer;
eval 'use warnings' if $] >= 5.006;

use vars qw( $ERROR );

use MARC::Field;
use Carp qw(croak);

=head1 VERSION

Version 1.16

    $Id: Record.pm,v 1.44 2003/01/29 17:06:53 petdance Exp $

=cut

use vars '$VERSION'; $VERSION = '1.16';

use Exporter;
use vars qw( @ISA @EXPORTS @EXPORT_OK );
@ISA = qw( Exporter );
@EXPORTS = qw();
@EXPORT_OK = qw( LEADER_LEN );

use vars qw( $DEBUG ); $DEBUG = 0;

use constant LEADER_LEN	=> 24;

=head1 DESCRIPTION

Module for handling MARC records as objects.  The file-handling stuff is
in MARC::File::*.

=head1 EXPORT

None.  

=head1 ERROR HANDLING

Any errors generated are stored in C<$MARC::Record::ERROR>. 
Warnings are kept with the record and accessible in the C<warnings()> method. 

=head1 CONSTRUCTORS

=head2 new()

Base constructor for the class.  It just returns a completely empty record.
To get real data, you'll need to populate it with fields, or use one of
the MARC::File::* modules to read from a file.

=cut

sub new {
    my $class = shift;
    $class = ref($class) || $class; # Handle cloning
    my $self = {
	_leader => ' ' x 24,
	_fields => [],
	_warnings => [],
    };
    return bless $self, $class;
} # new()

=head2 new_from_usmarc( $marcblob )

This is a wrapper around C<MARC::File::USMARC::decode()> for compatibility with
older versions of MARC::Record.

=cut

sub new_from_usmarc {
    my $blob = shift;
    $blob = shift if (ref($blob) || ($blob eq "MARC::Record"));

    require MARC::File::USMARC;

    return MARC::File::USMARC::decode( $blob );
}

=head1 COMMON FIELD RETRIEVAL METHODS

Following are a number of convenience methods for commonly-retrieved
data fields.  Please note that they each return strings, not MARC::Field
objects.  They return empty strings if the appropriate field or subfield
is not found.  This is as opposed to the field()/subfield() methods
which return C<undef> if something's not found.  My assumption is that
these methods are used for quick & dirty reports and you don't want to
mess around with noting if something is undef.

Also note that no punctuation cleanup is done.  If the 245a is
"Programming Perl / ", then that's what you'll get back, rather than
"Programming Perl".

=head2 title()

Returns the title from the 245 tag.

=cut

sub title() {
    my $self = shift;

    my $field = $self->field(245);
    return $field ? $field->as_string : "";
}

=head2 title_proper()

Returns the title proper from the 245 tag, subfields a, n and p.

=cut

sub title_proper() {
    my $self = shift;

    my $field = $self->field(245);

    if ( $field ) {
	my @subs = map { $_->[0] =~ /^[anp]$/ ? $_->[1] : "" } $field->subfields;
	return join( "", @subs );
    } else {
	return "";
    }
}

=head2 author()

Returns the author from the 100, 110 or 111 tag.

=cut

sub author() {
    my $self = shift;

    my $field = $self->field('100|110|111');
    return $field ? $field->as_string() : "";
}

=head2 edition()

Returns the edition from the 250 tag, subfield a.

=cut

sub edition() {
    my $self = shift;

    my $str = $self->subfield(250,'a');
    return defined $str ? $str : "";
}

=head2 publication_date()

Returns the publication date from the 260 tag, subfield c.

=cut

sub publication_date() {
    my $self = shift;

    my $str = $self->subfield(260,'c');
    return defined $str ? $str : "";
}

=head1 FIELD & SUBFIELD ACCESS METHODS

=head2 fields()

Returns a list of all the fields in the record. The list contains 
a MARC::Field object for each field in the record.

=cut

sub fields() {
    my $self = shift;
    return @{$self->{_fields}};
}

=head2 field(tagspec(s))

Returns a list of tags that match the field specifier, or in scalar
context, just the first matching tag.

The field specifier can be a simple number (i.e. "245"), or use the "." 
notation of wildcarding (i.e. subject tags are "6..").

=cut

my %field_regex;

sub field {
    my $self = shift;
    my @specs = @_;

    my @list = ();
    for my $tag ( @specs ) {
	my $regex = $field_regex{ $tag };

	# Compile & stash it if necessary
	if ( not defined $regex ) {
	    $regex = qr/^$tag$/;
	    $field_regex{ $tag } = $regex;
	} # not defined

	for my $maybe ( $self->fields ) {
	    if ( $maybe->tag =~ $regex ) {
		return $maybe unless wantarray;

		push( @list, $maybe );
	    } # if
	} # for $maybe
    } # for $tag

    return @list;
}

=head2 subfield(tag,subfield)

Shortcut method for getting just a subfield for a tag.  These are equivalent:

  my $title = $marc->field('245')->subfield("a");
  my $title = $marc->subfield('245',"a");

If either the field or subfield can't be found, C<undef> is returned.

=cut

sub subfield {
    my $self = shift;
    my $tag = shift;
    my $subfield = shift;

    my $field = $self->field($tag) or return undef;
    return $field->subfield($subfield);
} # subfield()

=head2 insert_grouped_field(field)

Will insert the specified MARC::Field object into the record in 'grouped
order' and return true (1) on success, and false (undef) on failure.
For example, if a '650' field is inserted with insert_grouped_field()
it will be inserted at the end of the 6XX group of tags. After some discussion
on the perl4lib list it was descided that this is ordinarily what you will 
want. If you would like to insert at a specific point in the record you can use 
insert_fields_after() and insert_fields_before() methods which are described 
below. 

=cut 

sub insert_grouped_field {
    my ($self,$new) = @_;
    _all_parms_are_fields($new) or croak('Argument must be MARC::Field object');

    ## try to find the end of the field group and insert it there
    my $limit = int($new->tag() / 100);
    my $found = 0;
    foreach my $field ($self->fields()) {
	if ( int($field->tag() / 100) > $limit ) {
	    $self->insert_fields_before($field,$new);
	    $found = 1;
	    last;
	}
    }

    ## if we couldn't find the end of the group, then we must not have 
    ## any tags this high yet, so just append it
    if (!$found) {
	$self->append_fields($new); 
    }

    return(1);

}

=for internal

=cut

sub _all_parms_are_fields {
    for ( @_ ) {
	return 0 unless ref($_) eq 'MARC::Field';
    }
    return 1;
}

=head2 append_fields(@fields)

Appends the field specified by C<$field> to the end of the record. 
C<@fields> need to be MARC::Field objects.

    my $field = MARC::Field->new('590','','','a' => 'My local note.');
    $record->append_fields($field);

Returns the number of fields appended.

=cut

sub append_fields {
    my $self = shift;

    _all_parms_are_fields(@_) or croak('Arguments must be MARC::Field objects');

    push(@{ $self->{_fields} }, @_); 
    return scalar @_;
}

=head2 insert_fields_before($before_field,@new_fields)

Inserts the field specified by C<$new_field> before the field C<$before_field>.
Returns the number of fields inserted, or undef on failures.
Both C<$before_field> and all C<@new_fields> need to be MARC::Field objects.

    my $before_field = $record->field('260');
    my $new_field = MARC::Field->new('250','','','a' => '2nd ed.');
    $record->insert_fields_before($before_field,$new_field);

=cut

sub insert_fields_before {
    my $self = shift;

    _all_parms_are_fields(@_) 
	or croak('All arguments must be MARC::Field objects');

    my ($before,@new) = @_;

    ## find position of $before
    my $fields = $self->{_fields};
    my $pos = 0;
    foreach my $f (@$fields) {
	last if ($f == $before);
	$pos++;
    }

    ## insert before $before 
    if ($pos >= @$fields) {
	$self->_warn("Couldn't find field to insert before");
	return(undef);
    }
    splice(@$fields,$pos,0,@new);
    return scalar @new;

}

=head2 insert_fields_after($after_field,@new_fields)

Identical to C<insert_fields_before()>, but fields are added after 
C<$after_field>.

=cut

sub insert_fields_after {
    my $self = shift;

    _all_parms_are_fields(@_) or croak('All arguments must be MARC::Field objects');
    my ($after,@new) = @_;

    ## find position of $after
    my $fields = $self->{_fields};
    my $pos = 0;
    foreach my $f (@$fields) {
	last if ($f == $after);
	$pos++;
    }

    ## insert after $after
    if ($pos+1 >= @$fields) { 
	$self->_warn("Couldn't find field to insert after");
	return(undef);
    }
    splice(@$fields,$pos+1,0,@new);
    return scalar @new;
}

=head2 delete_field($field)

Deletes a field from the record.

The field must have been retrieved from the record using the 
C<field()> method.  For example, to delete a 526 tag if it exists:

    my $tag526 = $marc->field( "526" );
    if ( $tag526 ) {
	$marc->delete_field( $tag526 );
    }

C<delete_field()> returns the number of fields that were deleted.
This shouldn't be 0 unless you didn't get the tag properly.

=cut

sub delete_field {
    my $self = shift;
    my $deleter = shift;
    my $list = $self->{_fields};

    my $old_count = @$list;
    @$list = grep { $_ != $deleter } @$list;
    return $old_count - @$list;
}

=head2 as_usmarc()

This is a wrapper around C<MARC::File::USMARC::encode()> for compatibility with
older versions of MARC::Record.

=cut

sub as_usmarc() {
    my $self = shift;

    require MARC::File::USMARC;

    return MARC::File::USMARC::encode( $self );
}

=head2 as_formatted()

Returns a pretty string for printing in a MARC dump.

=cut

sub as_formatted() {
    my $self = shift;
	    
    my @lines = ( "LDR " . ($self->{_leader} || "") );
    for my $field ( @{$self->{_fields}} ) {
	    push( @lines, $field->as_formatted() );
    }

    return join( "\n", @lines );
} # as_formatted


=head2 leader()

Returns the leader for the record.  Sets the leader if I<text> is defined.
No error checking is done on the validity of the leader.

=cut

sub leader {
    my $self = shift;
    my $text = shift;

    if ( defined $text ) {
    	(length($text) eq 24)
	    or $self->_warn( "Leader must be 24 bytes long" );
	$self->{_leader} = $text;
    } # set the leader

    return $self->{_leader};
} # leader()

=head2 set_leader_lengths( $reclen, $baseaddr )

Internal function for updating the leader's length and base address.

=cut

sub set_leader_lengths {
    my $self = shift;
    my $reclen = shift;
    my $baseaddr = shift;
    substr($self->{_leader},0,5)  = sprintf("%05d",$reclen);
    substr($self->{_leader},12,5) = sprintf("%05d",$baseaddr);
}

=head2 clone()

The C<clone()> method makes a copy of an existing MARC record and returns
the new version.  Note that you cannot just say:

    my $newmarc = $oldmarc;

This just makes a copy of the reference, not a new object.  You must use
the C<clone()> method like so:

    my $newmarc = $oldmarc->clone;

You can also specify field specs to filter down only a 
certain subset of fields.  For instance, if you only wanted the
title and ISBN tags from a record, you could do this:

    my $small_marc = $marc->clone( 245, '020' );

The order of the fields is preserved as it was in the original record.

=cut

sub clone {
    my $self = shift;
    my @keeper_tags = @_;

    my $clone = $self->new();
    $clone->{_leader} = $self->{_leader};

    my $filtered = @keeper_tags ? [$self->field( @keeper_tags )] : undef;

    for my $field ( $self->fields() ) {
        if ( !$filtered || (grep {$field eq $_} @$filtered ) ) {
	    $clone->add_fields( $field->clone );
        }
    }

    # XXX FIX THIS $clone->update_leader();

    return $clone;
}

=head2 warnings()

Returns the warnings that were created when the record was read.
These are things like "Invalid indicators converted to blanks".

The warnings are items that you might be interested in, or might
not.  It depends on how stringently you're checking data.  If
you're doing some grunt data analysis, you probably don't care.

A side effect of calling warnings() is that the warning buffer will
be cleared.

=cut

sub warnings() {
    my $self = shift;
    my @warnings = @{$self->{_warnings}};
    $self->{_warnings} = []; 
    return @warnings;
}

=head2 add_fields()

C<add_fields()> is now deprecated, and users are encouraged to use 
C<append_fields()>, C<insert_fields_after()>, and C<insert_fields_before()> 
since they do what you want probably. It is still here though, for backwards 
compatability.

C<add_fields()> adds MARC::Field objects to the end of the list.  Returns the 
number of fields added, or C<undef> if there was an error.

There are three ways of calling C<add_fields()> to add data to the record.

=over 4

=item 1 Create a MARC::Field object and add it

  my $author = MARC::Field->new(
	        100, "1", " ", a => "Arnosky, Jim."
	        );
  $marc->add_fields( $author );

=item 2 Add the data fields directly, and let C<add_fields()> take care of the objectifying.

  $marc->add_fields(
        245, "1", "0",
                a => "Raccoons and ripe corn /",
                c => "Jim Arnosky.",
        	);

=item 3 Same as #2 above, but pass multiple fields of data in anonymous lists

  $marc->add_fields(
	[ 250, " ", " ", a => "1st ed." ],
	[ 650, "1", " ", a => "Raccoons." ],
	);

=back

=cut

sub add_fields {
    my $self = shift;

    my $nfields = 0;
    my $fields = $self->{_fields};

    while ( my $parm = shift ) {
	# User handed us a list of data (most common possibility)
	if ( ref($parm) eq "" ) {
	    my $field = MARC::Field->new( $parm, @_ )
		    or return _gripe( $MARC::Field::ERROR );
	    push( @$fields, $field );
	    ++$nfields;
	    last; # Bail out, we're done eating parms

	# User handed us an object.
	} elsif ( ref($parm) eq "MARC::Field" ) {
	    push( @$fields, $parm );
	    ++$nfields;

	# User handed us an anonymous list of parms
	} elsif ( ref($parm) eq "ARRAY" ) {
	    my $field = MARC::Field->new(@$parm) 
		or return _gripe( $MARC::Field::ERROR );
	    push( @$fields, $field );
	    ++$nfields;

	} else {
	    croak( "Unknown parm of type", ref($parm), " passed to add_fields()" );
	} # if

    } # while

    return $nfields;
}

# NOTE: _warn is an object method
sub _warn {
    my $self = shift;
    push( @{$self->{_warnings}}, join( "", @_ ) );
    return($self);
}


# NOTE: _gripe is NOT an object method
sub _gripe {
    $ERROR = join( "", @_ );

    warn $ERROR;

    return undef;
}


1;

__END__

=head1 DESIGN NOTES

A brief discussion of why MARC::Record is done the way it is:

=over 4

=item * It's built for quick prototyping

One of the areas Perl excels is in allowing the programmer to 
create easy solutions quickly.  MARC::Record is designed along
those same lines.  You want a program to dump all the 6XX
tags in a file?  MARC::Record is your friend.

=item * It's built for extensibility

Currently, I'm using MARC::Record for analyzing bibliographic
data, but who knows what might happen in the future?  MARC::Record
needs to be just as adept at authority data, too.

=item * It's designed around accessor methods

I use method calls everywhere, and I expect calling programs to do
the same, rather than accessing internal data directly.  If you
access an object's hash fields on your own, future releases may
break your code.

=item * It's not built for speed

One of the tradeoffs in using accessor methods is some overhead
in the method calls.  Is this slow?  I don't know, I haven't measured.
I would suggest that if you're a cycle junkie that you use
Benchmark.pm to check to see where your bottlenecks are, and then
decide if MARC::Record is for you.

=back

=head1 RELATED MODULES

L<MARC::Record>, L<MARC::Lint>

=head1 SEE ALSO

=over 4

=item * perl4lib (L<http://www.rice.edu/perl4lib/>)

A mailing list devoted to the use of Perl in libraries.

=item * Library Of Congress MARC pages (L<http://www.loc.gov/marc/>)

The definitive source for all things MARC.


=item * I<Understanding MARC Bibliographic> (L<http://lcweb.loc.gov/marc/umb/>)

Online version of the free booklet.  An excellent overview of the MARC format.  Essential.


=item * Tag Of The Month (L<http://www.tagofthemonth.com/>)

Follett Software Company's
(L<http://www.fsc.follett.com/>) monthly discussion of various MARC tags.

=back

=head1 TODO

=over 4

=item * Incorporate MARC.pm in the distribution.

Combine MARC.pm and MARC::* into one distribution.

=item * Podify MARC.pm

=item * Allow regexes across the entire tag

Imagine something like this:

  my @sears_headings = $marc->tag_grep( /Sears/ );

(from Mike O'Regan)

=item * Insert a field in an arbitrary place in the record

=item * Allow deleting a field

  for my $field ( $record->field( "856" ) ) {
	$record->delete_field( $field ) unless useful($field);
	} # for

(from Anne Highsmith hismith@tamu.edu)


=item * Modifying an existing field

=back

=head1 BUGS, WISHES AND CORRESPONDENCE

Please feel free to email me at andy@petdance.com.  I'm glad to help as
best I can, and I'm always interested in bugs, suggestions and patches.

The MARC::Record development team uses the RT bug tracking system at
L<http://rt.cpan.org>.  If your email is about a bug or suggestion,
please report it through the RT system.  This is a huge help for
the team, and you'll be notified of progress as things get fixed or
updated.  If you prefer not to use the website, you can send your bug
to bug-MARC-Record@rt.cpan.org.

=head1 IDEAS

Ideas are things that have been considered, but nobody's actually asked for.

=over 4

=item * Create multiple output formats.

These could be ASCII, XML, or MarcMaker.

=back

=head1 LICENSE

This code may be distributed under the same terms as Perl itself. 

Please note that these modules are not products of or supported by the
employers of the various contributors to the code.

=head1 AUTHOR

Andy Lester, E<lt>marc@petdance.comE<gt>

=cut


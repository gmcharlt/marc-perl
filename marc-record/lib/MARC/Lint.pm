package MARC::Lint;

use strict;
use integer;

=head1 NAME

MARC::Lint - Perl extension for checking validity of MARC records

=head1 SYNOPSIS

  use MARC::Record;
  use MARC::Lint;

  my $linter = new MARC::Lint;
  my $filename = shift;

  open( IN, "<", $filename ) or die "Couldn't open $filename: $!\n";
  binmode( IN ); # for the Windows folks
  while ( !eof(IN) ) {
  	my $marc = MARC::Record::next_from_file( *IN );
	die $MARC::Record::ERROR unless $marc;

	$linter->check_record( $marc );


	# Print the title tag
	print $marc->subfield(245,"a"), "\n";

	# Print the errors that were found
	print join( "\n", $linter->warnings ), "\n";
  } # while

  close IN or die "Error closing $filename: $!\n";

Given the following MARC record:

	LDR 00000nam  22002538a 4500
	100 14 _aWall, Larry.
	110 1  _aO'Reilly & Associates.
	245 90 _aProgramming Perl /
               _aBig Book of Perl /
               _cLarry Wall, Tom Christiansen & Jon Orwant.
	250    _a3rd ed.
	250    _a3rd ed.
	260    _aCambridge, Mass. :
	       _bO'Reilly,
	       _r2000.
	590 4  _aPersonally signed by Larry.
	856 43 _uhttp://www.perl.com/

the following errors are generated:

	1XX: Only one 1XX tag is allowed, but I found 2 of them.
	100: Indicator 2 must be blank
	245: Indicator 1 must be 0 or 1
	245: Subfield _a is not repeatable.
	250: Field is not repeatable.
	260: Subfield _r is not valid.
	260: Must have a subfield _c.
	590: Indicator 1 must be blank
	856: Indicator 2 must be blank, 0, 1, 2 or 8

=head1 DESCRIPTION

Module for checking validity of MARC records.  99% of the users will want to do 
something like is shown in the synopsis.  The other intrepid 1% will overload the
C<MARC::Lint> module's methods and provide their own special field-level checking.

What this means is that if you have certain requirements, such as making sure that
all 952 tags have a certain call number in them, you can write a function that 
checks for that, and still get all the benefits of the MARC::Lint framework.

=head1 EXPORT

None.  Everything is done through objects.

=head1 METHODS

=head2 C<new()>

No parms needed.  The C<MARC::Lint> object is little more than a list of warnings 
and a bunch of rules.

=cut

use MARC::Record;
use MARC::Field;

sub new() {
	my $class = shift;
	$class = ref($class) || $class;

	my $self = {
		_warnings => [],
	};
	bless $self, $class;

	$self->_read_rules();

	return $self;
}

=head2 C<warnings()>

Returns a list of warnings found by C<check_record()> and its brethren.

=cut

sub warnings {
	my $self = shift;

	return wantarray ? @{$self->{_warnings}} : scalar @{$self->{_warnings}};
}

=head2 C<clear_warnings()>

Clear the list of warnings for this linter object.  It's automatically called
when you call C<check_record()>.

=cut

sub clear_warnings {
	my $self = shift;

	$self->{_warnings} = [];
}

=head2 C<warn(str[,str...])>

Create a warning message, built from strings passed, like a C<print> statement.

Typically, you'll leave this to C<check_record()>, but industrious programmers
may want to do their own checking as well.

=cut

sub warn {
	my $self = shift;

	push( @{$self->{_warnings}}, join( "", @_ ) );

	return undef;
}

=head2 C<check_record(marc)>

Does all sorts of lint-like checks on the MARC record I<marc>, both on the record as a whole,
and on the individual fields & subfields.

=cut

sub check_record {
	my $self = shift;
	my $marc = shift;

	$self->clear_warnings();

	(ref($marc) eq "MARC::Record")
		or return $self->warn( "Must pass a MARC::Record object to check_record" );

	if ( (my @_1xx = $marc->field( "1XX" )) > 1 ) {
		$self->warn( "1XX: Only one 1XX tag is allowed, but I found ", scalar @_1xx, " of them." );
	}

	if ( not $marc->field( 245 ) ) {
		$self->warn( "245: No 245 tag." );
	}


	my %field_seen;
	my $rules = $self->{_rules};
	for my $field ( $marc->fields ) {
		my $tagno = $field->tag;
		my $tagrules = $rules->{$tagno} or next;

		if ( $tagrules->{NR} && $field_seen{$tagno} ) { 
			$self->warn( "$tagno: Field is not repeatable." );
		}

		if ( $tagno >= 10 ) {
			for my $ind ( 1..2 ) {
				my $indvalue = $field->indicator($ind);
				if ( not ($indvalue =~ $tagrules->{"ind$ind" . "_regex"}) ) {
					$self->warn( 
						"$tagno: Indicator $ind must be ", 
						$tagrules->{"ind$ind" . "_desc"}, 
						" but it's \"$indvalue\"" 
					);
				}
			}
			
			my %sub_seen;
			for my $subfield ( $field->subfields ) {
				my ($code,$data) = @$subfield;

				my $rule = $tagrules->{$code};
				if ( not defined $rule ) {
					$self->warn( "$tagno: Subfield _$code is not allowed." );
				} elsif ( ($rule eq "NR") && $sub_seen{$code} ) {
					$self->warn( "$tagno: Subfield _$code is not repeatable." );
				}

				if ( $data =~ /[\t\r\n]/ ) {
					$self->warn( "$tagno: Subfield _$code has an invalid control character" );
				}

				++$sub_seen{$code};
			}
		}

		# Check to see if a check_xxx() function exists, and call it on the field if it does
		my $checker = "check_$tagno";
		if ( $self->can( $checker ) ) {
			$self->$checker( $field );
		}

		++$field_seen{$tagno};
	} # for

	return;
}

=head2 C<check_I<xxx>(field)>

Various functions to check the different fields.  If the function doesn't exist, 
then it doesn't get checked.

=cut

sub check_245 {
	my $self = shift;
	my $field = shift;

	if ( not $field->subfield( "a" ) ) {
		$self->warn( "245: Must have a subfield _a." );
	}
}

=head1 SEE ALSO

Check the docs for L<MARC::Record>.  All software links are there.

=head1 TODO

=over 4

=item * ISBN and ISSN checking

We can check the 020 and 022 fields with the C<Business::ISBN> and 
C<Business::ISSN> modules, respectively.

=back

=head1 LICENSE

This code may be distributed under the same terms as Perl itself. 

Please note that these modules are not products of or supported by the
employers of the various contributors to the code.

=head1 AUTHOR

Andy Lester, E<lt>marc@petdance.comE<gt>

=cut

# Used only to read the stuff from __DATA__
sub _read_rules() {
	my $self = shift;
	
	my $tell = tell(DATA);  # Stash the position so we can reset it for next time

	local $/ = "";
	while ( my $lines = <DATA> ) {
		$lines =~ s/\s+$//;
		my @keyvals = split( /\s+/, $lines );

		my $tagno = shift @keyvals;
		my $repeatable = shift @keyvals;
		
		my @tag_range = ($tagno);
		if ( $tagno =~ /^(\d\d)X/ ) {
			my $base = $1;
			@tag_range = ( "${base}0" .. "${base}9" );
		}

		# Handle the ranges of tags.
		for my $currtag ( @tag_range ) {
			$self->_parse_tag_rules( $currtag, $repeatable, @keyvals );
		} # for
		# I guess I could just have multiple references to the same tag, but I'm not that worried about memory
	} # while

	seek( DATA, $tell, 0 );
}

sub _parse_tag_rules {
	my $self = shift;
	my $tagno = shift;
	my $repeatable = shift;
	my @keyvals = @_;

	my $rules = ($self->{_rules}->{$tagno} ||= {});
	$rules->{$repeatable} = $repeatable;

	while ( @keyvals ) {
		my $key = shift @keyvals;
		my $val = shift @keyvals;
		
		$rules->{$key} = $val;

		# Do magic for indicators
		if ( $key =~ /^ind/ ) {
			my $desc;
			my $regex;
			
			if ( $val eq "blank" ) {
				$desc = "blank";
				$regex = qr/^ $/;
			} else {
				$desc = _nice_list($val);
				$val =~ s/^b/ /;
				$regex = qr/^[$val]$/;
			}

		$rules->{$key."_desc"} = $desc;
		$rules->{$key."_regex"} = $regex;
		} # if indicator
	} # while
}


sub _nice_list($) {
	my $str = shift;

	if ( $str =~ s/(\d)-(\d)/$1 thru $2/ ) {
		return $str;
	}

	my @digits = split( //, $str );
	$digits[0] = "blank" if $digits[0] eq "b";
	my $last = pop @digits;
	return join( ", ", @digits ) . " or $last";
}

sub _ind_regex($) {
	my $str = shift;

	return qr/^ $/ if $str eq "blank";

	return qr/^[$str]$/;
}


1;

__DATA__
010	NR
ind1	blank
ind2	blank
a	NR
b	R
z	R
8	R

013	R
ind1	blank
ind2	blank
a	NR
b	NR
c	NR
d	R
e	R
f	R
6	NR
8	R

015	R
ind1	blank
ind2	blank
a	R
2	NR
6	NR
8	R

016	R
ind1	b7
ind2	blank
a	NR
z	R
2	NR
8	R

017	R
ind1	blank
ind2	blank
a	R
b	NR
2	NR
6	NR
8	R

018	NR
ind1	blank
ind2	blank
a	NR
6	NR
8	R

020	R
ind1	blank
ind2	blank
a	NR
c	NR
z	R
6	NR
8	R

022	R
ind1	b01
ind2	blank
a	NR
y	R
z	R
6	NR
8	R

024	R
ind1	0123478
ind2	b01
a	NR
c	NR
d	NR
z	R
2	NR
6	NR
8	R

025	R
ind1	blank
ind2	blank
a	R
8	R

026	R
ind1	blank
ind2	blank
a	R
b	R
c	NR
d	R
e	NR
2	NR
5	R
6	NR
8	R

027	R
ind1	blank
ind2	blank
a	NR
z	R
6	NR
8	R

028	R
ind1	012345
ind2	0123
a	NR
b	NR
6	NR
8	R

030	R
ind1	blank
ind2	blank
a	NR
z	R
6	NR
8	R

032	R
ind1	blank
ind2	blank
a	NR
b	NR
6	NR
8	R

033	R
ind1	b012
ind2	b012
a	R
b	R
c	R
3	NR
6	NR
8	R

034	R
ind1	013
ind2	b01
a	NR
b	R
c	R
d	NR
e	NR
f	NR
g	NR
h	R
j	NR
k	NR
m	NR
n	NR
p	NR
s	R
t	R
6	NR
8	R

035	R
ind1	blank
ind2	blank
a	NR
z	R
6	NR
8	R

036	NR
ind1	blank
ind2	blank
a	NR
b	NR
6	NR
8	R

037	R
ind1	blank
ind2	blank
a	NR
b	NR
c	R
f	R
g	R
n	R
6	NR
8	R

038	NR
ind1	blank
ind2	blank
a	NR
6	NR
8	R

040	NR
ind1	blank
ind2	blank
a	NR
b	NR
c	NR
d	R
e	NR
6	NR
8	R

041	R
ind1	01
ind2	b7
a	R
b	R
d	R
e	R
f	R
g	R
h	R
2	NR
6	NR
8	R

042	NR
ind1	blank
ind2	blank
a	R

043	NR
ind1	blank
ind2	blank
a	R
b	R
c	R
2	R
6	NR
8	R

044	NR
ind1	blank
ind2	blank
a	R
b	R
c	R
2	R
6	NR
8	R

045	NR
ind1	b012
ind2	blank
a	R
b	R
c	R
6	NR
8	R

046	R
ind1	blank
ind2	blank
a	NR
b	NR
c	NR
d	NR
e	NR
j	NR
k	NR
l	NR
m	NR
n	NR
2	NR
6	NR
8	R

047	NR
ind1	blank
ind2	blank
a	R
8	R

048	R
ind1	blank
ind2	blank
a	R
b	R
8	R

050	R
ind1	b01
ind2	040123
a	R
b	NR
3	NR
6	NR
8	R

051	R
ind1	blank
ind2	b0123
a	NR
b	NR
c	NR
8	R

052	R
ind1	b17
ind2	blank
a	NR
b	R
d	R
2	NR
6	NR
8	R

055	R
ind1	b01
ind2	0123456789
a	NR
b	NR
2	NR
8	R

060	R
ind1	b01
ind2	040123
a	R
b	NR
8	R

061	R
ind1	blank
ind2	b0123
a	R
b	NR
c	NR
8	R

066	NR
ind1	blank
ind2	blank
a	NR
b	NR
c	R

070	R
ind1	01
ind2	b0123
a	R
b	NR
8	R

071	R
ind1	blank
ind2	b0123
a	R
b	NR
c	NR
8	R

072	R
ind1	blank
ind2	07
a	NR
x	R
2	NR
6	NR
8	R

074	R
ind1	blank
ind2	blank
a	NR
z	R
8	R

080	R
ind1	blank
ind2	blank
a	NR
b	NR
x	R
2	NR
6	NR
8	R

082	R
ind1	01
ind2	b04
a	R
b	NR
2	NR
6	NR
8	R

084	R
ind1	blank
ind2	blank
a	R
b	NR
2	NR
6	NR
8	R

086	R
ind1	b01
ind2	blank
a	NR
z	R
2	NR
6	NR
8	R

088	R
ind1	blank
ind2	blank
a	NR
z	R
6	NR
8	R

100	NR
ind1	013
ind2	blank
a	NR
b	NR
c	R
d	NR
e	R
f	NR
g	NR
j	R
k	R
l	NR
n	R
p	R
q	NR
t	NR
u	NR
4	R
6	NR
8	R

110	NR
ind1	012
ind2	blank
a	NR
b	R
c	NR
d	R
e	R
f	NR
g	NR
k	R
l	NR
n	R
p	R
t	NR
u	NR
4	R
6	NR
8	R

111	NR
ind1	012
ind2	blank
a	NR
c	NR
d	NR
e	R
f	NR
g	NR
k	R
l	NR
n	R
p	R
q	NR
t	NR
u	NR
4	R
6	NR
8	R

130	NR
ind1	0-9
ind2	blank
a	NR
d	R
f	NR
g	NR
h	NR
k	R
l	NR
m	R
n	R
o	NR
p	R
r	NR
s	NR
t	NR
6	NR
8	R

210	R
ind1	01
ind2	b0
a	NR
b	NR
2	R
6	NR
8	R

222	R
ind1	b0123
ind2	0-9
a	NR
b	NR
6	NR
8	R

240	NR
ind1	01
ind2	0-9
a	NR
d	R
f	NR
g	NR
h	NR
k	R
l	NR
m	R
n	R
o	NR
p	R
r	NR
s	NR
6	NR
8	R

242	R
ind1	01
ind2	0-9
a	NR
b	NR
c	NR
h	NR
n	R
p	R
y	NR
6	NR
8	R

243	NR
ind1	01
ind2	0-9
a	NR
d	R
f	NR
g	NR
h	NR
k	R
l	NR
m	NR
n	R
o	NR
p	R
r	NR
s	NR
6	NR
8	R

245	NR
ind1	01
ind2	0-9
a	NR
b	NR
c	NR
f	NR
g	NR
h	NR
k	R
n	R
p	R
s	NR
6	NR
8	R

246	R
ind1	0123
ind2	b012345678
a	NR
b	NR
f	NR
g	NR
h	NR
i	NR
n	R
p	R
5	NR
6	NR
8	R

247	R
ind1	01
ind2	01
a	NR
b	NR
f	NR
g	NR
h	NR
n	R
p	R
x	NR
6	NR
8	R

250	NR
ind1	blank
ind2	blank
a	NR
b	NR
6	NR
8	R

254	NR
ind1	blank
ind2	blank
a	NR
6	NR
8	R

255	R
ind1	blank
ind2	blank
a	NR
b	NR
c	NR
d	NR
e	NR
f	NR
g	NR
6	NR
8	R

256	NR
ind1	blank
ind2	blank
a	NR
6	NR
8	R

257	NR
ind1	blank
ind2	blank
a	NR
6	NR
8	R

260	R
ind1	b23
ind2	b0101
a	R
b	R
c	R
d	R
e	NR
f	NR
g	NR
3	NR
6	NR
8	R

261	NR
ind1	blank
ind2	blank
a	R
b	R
d	R
e	R
f	R
6	NR
8	R

262	NR
ind1	blank
ind2	blank
a	NR
b	NR
c	NR
k	NR
l	NR
6	NR
8	R

263	NR
ind1	blank
ind2	blank
a	NR
6	NR
8	R

270	R
ind1	b12
ind2	b07
a	R
b	NR
c	NR
d	NR
e	NR
f	NR
g	NR
h	NR
i	NR
j	R
k	R
l	R
m	R
n	R
p	R
q	R
r	R
z	R
4	R
6	NR
8	R

300	R
ind1	blank
ind2	blank
a	R
b	NR
c	R
e	NR
f	R
g	R
3	NR
6	NR
8	R

306	NR
ind1	blank
ind2	blank
a	R
6	NR
8	R

307	R
ind1	b8
ind2	blank
a	NR
b	NR
6	NR
8	R

310	NR
ind1	blank
ind2	blank
a	NR
b	NR
6	NR
8	R

321	R
ind1	blank
ind2	blank
a	NR
b	NR
6	NR
8	R

340	R
ind1	blank
ind2	blank
a	R
b	R
c	R
d	R
e	R
f	R
h	R
i	R
3	NR
6	NR
8	R

342	R
ind1	01
ind2	012345678
a	NR
b	NR
c	NR
d	NR
e	R
f	R
g	NR
h	NR
i	NR
j	NR
k	NR
l	NR
m	NR
n	NR
o	NR
p	NR
q	NR
r	NR
s	NR
t	NR
u	NR
v	NR
w	NR
2	NR
6	NR
8	R

343	R
ind1	blank
ind2	blank
a	NR
b	NR
c	NR
d	NR
e	NR
f	NR
g	NR
h	NR
i	NR
6	NR
8	R

351	R
ind1	blank
ind2	blank
a	R
b	R
c	NR
3	NR
6	NR
8	R

352	R
ind1	blank
ind2	blank
a	NR
b	R
c	R
d	NR
e	NR
f	NR
g	NR
i	NR
6	NR
8	R

355	R
ind1	0123458
ind2	blank
a	NR
b	R
c	R
d	NR
e	NR
f	NR
g	NR
h	NR
j	R
6	NR
8	R

357	NR
ind1	blank
ind2	blank
a	NR
b	R
c	R
g	R
6	NR
8	R

362	R
ind1	01
ind2	blank
a	NR
z	NR
6	NR
8	R

400	R
ind1	013
ind2	01
a	NR
b	NR
c	R
d	NR
e	R
f	NR
g	NR
k	R
l	NR
n	R
p	R
t	NR
u	NR
v	NR
x	NR
4	R
6	NR
8	R

410	R
ind1	012
ind2	01
a	NR
b	R
c	NR
d	R
e	R
f	NR
g	NR
k	R
l	NR
n	R
p	R
t	NR
u	NR
v	NR
x	NR
4	R
6	NR
8	R

411	R
ind1	012
ind2	01
a	NR
c	NR
d	NR
e	R
f	NR
g	NR
k	R
l	NR
n	R
p	R
q	NR
t	NR
u	NR
v	NR
x	NR
4	R
6	NR
8	R

440	R
ind1	blank
ind2	0-9
a	NR
n	R
p	R
v	NR
x	NR
6	NR
8	R

490	R
ind1	01
ind2	blank
a	R
l	NR
v	R
x	NR
6	NR
8	R

500	R
ind1	blank
ind2	blank
a	NR
3	NR
5	NR
6	NR
8	R

501	R
ind1	blank
ind2	blank
a	NR
5	NR
6	NR
8	R

502	R
ind1	blank
ind2	blank
a	NR
6	NR
8	R

504	R
ind1	blank
ind2	blank
a	NR
b	NR
6	NR
8	R

505	R
ind1	0128
ind2	b0
a	NR
g	R
r	R
t	R
u	R
6	NR
8	R

506	R
ind1	blank
ind2	blank
a	NR
b	R
c	R
d	R
e	R
u	R
3	NR
5	NR
6	NR
8	R

507	NR
ind1	blank
ind2	blank
a	NR
b	NR
6	NR
8	R

508	R
ind1	blank
ind2	blank
a	NR
6	NR
8	R

510	R
ind1	01234
ind2	blank
a	NR
b	NR
c	NR
x	NR
3	NR
6	NR
8	R

511	R
ind1	01
ind2	blank
a	NR
6	NR
8	R

513	R
ind1	blank
ind2	blank
a	NR
b	NR
6	NR
8	R

514	NR
ind1	blank
ind2	blank
a	NR
b	R
c	R
d	R
e	NR
f	NR
g	R
h	R
i	NR
j	R
k	R
m	NR
u	R
z	R
6	NR
8	R

515	R
ind1	blank
ind2	blank
a	NR
6	NR
8	R

516	R
ind1	b8
ind2	blank
a	NR
6	NR
8	R

518	R
ind1	blank
ind2	blank
a	NR
3	NR
6	NR
8	R

520	R
ind1	b01238
ind2	blank
a	NR
b	NR
u	R
3	NR
6	NR
8	R

521	R
ind1	b012348
ind2	blank
a	R
b	NR
3	NR
6	NR
8	R

522	R
ind1	b8
ind2	blank
a	NR
6	NR
8	R

524	R
ind1	b8
ind2	blank
a	NR
2	NR
3	NR
6	NR
8	R

525	R
ind1	blank
ind2	blank
a	NR
6	NR
8	R

526	R
ind1	08
ind2	blank
a	NR
b	NR
c	NR
d	NR
i	NR
x	R
z	R
5	NR
6	NR
8	R

530	R
ind1	blank
ind2	blank
a	NR
b	NR
c	NR
d	NR
u	R
3	NR
6	NR
8	R

533	R
ind1	blank
ind2	blank
a	NR
b	R
c	R
d	NR
e	NR
f	R
m	R
n	R
3	NR
6	NR
7	NR
8	R

534	R
ind1	blank
ind2	b01
a	NR
b	NR
c	NR
e	NR
f	R
k	R
l	NR
m	NR
n	R
p	NR
t	NR
x	R
z	R
6	NR
8	R

535	R
ind1	12
ind2	blank
a	NR
b	R
c	R
d	R
g	NR
3	NR
6	NR
8	R

536	R
ind1	blank
ind2	blank
a	NR
b	R
c	R
d	R
e	R
f	R
g	R
h	R
6	NR
8	R

538	R
ind1	blank
ind2	blank
a	NR
6	NR
8	R

540	R
ind1	blank
ind2	blank
a	NR
b	NR
c	NR
d	NR
u	R
3	NR
5	NR
6	NR
8	R

541	R
ind1	blank
ind2	blank
a	NR
b	NR
c	NR
d	NR
e	NR
f	NR
h	NR
n	R
o	R
3	NR
5	NR
6	NR
8	R

544	R
ind1	b01
ind2	blank
a	R
b	R
c	R
d	R
e	R
n	R
3	NR
6	NR
8	R

545	R
ind1	b01
ind2	blank
a	NR
b	NR
u	R
6	NR
8	R

546	R
ind1	blank
ind2	blank
a	NR
b	R
3	NR
6	NR
8	R

547	R
ind1	blank
ind2	blank
a	NR
6	NR
8	R

550	R
ind1	blank
ind2	b01
a	NR
6	NR
8	R

552	R
ind1	blank
ind2	blank
a	NR
b	NR
c	NR
d	NR
e	R
f	R
g	NR
h	NR
i	NR
j	NR
k	NR
l	NR
m	NR
n	NR
o	R
p	R
u	R
z	R
6	NR
8	R

555	R
ind1	b08
ind2	blank
a	NR
b	R
c	NR
d	NR
u	R
3	NR
6	NR
8	R

556	R
ind1	b8
ind2	blank
a	NR
z	R
6	NR
8	R

561	R
ind1	blank
ind2	blank
a	NR
3	NR
5	NR
6	NR
8	R

562	R
ind1	blank
ind2	blank
a	R
b	R
c	R
d	R
e	R
3	NR
5	NR
6	NR
8	R

563	R
ind1	blank
ind2	blank
a	NR
u	R
3	NR
5	NR
6	NR
8	R

565	R
ind1	b08
ind2	blank
a	NR
b	R
c	R
d	R
e	R
3	NR
6	NR
8	R

567	R
ind1	b8
ind2	blank
a	NR
6	NR
8	R

580	R
ind1	blank
ind2	blank
a	NR
6	NR
8	R

581	R
ind1	b8
ind2	blank
a	NR
z	R
3	NR
6	NR
8	R

583	R
ind1	blank
ind2	blank
a	NR
b	R
c	R
d	R
e	R
f	R
h	R
i	R
j	R
k	R
l	R
n	R
o	R
u	R
x	R
z	R
2	NR
3	NR
5	NR
6	NR
8	R

584	R
ind1	blank
ind2	blank
a	R
b	R
3	NR
5	NR
6	NR
8	R

585	R
ind1	blank
ind2	blank
a	NR
3	NR
5	NR
6	NR
8	R

586	R
ind1	b8
ind2	blank
a	NR
3	NR
6	NR
8	R

600	R
ind1	013
ind2	01234567
a	NR
b	NR
c	R
d	NR
e	R
f	NR
g	NR
h	NR
k	R
j	R
l	NR
m	R
n	R
o	NR
p	R
q	NR
r	NR
s	NR
t	NR
u	NR
v	R
x	R
y	R
z	R
2	NR
3	NR
4	R
6	NR
8	R

610	R
ind1	012
ind2	01234567
a	NR
b	R
c	NR
d	R
e	R
f	NR
g	NR
h	NR
k	R
l	NR
m	R
n	R
o	NR
p	R
r	NR
s	NR
t	NR
u	NR
v	R
x	R
y	R
z	R
2	NR
3	NR
4	R
6	NR
8	R

611	R
ind1	012
ind2	01234567
a	NR
c	NR
d	NR
e	R
f	NR
g	NR
h	NR
k	R
l	NR
n	R
p	R
q	NR
s	NR
t	NR
u	NR
v	R
x	R
y	R
z	R
2	NR
3	NR
4	R
6	NR
8	R

630	R
ind1	0-9
ind2	01234567
a	NR
d	R
f	NR
g	NR
h	NR
k	R
l	NR
m	R
n	R
o	NR
p	R
r	NR
s	NR
t	NR
v	R
x	R
y	R
z	R
2	NR
3	NR
6	NR
8	R

648	R
ind1	blank
ind2	01234567
a	NR
v	R
x	R
y	R
z	R
2	NR
3	NR
6	NR
8	R

650	R
ind1	b012
ind2	01234567
a	NR
b	NR
c	NR
d	NR
e	NR
v	R
x	R
y	R
z	R
2	NR
3	NR
6	NR
8	R

651	R
ind1	blank
ind2	01234567
a	NR
v	R
x	R
y	R
z	R
2	NR
3	NR
6	NR
8	R

653	R
ind1	b012
ind2	blank
a	R
6	NR
8	R

654	R
ind1	b012
ind2	blank
a	NR
b	R
c	R
v	R
y	R
z	R
2	NR
3	NR
6	NR
8	R

655	R
ind1	b0
ind2	01234567
a	NR
b	R
c	R
v	R
x	R
y	R
z	R
2	NR
3	NR
5	NR
6	NR
8	R

656	R
ind1	blank
ind2	7
a	NR
k	NR
v	R
x	R
y	R
z	R
2	NR
3	NR
6	NR
8	R

657	R
ind1	blank
ind2	7
a	NR
v	R
x	R
y	R
z	R
2	NR
3	NR
6	NR
8	R

658	R
ind1	blank
ind2	blank
a	NR
b	R
c	NR
d	NR
2	NR
6	NR
8	R

700	R
ind1	013
ind2	b2
a	NR
b	NR
c	R
d	NR
e	R
f	NR
g	NR
h	NR
j	R
k	R
l	NR
m	R
n	R
o	NR
p	R
q	NR
r	NR
s	NR
t	NR
u	NR
x	NR
3	NR
4	R
5	NR
6	NR
8	R

710	R
ind1	012
ind2	b2
a	NR
b	R
c	NR
d	R
e	R
f	NR
g	NR
h	NR
k	R
l	NR
m	R
n	R
o	NR
p	R
r	NR
s	NR
t	NR
u	NR
x	NR
3	NR
4	R
5	NR
6	NR
8	R

711	R
ind1	012
ind2	b2
a	NR
c	NR
d	NR
e	R
f	NR
g	NR
h	NR
k	R
l	NR
n	R
p	R
q	NR
s	NR
t	NR
u	NR
x	NR
3	NR
4	R
5	NR
6	NR
8	R

720	R
ind1	b12
ind2	blank
a	NR
e	R
4	R
6	NR
8	R

730	R
ind1	0-9
ind2	b2
a	NR
d	R
f	NR
g	NR
h	NR
k	R
l	NR
m	R
n	R
o	NR
p	R
r	NR
s	NR
t	NR
x	NR
3	NR
5	NR
6	NR
8	R

740	R
ind1	0-9
ind2	b2
a	NR
h	NR
n	R
p	R
5	NR
6	NR
8	R

752	R
ind1	blank
ind2	blank
a	NR
b	NR
c	NR
d	NR
6	NR
8	R

753	R
ind1	blank
ind2	blank
a	NR
b	NR
c	NR
6	NR
8	R

754	R
ind1	blank
ind2	blank
a	R
c	R
d	R
x	R
z	R
2	NR
6	NR
8	R

760	R
ind1	01
ind2	b8
a	NR
b	NR
c	NR
d	NR
g	R
h	NR
i	NR
m	NR
n	R
o	R
s	NR
t	NR
w	R
x	NR
y	NR
6	NR
7	NR
8	R

762	R
ind1	01
ind2	b8
a	NR
b	NR
c	NR
d	NR
g	R
h	NR
i	NR
m	NR
n	R
o	R
s	NR
t	NR
w	R
x	NR
y	NR
6	NR
7	NR
8	R

765	R
ind1	01
ind2	b8
a	NR
b	NR
c	NR
d	NR
g	R
h	NR
i	NR
k	R
m	NR
n	R
o	R
r	R
s	NR
t	NR
u	NR
w	R
x	NR
y	NR
z	R
6	NR
7	NR
8	R

767	R
ind1	01
ind2	b8
a	NR
b	NR
c	NR
d	NR
g	R
h	NR
i	NR
k	R
m	NR
n	R
o	R
r	R
s	NR
t	NR
u	NR
w	R
x	NR
y	NR
z	R
6	NR
7	NR
8	R

770	R
ind1	01
ind2	b8
a	NR
b	NR
c	NR
d	NR
g	R
h	NR
i	NR
k	R
m	NR
n	R
o	R
r	R
s	NR
t	NR
u	NR
w	R
x	NR
y	NR
z	R
6	NR
7	NR
8	R

772	R
ind1	01
ind2	b08
a	NR
b	NR
c	NR
d	NR
g	R
h	NR
i	NR
k	R
m	NR
n	R
o	R
r	R
s	NR
t	NR
u	NR
w	R
x	NR
y	NR
z	R
6	NR
7	NR
8	R

773	R
ind1	01
ind2	b8
a	NR
b	NR
d	NR
g	R
h	NR
i	NR
k	R
m	NR
n	R
o	R
p	NR
r	R
s	NR
t	NR
u	NR
w	R
x	NR
y	NR
z	R
3	NR
6	NR
7	NR
8	R

774	R
ind1	01
ind2	b8
a	NR
b	NR
c	NR
d	NR
g	R
h	NR
i	NR
k	R
m	NR
n	R
o	R
r	R
s	NR
t	NR
u	NR
w	R
x	NR
y	NR
z	R
6	NR
7	NR
8	R

775	R
ind1	01
ind2	b8012
a	NR
b	NR
c	NR
d	NR
e	NR
f	NR
g	R
h	NR
i	NR
k	R
m	NR
n	R
o	R
r	R
s	NR
t	NR
u	NR
w	R
x	NR
y	NR
z	R
6	NR
7	NR
8	R

776	R
ind1	01
ind2	b8
a	NR
b	NR
c	NR
d	NR
g	R
h	NR
i	NR
k	R
m	NR
n	R
o	R
r	R
s	NR
t	NR
u	NR
w	R
x	NR
y	NR
z	R
6	NR
7	NR
8	R

777	R
ind1	01
ind2	b8
a	NR
b	NR
c	NR
d	NR
g	R
h	NR
i	NR
k	R
m	NR
n	R
o	R
s	NR
t	NR
w	R
x	NR
y	NR
6	NR
7	NR
8	R

780	R
ind1	01
ind2	01234567
a	NR
b	NR
c	NR
d	NR
g	R
h	NR
i	NR
k	R
m	NR
n	R
o	R
r	R
s	NR
t	NR
u	NR
w	R
x	NR
y	NR
z	R
6	NR
7	NR
8	R

785	R
ind1	01
ind2	012345678
a	NR
b	NR
c	NR
d	NR
g	R
h	NR
i	NR
k	R
m	NR
n	R
o	R
r	R
s	NR
t	NR
u	NR
w	R
x	NR
y	NR
z	R
6	NR
7	NR
8	R

786	R
ind1	01
ind2	b8
a	NR
b	NR
c	NR
d	NR
g	R
h	NR
i	NR
j	NR
k	R
m	NR
n	R
o	R
p	NR
r	R
s	NR
t	NR
u	NR
v	NR
w	R
x	NR
y	NR
z	R
6	NR
7	NR
8	R

787	R
ind1	01
ind2	b8
a	NR
b	NR
c	NR
d	NR
g	R
h	NR
i	NR
k	R
m	NR
n	R
o	R
r	R
s	NR
t	NR
u	NR
w	R
x	NR
y	NR
z	R
6	NR
7	NR
8	R

800	R
ind1	013
ind2	blank
a	NR
b	NR
c	R
d	NR
e	R
f	NR
g	NR
h	NR
j	R
k	R
l	NR
m	R
n	R
o	NR
p	R
q	NR
r	NR
s	NR
t	NR
u	NR
v	NR
4	R
6	NR
8	R

810	R
ind1	012
ind2	blank
a	NR
b	R
c	NR
d	R
e	R
f	NR
g	NR
h	NR
k	R
l	NR
m	R
n	R
o	NR
p	R
r	NR
s	NR
t	NR
u	NR
v	NR
4	R
6	NR
8	R

811	R
ind1	012
ind2	blank
a	NR
c	NR
d	NR
e	R
f	NR
g	NR
h	NR
k	R
l	NR
n	R
p	R
q	NR
s	NR
t	NR
u	NR
v	NR
4	R
6	NR
8	R

830	R
ind1	blank
ind2	0-9
a	NR
d	R
f	NR
g	NR
h	NR
k	R
l	NR
m	R
n	R
o	NR
p	R
r	NR
s	NR
t	NR
v	NR
6	NR
8	R

850	R
ind1	blank
ind2	blank
a	R
8	R

852	R
ind1	b012345678
ind2	b012
a	NR
b	R
c	R
e	R
f	R
g	R
h	NR
i	R
j	NR
k	R
l	NR
m	R
n	NR
p	NR
q	NR
s	R
t	NR
x	R
z	R
2	NR
3	NR
6	NR
8	NR

856	R
ind1	b012347
ind2	b0128
a	R
b	R
c	R
d	R
f	R
h	NR
i	R
j	NR
k	NR
l	NR
m	R
n	NR
o	NR
p	NR
q	NR
r	NR
s	R
t	R
u	R
v	R
w	R
x	R
y	R
z	R
2	NR
3	NR
6	NR
8	R

880	R
ind1	
ind2	
6	NR

887	R
ind1	blank
ind2	blank
a	NR
2	NR

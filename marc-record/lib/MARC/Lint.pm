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

	return;
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

	# Set the pointer back to where it was, in case we do this again
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
010	NR	LIBRARY OF CONGRESS CONTROL NUMBER
ind1	blank
ind2	blank
a	NR
b	R
z	R
8	R

013	R	PATENT CONTROL INFORMATION
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

015	R	NATIONAL BIBLIOGRAPHY NUMBER
ind1	blank
ind2	blank
a	R
2	NR
6	NR
8	R

016	R	NATIONAL BIBLIOGRAPHIC AGENCY CONTROL NUMBER
ind1	b7
ind2	blank
a	NR
z	R
2	NR
8	R

017	R	COPYRIGHT OR LEGAL DEPOSIT NUMBER
ind1	blank
ind2	blank
a	R
b	NR
2	NR
6	NR
8	R

018	NR	COPYRIGHT ARTICLE-FEE CODE
ind1	blank
ind2	blank
a	NR
6	NR
8	R

020	R	INTERNATIONAL STANDARD BOOK NUMBER
ind1	blank
ind2	blank
a	NR
c	NR
z	R
6	NR
8	R

022	R	INTERNATIONAL STANDARD SERIAL NUMBER
ind1	b01
ind2	blank
a	NR
y	R
z	R
6	NR
8	R

024	R	OTHER STANDARD IDENTIFIER
ind1	0123478
ind2	b01
a	NR
c	NR
d	NR
z	R
2	NR
6	NR
8	R

025	R	OVERSEAS ACQUISITION NUMBER
ind1	blank
ind2	blank
a	R
8	R

026	R	FINGERPRINT IDENTIFIER
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

027	R	STANDARD TECHNICAL REPORT NUMBER
ind1	blank
ind2	blank
a	NR
z	R
6	NR
8	R

028	R	PUBLISHER NUMBER
ind1	012345
ind2	0123
a	NR
b	NR
6	NR
8	R

030	R	CODEN DESIGNATION
ind1	blank
ind2	blank
a	NR
z	R
6	NR
8	R

032	R	POSTAL REGISTRATION NUMBER
ind1	blank
ind2	blank
a	NR
b	NR
6	NR
8	R

033	R	DATE/TIME AND PLACE OF AN EVENT
ind1	b012
ind2	b012
a	R
b	R
c	R
3	NR
6	NR
8	R

034	R	CODED CARTOGRAPHIC MATHEMATICAL DATA
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

035	R	SYSTEM CONTROL NUMBER
ind1	blank
ind2	blank
a	NR
z	R
6	NR
8	R

036	NR	ORIGINAL STUDY NUMBER FOR COMPUTER DATA FILES
ind1	blank
ind2	blank
a	NR
b	NR
6	NR
8	R

037	R	SOURCE OF ACQUISITION
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

038	NR	RECORD CONTENT LICENSOR
ind1	blank
ind2	blank
a	NR
6	NR
8	R

040	NR	CATALOGING SOURCE
ind1	blank
ind2	blank
a	NR
b	NR
c	NR
d	R
e	NR
6	NR
8	R

041	R	LANGUAGE CODE
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

042	NR	AUTHENTICATION CODE
ind1	blank
ind2	blank
a	R

043	NR	GEOGRAPHIC AREA CODE
ind1	blank
ind2	blank
a	R
b	R
c	R
2	R
6	NR
8	R

044	NR	COUNTRY OF PUBLISHING/PRODUCING ENTITY CODE
ind1	blank
ind2	blank
a	R
b	R
c	R
2	R
6	NR
8	R

045	NR	TIME PERIOD OF CONTENT
ind1	b012
ind2	blank
a	R
b	R
c	R
6	NR
8	R

046	R	SPECIAL CODED DATES
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

047	NR	FORM OF MUSICAL COMPOSITION CODE
ind1	blank
ind2	blank
a	R
8	R

048	R	NUMBER OF MUSICAL INSTRUMENTS OR VOICES CODE
ind1	blank
ind2	blank
a	R
b	R
8	R

050	R	LIBRARY OF CONGRESS CALL NUMBER
ind1	b01
ind2	040123
a	R
b	NR
3	NR
6	NR
8	R

051	R	LIBRARY OF CONGRESS COPY, ISSUE, OFFPRINT STATEMENT
ind1	blank
ind2	b0123
a	NR
b	NR
c	NR
8	R

052	R	GEOGRAPHIC CLASSIFICATION
ind1	b17
ind2	blank
a	NR
b	R
d	R
2	NR
6	NR
8	R

055	R	CLASSIFICATION NUMBERS ASSIGNED IN CANADA
ind1	b01
ind2	0123456789
a	NR
b	NR
2	NR
8	R

060	R	NATIONAL LIBRARY OF MEDICINE CALL NUMBER
ind1	b01
ind2	040123
a	R
b	NR
8	R

061	R	NATIONAL LIBRARY OF MEDICINE COPY STATEMENT
ind1	blank
ind2	b0123
a	R
b	NR
c	NR
8	R

066	NR	CHARACTER SETS PRESENT
ind1	blank
ind2	blank
a	NR
b	NR
c	R

070	R	NATIONAL AGRICULTURAL LIBRARY CALL NUMBER
ind1	01
ind2	b0123
a	R
b	NR
8	R

071	R	NATIONAL AGRICULTURAL LIBRARY COPY STATEMENT
ind1	blank
ind2	b0123
a	R
b	NR
c	NR
8	R

072	R	SUBJECT CATEGORY CODE
ind1	blank
ind2	07
a	NR
x	R
2	NR
6	NR
8	R

074	R	GPO ITEM NUMBER
ind1	blank
ind2	blank
a	NR
z	R
8	R

080	R	UNIVERSAL DECIMAL CLASSIFICATION NUMBER
ind1	blank
ind2	blank
a	NR
b	NR
x	R
2	NR
6	NR
8	R

082	R	DEWEY DECIMAL CLASSIFICATION NUMBER
ind1	01
ind2	b04
a	R
b	NR
2	NR
6	NR
8	R

084	R	OTHER CLASSIFICATION NUMBER
ind1	blank
ind2	blank
a	R
b	NR
2	NR
6	NR
8	R

086	R	GOVERNMENT DOCUMENT CLASSIFICATION NUMBER
ind1	b01
ind2	blank
a	NR
z	R
2	NR
6	NR
8	R

088	R	REPORT NUMBER
ind1	blank
ind2	blank
a	NR
z	R
6	NR
8	R

100	NR	MAIN ENTRY--PERSONAL NAME
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

110	NR	MAIN ENTRY--CORPORATE NAME
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

111	NR	MAIN ENTRY--MEETING NAME
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

130	NR	MAIN ENTRY--UNIFORM TITLE
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

210	R	ABBREVIATED TITLE
ind1	01
ind2	b0
a	NR
b	NR
2	R
6	NR
8	R

222	R	KEY TITLE
ind1	b0123
ind2	0-9
a	NR
b	NR
6	NR
8	R

240	NR	UNIFORM TITLE
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

242	R	TRANSLATION OF TITLE BY CATALOGING AGENCY
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

243	NR	COLLECTIVE UNIFORM TITLE
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

245	NR	TITLE STATEMENT
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

246	R	VARYING FORM OF TITLE
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

247	R	FORMER TITLE
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

250	NR	EDITION STATEMENT
ind1	blank
ind2	blank
a	NR
b	NR
6	NR
8	R

254	NR	MUSICAL PRESENTATION STATEMENT
ind1	blank
ind2	blank
a	NR
6	NR
8	R

255	R	CARTOGRAPHIC MATHEMATICAL DATA
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

256	NR	COMPUTER FILE CHARACTERISTICS
ind1	blank
ind2	blank
a	NR
6	NR
8	R

257	NR	COUNTRY OF PRODUCING ENTITY FOR ARCHIVAL FILMS
ind1	blank
ind2	blank
a	NR
6	NR
8	R

260	R	PUBLICATION, DISTRIBUTION, ETC. (IMPRINT)
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

261	NR	IMPRINT STATEMENT FOR FILMS (Pre-AACR 1 Revised)
ind1	blank
ind2	blank
a	R
b	R
d	R
e	R
f	R
6	NR
8	R

262	NR	IMPRINT STATEMENT FOR SOUND RECORDINGS (Pre-AACR 2)
ind1	blank
ind2	blank
a	NR
b	NR
c	NR
k	NR
l	NR
6	NR
8	R

263	NR	PROJECTED PUBLICATION DATE
ind1	blank
ind2	blank
a	NR
6	NR
8	R

270	R	ADDRESS
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

300	R	PHYSICAL DESCRIPTION
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

306	NR	PLAYING TIME
ind1	blank
ind2	blank
a	R
6	NR
8	R

307	R	HOURS, ETC.
ind1	b8
ind2	blank
a	NR
b	NR
6	NR
8	R

310	NR	CURRENT PUBLICATION FREQUENCY
ind1	blank
ind2	blank
a	NR
b	NR
6	NR
8	R

321	R	FORMER PUBLICATION FREQUENCY
ind1	blank
ind2	blank
a	NR
b	NR
6	NR
8	R

340	R	PHYSICAL MEDIUM
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

342	R	GEOSPATIAL REFERENCE DATA
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

343	R	PLANAR COORDINATE DATA
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

351	R	ORGANIZATION AND ARRANGEMENT OF MATERIALS
ind1	blank
ind2	blank
a	R
b	R
c	NR
3	NR
6	NR
8	R

352	R	DIGITAL GRAPHIC REPRESENTATION
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

355	R	SECURITY CLASSIFICATION CONTROL
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

357	NR	ORIGINATOR DISSEMINATION CONTROL
ind1	blank
ind2	blank
a	NR
b	R
c	R
g	R
6	NR
8	R

362	R	DATES OF PUBLICATION AND/OR SEQUENTIAL DESIGNATION
ind1	01
ind2	blank
a	NR
z	NR
6	NR
8	R

400	R	SERIES STATEMENT/ADDED ENTRY--PERSONAL NAME 
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

410	R	SERIES STATEMENT/ADDED ENTRY--CORPORATE NAME
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

411	R	SERIES STATEMENT/ADDED ENTRY--MEETING NAME
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

440	R	SERIES STATEMENT/ADDED ENTRY--TITLE
ind1	blank
ind2	0-9
a	NR
n	R
p	R
v	NR
x	NR
6	NR
8	R

490	R	SERIES STATEMENT
ind1	01
ind2	blank
a	R
l	NR
v	R
x	NR
6	NR
8	R

500	R	GENERAL NOTE
ind1	blank
ind2	blank
a	NR
3	NR
5	NR
6	NR
8	R

501	R	WITH NOTE
ind1	blank
ind2	blank
a	NR
5	NR
6	NR
8	R

502	R	DISSERTATION NOTE
ind1	blank
ind2	blank
a	NR
6	NR
8	R

504	R	BIBLIOGRAPHY, ETC. NOTE
ind1	blank
ind2	blank
a	NR
b	NR
6	NR
8	R

505	R	FORMATTED CONTENTS NOTE
ind1	0128
ind2	b0
a	NR
g	R
r	R
t	R
u	R
6	NR
8	R

506	R	RESTRICTIONS ON ACCESS NOTE
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

507	NR	SCALE NOTE FOR GRAPHIC MATERIAL
ind1	blank
ind2	blank
a	NR
b	NR
6	NR
8	R

508	R	CREATION/PRODUCTION CREDITS NOTE
ind1	blank
ind2	blank
a	NR
6	NR
8	R

510	R	CITATION/REFERENCES NOTE
ind1	01234
ind2	blank
a	NR
b	NR
c	NR
x	NR
3	NR
6	NR
8	R

511	R	PARTICIPANT OR PERFORMER NOTE
ind1	01
ind2	blank
a	NR
6	NR
8	R

513	R	TYPE OF REPORT AND PERIOD COVERED NOTE
ind1	blank
ind2	blank
a	NR
b	NR
6	NR
8	R

514	NR	DATA QUALITY NOTE
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

515	R	NUMBERING PECULIARITIES NOTE
ind1	blank
ind2	blank
a	NR
6	NR
8	R

516	R	TYPE OF COMPUTER FILE OR DATA NOTE
ind1	b8
ind2	blank
a	NR
6	NR
8	R

518	R	DATE/TIME AND PLACE OF AN EVENT NOTE
ind1	blank
ind2	blank
a	NR
3	NR
6	NR
8	R

520	R	SUMMARY, ETC.
ind1	b01238
ind2	blank
a	NR
b	NR
u	R
3	NR
6	NR
8	R

521	R	TARGET AUDIENCE NOTE
ind1	b012348
ind2	blank
a	R
b	NR
3	NR
6	NR
8	R

522	R	GEOGRAPHIC COVERAGE NOTE
ind1	b8
ind2	blank
a	NR
6	NR
8	R

524	R	PREFERRED CITATION OF DESCRIBED MATERIALS NOTE
ind1	b8
ind2	blank
a	NR
2	NR
3	NR
6	NR
8	R

525	R	SUPPLEMENT NOTE
ind1	blank
ind2	blank
a	NR
6	NR
8	R

526	R	STUDY PROGRAM INFORMATION NOTE
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

530	R	ADDITIONAL PHYSICAL FORM AVAILABLE NOTE
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

533	R	REPRODUCTION NOTE
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

534	R	ORIGINAL VERSION NOTE
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

535	R	LOCATION OF ORIGINALS/DUPLICATES NOTE
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

536	R	FUNDING INFORMATION NOTE
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

538	R	SYSTEM DETAILS NOTE
ind1	blank
ind2	blank
a	NR
6	NR
8	R

540	R	TERMS GOVERNING USE AND REPRODUCTION NOTE
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

541	R	IMMEDIATE SOURCE OF ACQUISITION NOTE
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

544	R	LOCATION OF OTHER ARCHIVAL MATERIALS NOTE
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

545	R	BIOGRAPHICAL OR HISTORICAL DATA
ind1	b01
ind2	blank
a	NR
b	NR
u	R
6	NR
8	R

546	R	LANGUAGE NOTE
ind1	blank
ind2	blank
a	NR
b	R
3	NR
6	NR
8	R

547	R	FORMER TITLE COMPLEXITY NOTE
ind1	blank
ind2	blank
a	NR
6	NR
8	R

550	R	ISSUING BODY NOTE
ind1	blank
ind2	b01
a	NR
6	NR
8	R

552	R	ENTITY AND ATTRIBUTE INFORMATION NOTE
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

555	R	CUMULATIVE INDEX/FINDING AIDS NOTE
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

556	R	INFORMATION ABOUT DOCUMENTATION NOTE
ind1	b8
ind2	blank
a	NR
z	R
6	NR
8	R

561	R	OWNERSHIP AND CUSTODIAL HISTORY
ind1	blank
ind2	blank
a	NR
3	NR
5	NR
6	NR
8	R

562	R	COPY AND VERSION IDENTIFICATION NOTE
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

563	R	BINDING INFORMATION
ind1	blank
ind2	blank
a	NR
u	R
3	NR
5	NR
6	NR
8	R

565	R	CASE FILE CHARACTERISTICS NOTE
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

567	R	METHODOLOGY NOTE
ind1	b8
ind2	blank
a	NR
6	NR
8	R

580	R	LINKING ENTRY COMPLEXITY NOTE
ind1	blank
ind2	blank
a	NR
6	NR
8	R

581	R	PUBLICATIONS ABOUT DESCRIBED MATERIALS NOTE
ind1	b8
ind2	blank
a	NR
z	R
3	NR
6	NR
8	R

583	R	ACTION NOTE
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

584	R	ACCUMULATION AND FREQUENCY OF USE NOTE
ind1	blank
ind2	blank
a	R
b	R
3	NR
5	NR
6	NR
8	R

585	R	EXHIBITIONS NOTE
ind1	blank
ind2	blank
a	NR
3	NR
5	NR
6	NR
8	R

586	R	AWARDS NOTE
ind1	b8
ind2	blank
a	NR
3	NR
6	NR
8	R

600	R	SUBJECT ADDED ENTRY--PERSONAL NAME
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

610	R	SUBJECT ADDED ENTRY--CORPORATE NAME
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

611	R	SUBJECT ADDED ENTRY--MEETING NAME
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

630	R	SUBJECT ADDED ENTRY--UNIFORM TITLE
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

648	R	SUBJECT ADDED ENTRY--CHRONOLOGICAL TERM
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

650	R	SUBJECT ADDED ENTRY--TOPICAL TERM
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

651	R	SUBJECT ADDED ENTRY--GEOGRAPHIC NAME
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

653	R	INDEX TERM--UNCONTROLLED
ind1	b012
ind2	blank
a	R
6	NR
8	R

654	R	SUBJECT ADDED ENTRY--FACETED TOPICAL TERMS
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

655	R	INDEX TERM--GENRE/FORM
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

656	R	INDEX TERM--OCCUPATION
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

657	R	INDEX TERM--FUNCTION
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

658	R	INDEX TERM--CURRICULUM OBJECTIVE
ind1	blank
ind2	blank
a	NR
b	R
c	NR
d	NR
2	NR
6	NR
8	R

700	R	ADDED ENTRY--PERSONAL NAME
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

710	R	ADDED ENTRY--CORPORATE NAME
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

711	R	ADDED ENTRY--MEETING NAME
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

720	R	ADDED ENTRY--UNCONTROLLED NAME
ind1	b12
ind2	blank
a	NR
e	R
4	R
6	NR
8	R

730	R	ADDED ENTRY--UNIFORM TITLE
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

740	R	ADDED ENTRY--UNCONTROLLED RELATED/ANALYTICAL TITLE
ind1	0-9
ind2	b2
a	NR
h	NR
n	R
p	R
5	NR
6	NR
8	R

752	R	ADDED ENTRY--HIERARCHICAL PLACE NAME
ind1	blank
ind2	blank
a	NR
b	NR
c	NR
d	NR
6	NR
8	R

753	R	SYSTEM DETAILS ACCESS TO COMPUTER FILES
ind1	blank
ind2	blank
a	NR
b	NR
c	NR
6	NR
8	R

754	R	ADDED ENTRY--TAXONOMIC IDENTIFICATION
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

760	R	MAIN SERIES ENTRY
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

762	R	SUBSERIES ENTRY
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

765	R	ORIGINAL LANGUAGE ENTRY
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

767	R	TRANSLATION ENTRY
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

770	R	SUPPLEMENT/SPECIAL ISSUE ENTRY
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

772	R	SUPPLEMENT PARENT ENTRY
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

773	R	HOST ITEM ENTRY
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

774	R	CONSTITUENT UNIT ENTRY
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

775	R	OTHER EDITION ENTRY
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

776	R	ADDITIONAL PHYSICAL FORM ENTRY
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

777	R	ISSUED WITH ENTRY
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

780	R	PRECEDING ENTRY
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

785	R	SUCCEEDING ENTRY
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

786	R	DATA SOURCE ENTRY
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

787	R	NONSPECIFIC RELATIONSHIP ENTRY
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

800	R	SERIES ADDED ENTRY--PERSONAL NAME
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

810	R	SERIES ADDED ENTRY--CORPORATE NAME
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

811	R	SERIES ADDED ENTRY--MEETING NAME
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

830	R	SERIES ADDED ENTRY--UNIFORM TITLE
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

841	NR	HOLDINGS CODED DATA VALUES

842	NR	TEXTUAL PHYSICAL FORM DESIGNATOR

843	R	REPRODUCTION NOTE

844	NR	NAME OF UNIT

845	R	TERMS GOVERNING USE AND REPRODUCTION NOTE

850	R	HOLDING INSTITUTION
ind1	blank
ind2	blank
a	R
8	R

852	R	LOCATION
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

853	R	CAPTIONS AND PATTERN--BASIC BIBLIOGRAPHIC UNIT

854	R	CAPTIONS AND PATTERN--SUPPLEMENTARY MATERIAL

855	R	CAPTIONS AND PATTERN--INDEXES

856	R	ELECTRONIC LOCATION AND ACCESS
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

863	R	ENUMERATION AND CHRONOLOGY--BASIC BIBLIOGRAPHIC UNIT

864	R	ENUMERATION AND CHRONOLOGY--SUPPLEMENTARY MATERIAL

865	R	ENUMERATION AND CHRONOLOGY--INDEXES

866	R	TEXTUAL HOLDINGS--BASIC BIBLIOGRAPHIC UNIT

867	R	TEXTUAL HOLDINGS--SUPPLEMENTARY MATERIAL

868	R	TEXTUAL HOLDINGS--INDEXES

876	R	ITEM INFORMATION--BASIC BIBLIOGRAPHIC UNIT

877	R	ITEM INFORMATION--SUPPLEMENTARY MATERIAL

878	R	ITEM INFORMATION--INDEXES

880	R	ALTERNATE GRAPHIC REPRESENTATION
ind1	
ind2	
6	NR

886	R	FOREIGN MARC INFORMATION FIELD
ind1	012
ind2	blank
a	NR
b	NR
2	NR

887	R	NON-MARC INFORMATION FIELD
ind1	blank
ind2	blank
a	NR
2	NR

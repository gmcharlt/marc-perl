package MARC::Lint;

use strict;
use integer;

=head1 NAME

MARC::Lint - Perl extension for checking validity of MARC records

=head1 SYNOPSIS

    use MARC::File::USMARC;
    use MARC::Lint;

    my $lint = new MARC::Lint;
    my $filename = shift;

    my $file = MARC::File::USMARC->in( $filename );
    while ( my $marc = $file->next() ) {
	$lint->check_record( $marc );

	# Print the title tag
	print $marc->title, "\n";

	# Print the errors that were found
	print join( "\n", $linter->warnings ), "\n";
    } # while

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

	my @_1xx = $marc->field( "1.." );
	my $n1xx = scalar @_1xx;
	if ( $n1xx > 1 ) {
		$self->warn( "1XX: Only one 1XX tag is allowed, but I found $n1xx of them." );
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
    while ( my $tagblock = <DATA> ) {
	my @lines = split( /\n/, $tagblock );
	s/\s+$// for @lines;

	next unless @lines >= 4; # Some of our entries are tag-only
	
	my $tagline = shift @lines;
	my @keyvals = split( /\s+/, $tagline, 3 );
	my $tagno = shift @keyvals;
	my $repeatable = shift @keyvals;
	
	$self->_parse_tag_rules( $tagno, $repeatable, @lines );
    } # while

    # Set the pointer back to where it was, in case we do this again
    seek( DATA, $tell, 0 );
}

sub _parse_tag_rules {
	my $self = shift;
	my $tagno = shift;
	my $repeatable = shift;
	my @lines = @_;

	my $rules = ($self->{_rules}->{$tagno} ||= {});
	$rules->{$repeatable} = $repeatable;

	for ( @lines ) {
		my @keyvals = split( /\s+/, $_, 3 );
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
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	LC control number
b	R	NUCMC control number
z	R	Canceled/invalid LC control number
8	R	Field link and sequence number

013	R	PATENT CONTROL INFORMATION
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Number
b	NR	Country
c	NR	Type of number
d	R	Date
e	R	Status
f	R	Party to document
6	NR	Linkage
8	R	Field link and sequence number

015	R	NATIONAL BIBLIOGRAPHY NUMBER
ind1	blank	Undefined
ind2	blank	Undefined
a	R	National bibliography number
2	NR	Source
6	NR	Linkage
8	R	Field link and sequence number

016	R	NATIONAL BIBLIOGRAPHIC AGENCY CONTROL NUMBER
ind1	b7	National bibliographic agency
ind2	blank	Undefined
a	NR	Record control number
z	R	Canceled or invalid record control number
2	NR	Source
8	R	Field link and sequence number

017	R	COPYRIGHT OR LEGAL DEPOSIT NUMBER
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Copyright registration number
b	NR	Assigning agency
2	NR	Source
6	NR	Linkage
8	R	Field link and sequence number

018	NR	COPYRIGHT ARTICLE-FEE CODE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Copyright article-fee code
6	NR	Linkage
8	R	Field link and sequence number

020	R	INTERNATIONAL STANDARD BOOK NUMBER
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	International Standard Book Number
c	NR	Terms of availability
z	R	Canceled/invalid ISBN
6	NR	Linkage
8	R	Field link and sequence number

022	R	INTERNATIONAL STANDARD SERIAL NUMBER
ind1	b01	Level of international interest
ind2	blank	Undefined
a	NR	International Standard Serial Number
y	R	Incorrect ISSN
z	R	Canceled ISSN
6	NR	Linkage
8	R	Field link and sequence number

024	R	OTHER STANDARD IDENTIFIER
ind1	0123478	Type of standard number or code
ind2	b01	Difference indicator
a	NR	Standard number or code
c	NR	Terms of availability
d	NR	Additional codes following the standard number or code
z	R	Canceled/invalid standard number or code
2	NR	Source of number or code
6	NR	Linkage
8	R	Field link and sequence number

025	R	OVERSEAS ACQUISITION NUMBER
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Overseas acquisition number
8	R	Field link and sequence number

026	R	FINGERPRINT IDENTIFIER
ind1	blank	Undefined
ind2	blank	Undefined
a	R	First and second groups of characters
b	R	Third and fourth groups of characters
c	NR	Date
d	R	Number of volume or part
e	NR	Unparsed fingerprint
2	NR	Source
5	R	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

027	R	STANDARD TECHNICAL REPORT NUMBER
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Standard technical report number
z	R	Canceled/invalid number
6	NR	Linkage
8	R	Field link and sequence number

028	R	PUBLISHER NUMBER
ind1	012345	Type of publisher number
ind2	0123	Note/added entry controller
a	NR	Publisher number
b	NR	Source
6	NR	Linkage
8	R	Field link and sequence number

030	R	CODEN DESIGNATION
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	CODEN
z	R	Canceled/invalid CODEN
6	NR	Linkage
8	R	Field link and sequence number

032	R	POSTAL REGISTRATION NUMBER
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Postal registration number
b	NR	Source (agency assigning number)
6	NR	Linkage
8	R	Field link and sequence number

033	R	DATE/TIME AND PLACE OF AN EVENT
ind1	b012	Type of date in subfield $a
ind2	b012	Type of event
a	R	Formatted date/time
b	R	Geographic classification area code
c	R	Geographic classification subarea code
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

034	R	CODED CARTOGRAPHIC MATHEMATICAL DATA
ind1	013	Type of scale
ind2	b01	Type of ring
a	NR	Category of scale
b	R	Constant ratio linear horizontal scale
c	R	Constant ratio linear vertical scale
d	NR	Coordinates--westernmost longitude
e	NR	Coordinates--easternmost longitude
f	NR	Coordinates--northernmost latitude
g	NR	Coordinates--southernmost latitude
h	R	Angular scale
j	NR	Declination--northern limit
k	NR	Declination--southern limit
m	NR	Right ascension--eastern limit
n	NR	Right ascension--western limit
p	NR	Equinox
s	R	G-ring latitude
t	R	G-ring longitude
6	NR	Linkage
8	R	Field link and sequence number

035	R	SYSTEM CONTROL NUMBER
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	System control number
z	R	Canceled/invalid control number
6	NR	Linkage
8	R	Field link and sequence number

036	NR	ORIGINAL STUDY NUMBER FOR COMPUTER DATA FILES
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Original study number
b	NR	Source (agency assigning number)
6	NR	Linkage
8	R	Field link and sequence number

037	R	SOURCE OF ACQUISITION
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Stock number
b	NR	Source of stock number/acquisition
c	R	Terms of availability
f	R	Form of issue
g	R	Additional format characteristics
n	R	Note
6	NR	Linkage
8	R	Field link and sequence number

038	NR	RECORD CONTENT LICENSOR
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Record content licensor
6	NR	Linkage
8	R	Field link and sequence number

040	NR	CATALOGING SOURCE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Original cataloging agency
b	NR	Language of cataloging
c	NR	Transcribing agency
d	R	Modifying agency
e	NR	Description conventions
6	NR	Linkage
8	R	Field link and sequence number

041	R	LANGUAGE CODE
ind1	01	Translation indication
ind2	b7	Source of code
a	R	Language code of text/sound track or separate title
b	R	Language code of summary or abstract/overprinted title or subtitle
d	R	Language code of sung or spoken text
e	R	Language code of librettos
f	R	Language code of table of contents
g	R	Language code of accompanying material other than librettos
h	R	Language code of original and/or intermediate translations of text
2	NR	Source of code
6	NR	Linkage
8	R	Field link and sequence number

042	NR	AUTHENTICATION CODE
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Authentication code

043	NR	GEOGRAPHIC AREA CODE
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Geographic area code
b	R	Local GAC code
c	R	ISO code
2	R	Source of local code
6	NR	Linkage
8	R	Field link and sequence number

044	NR	COUNTRY OF PUBLISHING/PRODUCING ENTITY CODE
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Country of publishing/producing entity code
b	R	Local subentity code
c	R	ISO code
2	R	Source of local subentity code
6	NR	Linkage
8	R	Field link and sequence number

045	NR	TIME PERIOD OF CONTENT
ind1	b012	Type of time period in subfield $b or $c
ind2	blank	Undefined
a	R	Time period code
b	R	Formatted 9999 B.C. through C.E. time period
c	R	Formatted pre-9999 B.C. time period
6	NR	Linkage
8	R	Field link and sequence number

046	R	SPECIAL CODED DATES
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Type of date code
b	NR	Date 1 (B.C. date)
c	NR	Date 1 (C.E. date)
d	NR	Date 2 (B.C. date)
e	NR	Date 2 (C.E. date)
j	NR	Date resource modified
k	NR	Beginning or single date created
l	NR	Ending date created
m	NR	Beginning of date valid
n	NR	End of date valid
2	NR	Source of date
6	NR	Linkage
8	R	Field link and sequence number

047	NR	FORM OF MUSICAL COMPOSITION CODE
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Form of musical composition code
8	R	Field link and sequence number

048	R	NUMBER OF MUSICAL INSTRUMENTS OR VOICES CODE
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Performer or ensemble
b	R	Soloist

050	R	LIBRARY OF CONGRESS CALL NUMBER
ind1	b01	Existence in LC collection
ind2	040123	Source of call number
a	R	Classification number
b	NR	Item number
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

051	R	LIBRARY OF CONGRESS COPY, ISSUE, OFFPRINT STATEMENT
ind1	blank	Undefined
ind2	b0123	Undefined
a	NR	Classification number
b	NR	Item number
c	NR	Copy information
8	R	Field link and sequence number

052	R	GEOGRAPHIC CLASSIFICATION
ind1	b17	Code source
ind2	blank	Undefined
a	NR	Geographic classification area code
b	R	Geographic classification subarea code
d	R	Populated place name
2	NR	Code source
6	NR	Linkage
8	R	Field link and sequence number

055	R	CLASSIFICATION NUMBERS ASSIGNED IN CANADA
ind1	b01	Existence in NLC collection
ind2	0123456789	Type, completeness, source of class/call number
a	NR	Classification number
b	NR	Item number
2	NR	Source of call/class number
8	R	Field link and sequence number

060	R	NATIONAL LIBRARY OF MEDICINE CALL NUMBER
ind1	b01	Existence in NLM collection
ind2	040123	Source of call number
a	R	Classification number
b	NR	Item number
8	R	Field link and sequence number

061	R	NATIONAL LIBRARY OF MEDICINE COPY STATEMENT
ind1	blank	Undefined
ind2	b0123	Undefined
a	R	Classification number
b	NR	Item number
c	NR	Copy information
8	R	Field link and sequence number

066	NR	CHARACTER SETS PRESENT
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Primary G0 character set
b	NR	Primary G1 character set
c	R	Alternate G0 or G1 character set

070	R	NATIONAL AGRICULTURAL LIBRARY CALL NUMBER
ind1	01	Existence in NAL collection
ind2	b0123	Undefined
a	R	Classification number
b	NR	Item number
8	R	Field link and sequence number

071	R	NATIONAL AGRICULTURAL LIBRARY COPY STATEMENT
ind1	blank	Undefined
ind2	b0123	Undefined
a	R	Classification number
b	NR	Item number
c	NR	Copy information
8	R	Field link and sequence number

072	R	SUBJECT CATEGORY CODE
ind1	blank	Undefined
ind2	07	Code source
a	NR	Subject category code
x	R	Subject category code subdivision
2	NR	Code source
6	NR	Linkage
8	R	Field link and sequence number

074	R	GPO ITEM NUMBER
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	GPO item number
z	R	Canceled/invalid GPO item number
8	R	Field link and sequence number

080	R	UNIVERSAL DECIMAL CLASSIFICATION NUMBER
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Universal Decimal Classification number
b	NR	Item number
x	R	Common auxiliary subdivision
2	NR	Edition identifier
6	NR	Linkage
8	R	Field link and sequence number

082	R	DEWEY DECIMAL CLASSIFICATION NUMBER
ind1	01	Type of edition
ind2	b04	Source of classification number
a	R	Classification number
b	NR	Item number
2	NR	Edition number
6	NR	Linkage
8	R	Field link and sequence number

084	R	OTHER CLASSIFICATION NUMBER
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Classification number
b	NR	Item number
2	NR	Source of number
6	NR	Linkage
8	R	Field link and sequence number

086	R	GOVERNMENT DOCUMENT CLASSIFICATION NUMBER
ind1	b01	Number source
ind2	blank	Undefined
a	NR	Classification number
z	R	Canceled/invalid classification number
2	NR	Number source
6	NR	Linkage
8	R	Field link and sequence number

088	R	REPORT NUMBER
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Report number
z	R	Canceled/invalid report number
6	NR	Linkage
8	R	Field link and sequence number

100	NR	MAIN ENTRY--PERSONAL NAME
ind1	013	Type of personal name entry element
ind2	blank	Undefined
a	NR	Personal name
b	NR	Numeration
c	R	Titles and other words associated with a name
d	NR	Dates associated with a name
e	R	Relator term
f	NR	Date of a work
g	NR	Miscellaneous information
j	R	Attribution qualifier
k	R	Form subheading
l	NR	Language of a work
n	R	Number of part/section of a work
p	R	Name of part/section of a work
q	NR	Fuller form of name
t	NR	Title of a work
u	NR	Affiliation
4	R	Relator code
6	NR	Linkage
8	R	Field link and sequence number

110	NR	MAIN ENTRY--CORPORATE NAME
ind1	012	Type of corporate name entry element
ind2	blank	Undefined
a	NR	Corporate name or jurisdiction name as entry element
b	R	Subordinate unit
c	NR	Location of meeting
d	R	Date of meeting or treaty signing
e	R	Relator term
f	NR	Date of a work
g	NR	Miscellaneous information
k	R	Form subheading
l	NR	Language of a work
n	R	Number of part/section/meeting
p	R	Name of part/section of a work
t	NR	Title of a work
u	NR	Affiliation
4	R	Relator code
6	NR	Linkage
8	R	Field link and sequence number

111	NR	MAIN ENTRY--MEETING NAME
ind1	012	Type of meeting name entry element
ind2	blank	Undefined
a	NR	Meeting name or jurisdiction name as entry element
c	NR	Location of meeting
d	NR	Date of meeting
e	R	Subordinate unit
f	NR	Date of a work
g	NR	Miscellaneous information
k	R	Form subheading
l	NR	Language of a work
n	R	Number of part/section/meeting
p	R	Name of part/section of a work
q	NR	Name of meeting following jurisdiction name entry element
t	NR	Title of a work
u	NR	Affiliation
4	R	Relator code
6	NR	Linkage
8	R	Field link and sequence number

130	NR	MAIN ENTRY--UNIFORM TITLE
ind1	0-9	Nonfiling characters
ind2	blank	Undefined
a	NR	Uniform title
d	R	Date of treaty signing
f	NR	Date of a work
g	NR	Miscellaneous information
h	NR	Medium
k	R	Form subheading
l	NR	Language of a work
m	R	Medium of performance for music
n	R	Number of part/section of a work
o	NR	Arranged statement for music
p	R	Name of part/section of a work
r	NR	Key for music
s	NR	Version
t	NR	Title of a work
6	NR	Linkage
8	R	Field link and sequence number

210	R	ABBREVIATED TITLE
ind1	01	Title added entry
ind2	b0	Type
a	NR	Abbreviated title
b	NR	Qualifying information
2	R	Source
6	NR	Linkage
8	R	Field link and sequence number

222	R	KEY TITLE
ind1	b0123	Specifies whether variant title and/or added entry is required
ind2	0-9	Nonfiling characters
a	NR	Key title
b	NR	Qualifying information
6	NR	Linkage
8	R	Field link and sequence number

240	NR	UNIFORM TITLE
ind1	01	Uniform title printed or displayed
ind2	0-9	Nonfiling characters
a	NR	Uniform title
d	R	Date of treaty signing
f	NR	Date of a work
g	NR	Miscellaneous information
h	NR	Medium
k	R	Form subheading
l	NR	Language of a work
m	R	Medium of performance for music
n	R	Number of part/section of a work
o	NR	Arranged statement for music
p	R	Name of part/section of a work
r	NR	Key for music
s	NR	Version
6	NR	Linkage
8	R	Field link and sequence number

242	R	TRANSLATION OF TITLE BY CATALOGING AGENCY
ind1	01	Title added entry
ind2	0-9	Nonfiling characters
a	NR	Title
b	NR	Remainder of title
c	NR	Statement of responsibility, etc.
h	NR	Medium
n	R	Number of part/section of a work
p	R	Name of part/section of a work
y	NR	Language code of translated title
6	NR	Linkage
8	R	Field link and sequence number

243	NR	COLLECTIVE UNIFORM TITLE
ind1	01	Uniform title printed or displayed
ind2	0-9	Nonfiling characters
a	NR	Uniform title
d	R	Date of treaty signing
f	NR	Date of a work
g	NR	Miscellaneous information
h	NR	Medium
k	R	Form subheading
l	NR	Language of a work
m	NR	Medium of performance for music
n	R	Number of part/section of a work
o	NR	Arranged statement for music
p	R	Name of part/section of a work
r	NR	Key for music
s	NR	Version
6	NR	Linkage
8	R	Field link and sequence number

245	NR	TITLE STATEMENT
ind1	01	Title added entry
ind2	0-9	Nonfiling characters
a	NR	Title
b	NR	Remainder of title
c	NR	Statement of responsibility, etc.
f	NR	Inclusive dates
g	NR	Bulk dates
h	NR	Medium
k	R	Form
n	R	Number of part/section of a work
p	R	Name of part/section of a work
s	NR	Version
6	NR	Linkage
8	R	Field link and sequence number

246	R	VARYING FORM OF TITLE
ind1	0123	Note/added entry controller
ind2	b012345678	Type of title
a	NR	Title proper/short title
b	NR	Remainder of title
f	NR	Date or sequential designation
g	NR	Miscellaneous information
h	NR	Medium
i	NR	Display text
n	R	Number of part/section of a work
p	R	Name of part/section of a work
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

247	R	FORMER TITLE
ind1	01	Title added entry
ind2	01	Note controller
a	NR	Title
b	NR	Remainder of title
f	NR	Date or sequential designation
g	NR	Miscellaneous information
h	NR	Medium
n	R	Number of part/section of a work
p	R	Name of part/section of a work
x	NR	International Standard Serial Number
6	NR	Linkage
8	R	Field link and sequence number

250	NR	EDITION STATEMENT
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Edition statement
6	NR	Linkage
8	R	Field link and sequence number

254	NR	MUSICAL PRESENTATION STATEMENT
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Musical presentation statement
6	NR	Linkage
8	R	Field link and sequence number

255	R	CARTOGRAPHIC MATHEMATICAL DATA
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Statement of scale
b	NR	Statement of projection
c	NR	Statement of coordinates
d	NR	Statement of zone
e	NR	Statement of equinox
f	NR	Outer G-ring coordinate pairs
g	NR	Exclusion G-ring coordinate pairs
6	NR	Linkage
8	R	Field link and sequence number

256	NR	COMPUTER FILE CHARACTERISTICS
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Computer file characteristics
6	NR	Linkage
8	R	Field link and sequence number

257	NR	COUNTRY OF PRODUCING ENTITY FOR ARCHIVAL FILMS
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Country of producing entity
6	NR	Linkage
8	R	Field link and sequence number

260	R	PUBLICATION, DISTRIBUTION, ETC. (IMPRINT)
ind1	b23	Sequence of publishing statements
ind2	b0101	Undefined
a	R	Place of publication, distribution, etc.
b	R	Name of publisher, distributor, etc.
c	R	Date of publication, distribution, etc.
d	R	Plates of publisher's number for music (Pre-AACR 2)
e	NR	Place of manufacture
f	NR	Manufacturer
g	NR	Date of manufacture
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

261	NR	IMPRINT STATEMENT FOR FILMS (Pre-AACR 1 Revised)
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Producing company
b	R	Releasing company (primary distributor)
d	R	Date of production, release, etc.
e	R	Contractual producer
f	R	Place of production, release, etc.
6	NR	Linkage
8	R	Field link and sequence number

262	NR	IMPRINT STATEMENT FOR SOUND RECORDINGS (Pre-AACR 2)
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Place of production, release, etc.
b	NR	Publisher or trade name
c	NR	Date of production, release, etc.
k	NR	Serial identification
l	NR	Matrix and/or take number
6	NR	Linkage
8	R	Field link and sequence number

263	NR	PROJECTED PUBLICATION DATE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Projected publication date
6	NR	Linkage
8	R	Field link and sequence number

270	R	ADDRESS
ind1	b12	Level
ind2	b07	Type of address
a	R	Address
b	NR	City
c	NR	State or province
d	NR	Country
e	NR	Postal code
f	NR	Terms preceding attention name
g	NR	Attention name
h	NR	Attention position
i	NR	Type of address
j	R	Specialized telephone number
k	R	Telephone number
l	R	Fax number
m	R	Electronic mail address
n	R	TDD or TTY number
p	R	Contact person
q	R	Title of contact person
r	R	Hours
z	R	Public note
4	R	Relator code
6	NR	Linkage
8	R	Field link and sequence number

300	R	PHYSICAL DESCRIPTION
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Extent
b	NR	Other physical details
c	R	Dimensions
e	NR	Accompanying material
f	R	Type of unit
g	R	Size of unit
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

306	NR	PLAYING TIME
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Playing time
6	NR	Linkage
8	R	Field link and sequence number

307	R	HOURS, ETC.
ind1	b8	Display constant controller
ind2	blank	Undefined
a	NR	Hours
b	NR	Additional information
6	NR	Linkage
8	R	Field link and sequence number

310	NR	CURRENT PUBLICATION FREQUENCY
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Current publication frequency
b	NR	Date of current publication frequency
6	NR	Linkage
8	R	Field link and sequence number

321	R	FORMER PUBLICATION FREQUENCY
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Former publication frequency
b	NR	Dates of former publication frequency
6	NR	Linkage
8	R	Field link and sequence number

340	R	PHYSICAL MEDIUM
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Material base and configuration
b	R	Dimensions
c	R	Materials applied to surface
d	R	Information recording technique
e	R	Support
f	R	Production rate/ratio
h	R	Location within medium
i	R	Technical specifications of medium
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

342	R	GEOSPATIAL REFERENCE DATA
ind1	01	Geospatial reference dimension
ind2	012345678	Geospatial reference method
a	NR	Name
b	NR	Coordinate or distance units
c	NR	Latitude resolution
d	NR	Longitude resolution
e	R	Standard parallel or oblique line latitude
f	R	Oblique line longitude
g	NR	Longitude of central meridian or projection center
h	NR	Latitude of projection origin or projection center
i	NR	False easting
j	NR	False northing
k	NR	Scale factor
l	NR	Height of perspective point above surface
m	NR	Azimuthal angle
o	NR	Landsat number and path number
p	NR	Zone identifier
q	NR	Ellipsoid name
r	NR	Semi-major axis
s	NR	Denominator of flattening ratio
t	NR	Vertical resolution
u	NR	Vertical encoding method
v	NR	Local planar, local, or other projection or grid description
w	NR	Local planar or local georeference information
2	NR	Reference method used
6	NR	Linkage
8	R	Field link and sequence number

343	R	PLANAR COORDINATE DATA
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Planar coordinate encoding method
b	NR	Planar distance units
c	NR	Abscissa resolution
d	NR	Ordinate resolution
e	NR	Distance resolution
f	NR	Bearing resolution
g	NR	Bearing units
h	NR	Bearing reference direction
i	NR	Bearing reference meridian
6	NR	Linkage
8	R	Field link and sequence number

351	R	ORGANIZATION AND ARRANGEMENT OF MATERIALS
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Organization
b	R	Arrangement
c	NR	Hierarchical level
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

352	R	DIGITAL GRAPHIC REPRESENTATION
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Direct reference method
b	R	Object type
c	R	Object count
d	NR	Row count
e	NR	Column count
f	NR	Vertical count
g	NR	VPF topology level
i	NR	Indirect reference description
6	NR	Linkage
8	R	Field link and sequence number

355	R	SECURITY CLASSIFICATION CONTROL
ind1	0123458	Controlled element
ind2	blank	Undefined
a	NR	Security classification
b	R	Handling instructions
c	R	External dissemination information
d	NR	Downgrading or declassification event
e	NR	Classification system
f	NR	Country of origin code
g	NR	Downgrading date
h	NR	Declassification date
j	R	Authorization
6	NR	Linkage
8	R	Field link and sequence number

357	NR	ORIGINATOR DISSEMINATION CONTROL
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Originator control term
b	R	Originating agency
c	R	Authorized recipients of material
g	R	Other restrictions
6	NR	Linkage
8	R	Field link and sequence number

362	R	DATES OF PUBLICATION AND/OR SEQUENTIAL DESIGNATION
ind1	01	Format of date
ind2	blank	Undefined
a	NR	Dates of publication and/or sequential designation
z	NR	Source of information
6	NR	Linkage
8	R	Field link and sequence number

400	R	SERIES STATEMENT/ADDED ENTRY--PERSONAL NAME 
ind1	013	Type of personal name entry element
ind2	01	Pronoun represents main entry
a	NR	Personal name
b	NR	Numeration
c	R	Titles and other words associated with a name
d	NR	Dates associated with a name
e	R	Relator term
f	NR	Date of a work
g	NR	Miscellaneous information
k	R	Form subheading
l	NR	Language of a work
n	R	Number of part/section of a work
p	R	Name of part/section of a work
t	NR	Title of a work
u	NR	Affiliation
v	NR	Volume number/sequential designation 
x	NR	International Standard Serial Number 
4	R	Relator code
6	NR	Linkage
8	R	Field link and sequence number 

410	R	SERIES STATEMENT/ADDED ENTRY--CORPORATE NAME
ind1	012	Type of corporate name entry element
ind2	01	Pronoun represents main entry
a	NR	Corporate name or jurisdiction name as entry element
b	R	Subordinate unit
c	NR	Location of meeting
d	R	Date of meeting or treaty signing
e	R	Relator term
f	NR	Date of a work
g	NR	Miscellaneous information
k	R	Form subheading
l	NR	Language of a work
n	R	Number of part/section/meeting
p	R	Name of part/section of a work
t	NR	Title of a work
u	NR	Affiliation
v	NR	Volume number/sequential designation 
x	NR	International Standard Serial Number
4	R	Relator code
6	NR	Linkage
8	R	Field link and sequence number

411	R	SERIES STATEMENT/ADDED ENTRY--MEETING NAME
ind1	012	Type of meeting name entry element
ind2	01	Pronoun represents main entry
a	NR	Meeting name or jurisdiction name as entry element
c	NR	Location of meeting
d	NR	Date of meeting
e	R	Subordinate unit
f	NR	Date of a work
g	NR	Miscellaneous information
k	R	Form subheading
l	NR	Language of a work
n	R	Number of part/section/meeting
p	R	Name of part/section of a work
q	NR	Name of meeting following jurisdiction name entry element
t	NR	Title of a work
u	NR	Affiliation
v	NR	Volume number/sequential designation 
x	NR	International Standard Serial Number
4	R	Relator code
6	NR	Linkage
8	R	Field link and sequence number

440	R	SERIES STATEMENT/ADDED ENTRY--TITLE
ind1	blank	Undefined
ind2	0-9	Nonfiling characters
a	NR	Title
n	R	Number of part/section of a work
p	R	Name of part/section of a work
v	NR	Volume number/sequential designation 
x	NR	International Standard Serial Number
6	NR	Linkage
8	R	Field link and sequence number

490	R	SERIES STATEMENT
ind1	01	Specifies whether series is traced
ind2	blank	Undefined
a	R	Series statement
l	NR	Library of Congress call number
v	R	Volume number/sequential designation 
x	NR	International Standard Serial Number
6	NR	Linkage
8	R	Field link and sequence number

500	R	GENERAL NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	General note
3	NR	Materials specified
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

501	R	WITH NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	With note
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

502	R	DISSERTATION NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Dissertation note
6	NR	Linkage
8	R	Field link and sequence number

504	R	BIBLIOGRAPHY, ETC. NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Bibliography, etc. note
b	NR	Number of references
6	NR	Linkage
8	R	Field link and sequence number

505	R	FORMATTED CONTENTS NOTE
ind1	0128	Display constant controller
ind2	b0	Level of content designation
a	NR	Formatted contents note
g	R	Miscellaneous information
r	R	Statement of responsibility
t	R	Title
u	R	Uniform Resource Identifier
6	NR	Linkage
8	R	Field link and sequence number

506	R	RESTRICTIONS ON ACCESS NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Terms governing access
b	R	Jurisdiction
c	R	Physical access provisions
d	R	Authorized users
e	R	Authorization
u	R	Uniform Resource Identifier
3	NR	Materials specified
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

507	NR	SCALE NOTE FOR GRAPHIC MATERIAL
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Representative fraction of scale note
b	NR	Remainder of scale note
6	NR	Linkage
8	R	Field link and sequence number

508	R	CREATION/PRODUCTION CREDITS NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Creation/production credits note
6	NR	Linkage
8	R	Field link and sequence number

510	R	CITATION/REFERENCES NOTE
ind1	01234	Coverage/location in source
ind2	blank	Undefined
a	NR	Name of source
b	NR	Coverage of source
c	NR	Location within source
x	NR	International Standard Serial Number
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

511	R	PARTICIPANT OR PERFORMER NOTE
ind1	01	Display constant controller
ind2	blank	Undefined
a	NR	Participant or performer note
6	NR	Linkage
8	R	Field link and sequence number

513	R	TYPE OF REPORT AND PERIOD COVERED NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Type of report
b	NR	Period covered
6	NR	Linkage
8	R	Field link and sequence number

514	NR	DATA QUALITY NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Attribute accuracy report
b	R	Attribute accuracy value
c	R	Attribute accuracy explanation
d	R	Logical consistency report
e	NR	Completeness report
f	NR	Horizontal position accuracy report
g	R	Horizontal position accuracy value
h	R	Horizontal position accuracy explanation
i	NR	Vertical positional accuracy report
j	R	Vertical positional accuracy value
k	R	Vertical positional accuracy explanation
m	NR	Cloud cover
u	R	Uniform Resource Identifier
z	R	Display note
6	NR	Linkage
8	R	Field link and sequence number

515	R	NUMBERING PECULIARITIES NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Numbering peculiarities note
6	NR	Linkage
8	R	Field link and sequence number

516	R	TYPE OF COMPUTER FILE OR DATA NOTE
ind1	b8	Display constant controller
ind2	blank	Undefined
a	NR	Type of computer file or data note
6	NR	Linkage
8	R	Field link and sequence number

518	R	DATE/TIME AND PLACE OF AN EVENT NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Date/time and place of an event note
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

520	R	SUMMARY, ETC.
ind1	b01238	Display constant controller
ind2	blank	Undefined
a	NR	Summary, etc. note
b	NR	Expansion of summary note
u	R	Uniform Resource Identifier
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

521	R	TARGET AUDIENCE NOTE
ind1	b012348	Display constant controller
ind2	blank	Undefined
a	R	Target audience note
b	NR	Source
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

522	R	GEOGRAPHIC COVERAGE NOTE
ind1	b8	Display constant controller
ind2	blank	Undefined
a	NR	Geographic coverage note
6	NR	Linkage
8	R	Field link and sequence number

524	R	PREFERRED CITATION OF DESCRIBED MATERIALS NOTE
ind1	b8	Display constant controller
ind2	blank	Undefined
a	NR	Preferred citation of described materials note
2	NR	Source of schema used
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

525	R	SUPPLEMENT NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Supplement note
6	NR	Linkage
8	R	Field link and sequence number

526	R	STUDY PROGRAM INFORMATION NOTE
ind1	08	Display constant controller
ind2	blank	Undefined
a	NR	Program name
b	NR	Interest level
c	NR	Reading level
d	NR	Title point value
i	NR	Display text
x	R	Nonpublic note
z	R	Public note
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

530	R	ADDITIONAL PHYSICAL FORM AVAILABLE NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Additional physical form available note
b	NR	Availability source
c	NR	Availability conditions
d	NR	Order number
u	R	Uniform Resource Identifier
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

533	R	REPRODUCTION NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Type of reproduction
b	R	Place of reproduction
c	R	Agency responsible for reproduction
d	NR	Date of reproduction
e	NR	Physical description of reproduction
f	R	Series statement of reproduction
m	R	Dates and/or sequential designation of issues reproduced
n	R	Note about reproduction
3	NR	Materials specified
6	NR	Linkage
7	NR	Fixed-length data elements of reproduction
8	R	Field link and sequence number

534	R	ORIGINAL VERSION NOTE
ind1	blank	Undefined
ind2	b01	Undefined
a	NR	Main entry of original
b	NR	Edition statement of original
c	NR	Publication, distribution, etc. of original
e	NR	Physical description, etc. of original
f	R	Series statement of original
k	R	Key title of original
l	NR	Location of original
m	NR	Material specific details
n	R	Note about original
p	NR	Introductory phrase
t	NR	Title statement of original
x	R	International Standard Serial Number
z	R	International Standard Book Number
6	NR	Linkage
8	R	Field link and sequence number

535	R	LOCATION OF ORIGINALS/DUPLICATES NOTE
ind1	12	Additional information about custodian
ind2	blank	Undefined
a	NR	Custodian
b	R	Postal address
c	R	Country
d	R	Telecommunications address
g	NR	Repository location code
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

536	R	FUNDING INFORMATION NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Text of note
b	R	Contract number
c	R	Grant number
d	R	Undifferentiated number
e	R	Program element number
f	R	Project number
g	R	Task number
h	R	Work unit number
6	NR	Linkage
8	R	Field link and sequence number

538	R	SYSTEM DETAILS NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	System details note
6	NR	Linkage
8	R	Field link and sequence number

540	R	TERMS GOVERNING USE AND REPRODUCTION NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Terms governing use and reproduction
b	NR	Jurisdiction
c	NR	Authorization
d	NR	Authorized users
u	R	Uniform Resource Identifier
3	NR	Materials specified
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

541	R	IMMEDIATE SOURCE OF ACQUISITION NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Source of acquisition
b	NR	Address
c	NR	Method of acquisition
d	NR	Date of acquisition
e	NR	Accession number
f	NR	Owner
h	NR	Purchase price
n	R	Extent
o	R	Type of unit
3	NR	Materials specified
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

544	R	LOCATION OF OTHER ARCHIVAL MATERIALS NOTE
ind1	b01	Relationship
ind2	blank	Undefined
a	R	Custodian
b	R	Address
c	R	Country
d	R	Title
e	R	Provenance
n	R	Note
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

545	R	BIOGRAPHICAL OR HISTORICAL DATA
ind1	b01	Type of data
ind2	blank	Undefined
a	NR	Biographical or historical note
b	NR	Expansion
u	R	Uniform Resource Identifier
6	NR	Linkage
8	R	Field link and sequence number

546	R	LANGUAGE NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Language note
b	R	Information code or alphabet
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

547	R	FORMER TITLE COMPLEXITY NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Former title complexity note
6	NR	Linkage
8	R	Field link and sequence number

550	R	ISSUING BODY NOTE
ind1	blank	Undefined
ind2	b01	Undefined
a	NR	Issuing body note
6	NR	Linkage
8	R	Field link and sequence number

552	R	ENTITY AND ATTRIBUTE INFORMATION NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Entity type label
b	NR	Entity type definition and source
c	NR	Attribute label
d	NR	Attribute definition and source
e	R	Enumerated domain value
f	R	Enumerated domain value definition and source
g	NR	Range domain minimum and maximum
h	NR	Codeset name and source
i	NR	Unrepresentable domain
j	NR	Attribute units of measurement and resolution
k	NR	Beginning date and ending date of attribute values
l	NR	Attribute value accuracy
m	NR	Attribute value accuracy explanation
n	NR	Attribute measurement frequency
o	R	Entity and attribute overview
p	R	Entity and attribute detail citation
u	R	Uniform Resource Identifier
z	R	Display note
6	NR	Linkage
8	R	Field link and sequence number

555	R	CUMULATIVE INDEX/FINDING AIDS NOTE
ind1	b08	Display constant controller
ind2	blank	Undefined
a	NR	Cumulative index/finding aids note
b	R	Availability source
c	NR	Degree of control
d	NR	Bibliographic reference
u	R	Uniform Resource Identifier
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

556	R	INFORMATION ABOUT DOCUMENTATION NOTE
ind1	b8	Display constant controller
ind2	blank	Undefined
a	NR	Information about documentation note
z	R	International Standard Book Number
6	NR	Linkage
8	R	Field link and sequence number

561	R	OWNERSHIP AND CUSTODIAL HISTORY
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	History
3	NR	Materials specified
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

562	R	COPY AND VERSION IDENTIFICATION NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Identifying markings
b	R	Copy identification
c	R	Version identification
d	R	Presentation format
e	R	Number of copies
3	NR	Materials specified
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

563	R	BINDING INFORMATION
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Binding note
u	R	Uniform Resource Identifier
3	NR	Materials specified
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

565	R	CASE FILE CHARACTERISTICS NOTE
ind1	b08	Display constant controller
ind2	blank	Undefined
a	NR	Number of cases/variables
b	R	Name of variable
c	R	Unit of analysis
d	R	Universe of data
e	R	Filing scheme or code
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

567	R	METHODOLOGY NOTE
ind1	b8	Display constant controller
ind2	blank	Undefined
a	NR	Methodology note
6	NR	Linkage
8	R	Field link and sequence number

580	R	LINKING ENTRY COMPLEXITY NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Linking entry complexity note
6	NR	Linkage
8	R	Field link and sequence number

581	R	PUBLICATIONS ABOUT DESCRIBED MATERIALS NOTE
ind1	b8	Display constant controller
ind2	blank	Undefined
a	NR	Publications about described materials note
z	R	International Standard Book Number
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

583	R	ACTION NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Action
b	R	Action identification
c	R	Time/date of action
d	R	Action interval
e	R	Contingency for action
f	R	Authorization
h	R	Jurisdiction
i	R	Method of action
j	R	Site of action
k	R	Action agent
l	R	Status
n	R	Extent
o	R	Type of unit
u	R	Uniform Resource Identifier
x	R	Nonpublic note
z	R	Public note
2	NR	Source of term
3	NR	Materials specified
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

584	R	ACCUMULATION AND FREQUENCY OF USE NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Accumulation
b	R	Frequency of use
3	NR	Materials specified
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

585	R	EXHIBITIONS NOTE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Exhibitions note
3	NR	Materials specified
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

586	R	AWARDS NOTE
ind1	b8	Display constant controller
ind2	blank	Undefined
a	NR	Awards note
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

600	R	SUBJECT ADDED ENTRY--PERSONAL NAME
ind1	013	Type of personal name entry element
ind2	01234567	Thesaurus
a	NR	Personal name
b	NR	Numeration
c	R	Titles and other words associated with a name
d	NR	Dates associated with a name
e	R	Relator term
f	NR	Date of a work
g	NR	Miscellaneous information
h	NR	Medium
k	R	Form subheading
j	R	Attribution qualifier
l	NR	Language of a work
m	R	Medium of performance for music
n	R	Number of part/section of a work
o	NR	Arranged statement for music
p	R	Name of part/section of a work
q	NR	Fuller form of name
r	NR	Key for music
s	NR	Version
t	NR	Title of a work
u	NR	Affiliation
v	R	Form subdivision
x	R	General subdivision
y	R	Chronological subdivision
z	R	Geographic subdivision
2	NR	Source of heading or term
3	NR	Materials specified
4	R	Relator code
6	NR	Linkage
8	R	Field link and sequence number

610	R	SUBJECT ADDED ENTRY--CORPORATE NAME
ind1	012	Type of corporate name entry element
ind2	01234567	Thesaurus
a	NR	Corporate name or jurisdiction name as entry element
b	R	Subordinate unit
c	NR	Location of meeting
d	R	Date of meeting or treaty signing
e	R	Relator term
f	NR	Date of a work
g	NR	Miscellaneous information
h	NR	Medium
k	R	Form subheading
l	NR	Language of a work
m	R	Medium of performance for music
n	R	Number of part/section/meeting
o	NR	Arranged statement for music
p	R	Name of part/section of a work
r	NR	Key for music
s	NR	Version
t	NR	Title of a work
u	NR	Affiliation
v	R	Form subdivision
x	R	General subdivision
y	R	Chronological subdivision
z	R	Geographic subdivision
2	NR	Source of heading or term
3	NR	Materials specified
4	R	Relator code
6	NR	Linkage
8	R	Field link and sequence number

611	R	SUBJECT ADDED ENTRY--MEETING NAME
ind1	012	Type of meeting name entry element
ind2	01234567	Thesaurus
a	NR	Meeting name or jurisdiction name as entry element
c	NR	Location of meeting
d	NR	Date of meeting
e	R	Subordinate unit
f	NR	Date of a work
g	NR	Miscellaneous information
h	NR	Medium
k	R	Form subheading
l	NR	Language of a work
n	R	Number of part/section/meeting
p	R	Name of part/section of a work
q	NR	Name of meeting following jurisdiction name entry element
s	NR	Version
t	NR	Title of a work
u	NR	Affiliation
v	R	Form subdivision
x	R	General subdivision
y	R	Chronological subdivision
z	R	Geographic subdivision
2	NR	Source of heading or term
3	NR	Materials specified
4	R	Relator code
6	NR	Linkage
8	R	Field link and sequence number

630	R	SUBJECT ADDED ENTRY--UNIFORM TITLE
ind1	0-9	Nonfiling characters
ind2	01234567	Thesaurus
a	NR	Uniform title
d	R	Date of treaty signing
f	NR	Date of a work
g	NR	Miscellaneous information
h	NR	Medium
k	R	Form subheading
l	NR	Language of a work
m	R	Medium of performance for music
n	R	Number of part/section of a work
o	NR	Arranged statement for music
p	R	Name of part/section of a work
r	NR	Key for music
s	NR	Version
t	NR	Title of a work
v	R	Form subdivision
x	R	General subdivision
y	R	Chronological subdivision
z	R	Geographic subdivision
2	NR	Source of heading or term
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

648	R	SUBJECT ADDED ENTRY--CHRONOLOGICAL TERM
ind1	blank	Undefined
ind2	01234567	Thesaurus
a	NR	Chronological term
v	R	Form subdivision
x	R	General subdivision
y	R	Chronological subdivision
z	R	Geographic subdivision
2	NR	Source of heading or term
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

650	R	SUBJECT ADDED ENTRY--TOPICAL TERM
ind1	b012	Level of subject
ind2	01234567	Thesaurus
a	NR	Topical term or geographic name as entry element
b	NR	Topical term following geographic name as entry element
c	NR	Location of event
d	NR	Active dates
e	NR	Relator term
v	R	Form subdivision
x	R	General subdivision
y	R	Chronological subdivision
z	R	Geographic subdivision
2	NR	Source of heading or term
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

651	R	SUBJECT ADDED ENTRY--GEOGRAPHIC NAME
ind1	blank	Undefined
ind2	01234567	Thesaurus
a	NR	Geographic name
v	R	Form subdivision
x	R	General subdivision
y	R	Chronological subdivision
z	R	Geographic subdivision
2	NR	Source of heading or term
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

653	R	INDEX TERM--UNCONTROLLED
ind1	b012	Level of index term
ind2	blank	Undefined
a	R	Uncontrolled term
6	NR	Linkage
8	R	Field link and sequence number

654	R	SUBJECT ADDED ENTRY--FACETED TOPICAL TERMS
ind1	b012	Level of subject
ind2	blank	Undefined
a	NR	Focus term
b	R	Non-focus term
c	R	Facet/hierarchy designation
v	R	Form subdivision
y	R	Chronological subdivision
z	R	Geographic subdivision
2	NR	Source of heading or term
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

655	R	INDEX TERM--GENRE/FORM
ind1	b0	Type of heading
ind2	01234567	Thesaurus
a	NR	Genre/form data or focus term
b	R	Non-focus term
c	R	Facet/hierarchy designation
v	R	Form subdivision
x	R	General subdivision
y	R	Chronological subdivision
z	R	Geographic subdivision
2	NR	Source of term
3	NR	Materials specified
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

656	R	INDEX TERM--OCCUPATION
ind1	blank	Undefined
ind2	7	Source of term
a	NR	Occupation
k	NR	Form
v	R	Form subdivision
x	R	General subdivision
y	R	Chronological subdivision
z	R	Geographic subdivision
2	NR	Source of term
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

657	R	INDEX TERM--FUNCTION
ind1	blank	Undefined
ind2	7	Source of term
a	NR	Function
v	R	Form subdivision
x	R	General subdivision
y	R	Chronological subdivision
z	R	Geographic subdivision
2	NR	Source of term
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

658	R	INDEX TERM--CURRICULUM OBJECTIVE
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Main curriculum objective
b	R	Subordinate curriculum objective
c	NR	Curriculum code
d	NR	Correlation factor
2	NR	Source of term or code
6	NR	Linkage
8	R	Field link and sequence number

700	R	ADDED ENTRY--PERSONAL NAME
ind1	013	Type of personal name entry element
ind2	b2	Type of added entry
a	NR	Personal name
b	NR	Numeration
c	R	Titles and other words associated with a name
d	NR	Dates associated with a name
e	R	Relator term
f	NR	Date of a work
g	NR	Miscellaneous information
h	NR	Medium
j	R	Attribution qualifier
k	R	Form subheading
l	NR	Language of a work
m	R	Medium of performance for music
n	R	Number of part/section of a work
o	NR	Arranged statement for music
p	R	Name of part/section of a work
q	NR	Fuller form of name
r	NR	Key for music
s	NR	Version
t	NR	Title of a work
u	NR	Affiliation
x	NR	International Standard Serial Number
3	NR	Materials specified
4	R	Relator code
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

710	R	ADDED ENTRY--CORPORATE NAME
ind1	012	Type of corporate name entry element
ind2	b2	Type of added entry
a	NR	Corporate name or jurisdiction name as entry element
b	R	Subordinate unit
c	NR	Location of meeting
d	R	Date of meeting or treaty signing
e	R	Relator term
f	NR	Date of a work
g	NR	Miscellaneous information
h	NR	Medium
k	R	Form subheading
l	NR	Language of a work
m	R	Medium of performance for music
n	R	Number of part/section/meeting
o	NR	Arranged statement for music
p	R	Name of part/section of a work
r	NR	Key for music
s	NR	Version
t	NR	Title of a work
u	NR	Affiliation
x	NR	International Standard Serial Number
3	NR	Materials specified
4	R	Relator code
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

711	R	ADDED ENTRY--MEETING NAME
ind1	012	Type of meeting name entry element
ind2	b2	Type of added entry
a	NR	Meeting name or jurisdiction name as entry element
c	NR	Location of meeting
d	NR	Date of meeting
e	R	Subordinate unit
f	NR	Date of a work
g	NR	Miscellaneous information
h	NR	Medium
k	R	Form subheading
l	NR	Language of a work
n	R	Number of part/section/meeting
p	R	Name of part/section of a work
q	NR	Name of meeting following jurisdiction name entry element
s	NR	Version
t	NR	Title of a work
u	NR	Affiliation
x	NR	International Standard Serial Number
3	NR	Materials specified
4	R	Relator code
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

720	R	ADDED ENTRY--UNCONTROLLED NAME
ind1	b12	Type of name
ind2	blank	Undefined
a	NR	Name
e	R	Relator term
4	R	Relator code
6	NR	Linkage
8	R	Field link and sequence number

730	R	ADDED ENTRY--UNIFORM TITLE
ind1	0-9	Nonfiling characters
ind2	b2	Type of added entry
a	NR	Uniform title
d	R	Date of treaty signing
f	NR	Date of a work
g	NR	Miscellaneous information
h	NR	Medium
k	R	Form subheading
l	NR	Language of a work
m	R	Medium of performance for music
n	R	Number of part/section of a work
o	NR	Arranged statement for music
p	R	Name of part/section of a work
r	NR	Key for music
s	NR	Version
t	NR	Title of a work
x	NR	International Standard Serial Number
3	NR	Materials specified
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

740	R	ADDED ENTRY--UNCONTROLLED RELATED/ANALYTICAL TITLE
ind1	0-9	Nonfiling characters
ind2	b2	Type of added entry
a	NR	Uncontrolled related/analytical title
h	NR	Medium
n	R	Number of part/section of a work
p	R	Name of part/section of a work
5	NR	Institution to which field applies
6	NR	Linkage
8	R	Field link and sequence number

752	R	ADDED ENTRY--HIERARCHICAL PLACE NAME
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Country
b	NR	State, province, territory
c	NR	County, region, islands area
d	NR	City
6	NR	Linkage
8	R	Field link and sequence number

753	R	SYSTEM DETAILS ACCESS TO COMPUTER FILES
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Make and model of machine
b	NR	Programming language
c	NR	Operating system
6	NR	Linkage
8	R	Field link and sequence number

754	R	ADDED ENTRY--TAXONOMIC IDENTIFICATION
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Taxonomic name
c	R	Taxonomic category
d	R	Common or alternative name
x	R	Non-public note
z	R	Public note
2	NR	Source of taxonomic identification
6	NR	Linkage
8	R	Field link and sequence number

760	R	MAIN SERIES ENTRY
ind1	01	Note controller
ind2	b8	Display constant controller
a	NR	Main entry heading
b	NR	Edition
c	NR	Qualifying information
d	NR	Place, publisher, and date of publication
g	R	Relationship information
h	NR	Physical description
i	NR	Display text
m	NR	Material-specific details
n	R	Note
o	R	Other item identifier
s	NR	Uniform title
t	NR	Title
w	R	Record control number
x	NR	International Standard Serial Number
y	NR	CODEN designation
6	NR	Linkage
7	NR	Control subfield
8	R	Field link and sequence number

762	R	SUBSERIES ENTRY
ind1	01	Note controller
ind2	b8	Display constant controller
a	NR	Main entry heading
b	NR	Edition
c	NR	Qualifying information
d	NR	Place, publisher, and date of publication
g	R	Relationship information
h	NR	Physical description
i	NR	Display text
m	NR	Material-specific details
n	R	Note
o	R	Other item identifier
s	NR	Uniform title
t	NR	Title
w	R	Record control number
x	NR	International Standard Serial Number
y	NR	CODEN designation
6	NR	Linkage
7	NR	Control subfield
8	R	Field link and sequence number

765	R	ORIGINAL LANGUAGE ENTRY
ind1	01	Note controller
ind2	b8	Display constant controller
a	NR	Main entry heading
b	NR	Edition
c	NR	Qualifying information
d	NR	Place, publisher, and date of publication
g	R	Relationship information
h	NR	Physical description
i	NR	Display text
k	R	Series data for related item
m	NR	Material-specific details
n	R	Note
o	R	Other item identifier
r	R	Report number
s	NR	Uniform title
t	NR	Title
u	NR	Standard Technical Report Number
w	R	Record control number
x	NR	International Standard Serial Number
y	NR	CODEN designation
z	R	International Standard Book Number
6	NR	Linkage
7	NR	Control subfield
8	R	Field link and sequence number

767	R	TRANSLATION ENTRY
ind1	01	Note controller
ind2	b8	Display constant controller
a	NR	Main entry heading
b	NR	Edition
c	NR	Qualifying information
d	NR	Place, publisher, and date of publication
g	R	Relationship information
h	NR	Physical description
i	NR	Display text
k	R	Series data for related item
m	NR	Material-specific details
n	R	Note
o	R	Other item identifier
r	R	Report number
s	NR	Uniform title
t	NR	Title
u	NR	Standard Technical Report Number
w	R	Record control number
x	NR	International Standard Serial Number
y	NR	CODEN designation
z	R	International Standard Book Number
6	NR	Linkage
7	NR	Control subfield
8	R	Field link and sequence number

770	R	SUPPLEMENT/SPECIAL ISSUE ENTRY
ind1	01	Note controller
ind2	b8	Display constant controller
a	NR	Main entry heading
b	NR	Edition
c	NR	Qualifying information
d	NR	Place, publisher, and date of publication
g	R	Relationship information
h	NR	Physical description
i	NR	Display text
k	R	Series data for related item
m	NR	Material-specific details
n	R	Note
o	R	Other item identifier
r	R	Report number
s	NR	Uniform title
t	NR	Title
u	NR	Standard Technical Report Number
w	R	Record control number
x	NR	International Standard Serial Number
y	NR	CODEN designation
z	R	International Standard Book Number
6	NR	Linkage
7	NR	Control subfield
8	R	Field link and sequence number

772	R	SUPPLEMENT PARENT ENTRY
ind1	01	Note controller
ind2	b08	Display constant controller
a	NR	Main entry heading
b	NR	Edition
c	NR	Qualifying information
d	NR	Place, publisher, and date of publication
g	R	Relationship information
h	NR	Physical description
i	NR	Display text
k	R	Series data for related item
m	NR	Material-specific details
n	R	Note
o	R	Other item identifier
r	R	Report number
s	NR	Uniform title
t	NR	Title
u	NR	Standard Technical Report Number
w	R	Record control number
x	NR	International Standard Serial Number
y	NR	CODEN designation
z	R	International Stan dard Book Number
6	NR	Linkage
7	NR	Control subfield
8	R	Field link and sequence number

773	R	HOST ITEM ENTRY
ind1	01	Note controller
ind2	b8	Display constant controller
a	NR	Main entry heading
b	NR	Edition
d	NR	Place, publisher, and date of publication
g	R	Relationship information
h	NR	Physical description
i	NR	Display text
k	R	Series data for related item
m	NR	Material-specific details
n	R	Note
o	R	Other item identifier
p	NR	Abbreviated title
r	R	Report number
s	NR	Uniform title
t	NR	Title
u	NR	Standard Technical Report Number
w	R	Record control number
x	NR	International Standard Serial Number
y	NR	CODEN designation
z	R	International Standard Book Number
3	NR	Materials specified
6	NR	Linkage
7	NR	Control subfield
8	R	Field link and sequence number

774	R	CONSTITUENT UNIT ENTRY
ind1	01	Note controller
ind2	b8	Display constant controller
a	NR	Main entry heading
b	NR	Edition
c	NR	Qualifying information
d	NR	Place, publisher, and date of publication
g	R	Relationship information
h	NR	Physical description
i	NR	Display text
k	R	Series data for related item
m	NR	Material-specific details
n	R	Note
o	R	Other item identifier
r	R	Report number
s	NR	Uniform title
t	NR	Title
u	NR	Standard Technical Report Number
w	R	Record control number
x	NR	International Standard Serial Number
y	NR	CODEN designation
z	R	International Standard Book Number
6	NR	Linkage
7	NR	Control subfield
8	R	Field link and sequence number

775	R	OTHER EDITION ENTRY
ind1	01	Note controller
ind2	b8012	Display constant controller
a	NR	Main entry heading
b	NR	Edition
c	NR	Qualifying information
d	NR	Place, publisher, and date of publication
e	NR	Language code
f	NR	Country code
g	R	Relationship information
h	NR	Physical description
i	NR	Display text
k	R	Series data for related item
m	NR	Material-specific details
n	R	Note
o	R	Other item identifier
r	R	Report number
s	NR	Uniform title
t	NR	Title
u	NR	Standard Technical Report Number
w	R	Record control number
x	NR	International Standard Serial Number
y	NR	CODEN designation
z	R	International Standard Book Number
6	NR	Linkage
7	NR	Control subfield
8	R	Field link and sequence number

776	R	ADDITIONAL PHYSICAL FORM ENTRY
ind1	01	Note controller
ind2	b8	Display constant controller
a	NR	Main entry heading
b	NR	Edition
c	NR	Qualifying information
d	NR	Place, publisher, and date of publication
g	R	Relationship information
h	NR	Physical description
i	NR	Display text
k	R	Series data for related item
m	NR	Material-specific details
n	R	Note
o	R	Other item identifier
r	R	Report number
s	NR	Uniform title
t	NR	Title
u	NR	Standard Technical Report Number
w	R	Record control number
x	NR	International Standard Serial Number
y	NR	CODEN designation
z	R	International Standard Book Number
6	NR	Linkage
7	NR	Control subfield
8	R	Field link and sequence number

777	R	ISSUED WITH ENTRY
ind1	01	Note controller
ind2	b8	Display constant controller
a	NR	Main entry heading
b	NR	Edition
c	NR	Qualifying information
d	NR	Place, publisher, and date of publication
g	R	Relationship information
h	NR	Physical description
i	NR	Display text
k	R	Series data for related item
m	NR	Material-specific details
n	R	Note
o	R	Other item identifier
s	NR	Uniform title
t	NR	Title
w	R	Record control number
x	NR	International Standard Serial Number
y	NR	CODEN designation
6	NR	Linkage
7	NR	Control subfield
8	R	Field link and sequence number

780	R	PRECEDING ENTRY
ind1	01	Note controller
ind2	01234567	Type of relationship
a	NR	Main entry heading
b	NR	Edition
c	NR	Qualifying information
d	NR	Place, publisher, and date of publication
g	R	Relationship information
h	NR	Physical description
i	NR	Display text
k	R	Series data for related item
m	NR	Material-specific details
n	R	Note
o	R	Other item identifier
r	R	Report number
s	NR	Uniform title
t	NR	Title
u	NR	Standard Technical Report Number
w	R	Record control number
x	NR	International Standard Serial Number
y	NR	CODEN designation
z	R	International Standard Book Number
6	NR	Linkage
7	NR	Control subfield
8	R	Field link and sequence number

785	R	SUCCEEDING ENTRY
ind1	01	Note controller
ind2	012345678	Type of relationship
a	NR	Main entry heading
b	NR	Edition
c	NR	Qualifying information
d	NR	Place, publisher, and date of publication
g	R	Relationship information
h	NR	Physical description
i	NR	Display text
k	R	Series data for related item
m	NR	Material-specific details
n	R	Note
o	R	Other item identifier
r	R	Report number
s	NR	Uniform title
t	NR	Title
u	NR	Standa rd Technical Report Number
w	R	Record control number
x	NR	International Standard Serial Number
y	NR	CODEN designation
z	R	International Standard Book Number
6	NR	Linkage
7	NR	Control subfield
8	R	Field link and sequence number

786	R	DATA SOURCE ENTRY
ind1	01	Note controller
ind2	b8	Display constant controller
a	NR	Main entry heading
b	NR	Edition
c	NR	Qualifying information
d	NR	Place, publisher, and date of publication
g	R	Relationship information
h	NR	Physical description
i	NR	Display text
j	NR	Period of content
k	R	Series data for related item
m	NR	Material-specific details
n	R	Note
o	R	Other item identifier
p	NR	Abbreviated title
r	R	Report number
s	NR	Uniform title
t	NR	Title
u	NR	Standard Technical Report Number
v	NR	Source Contribution
w	R	Record control number
x	NR	International Standard Serial Number
y	NR	CODEN designation
z	R	International Standard Book Number
6	NR	Linkage
7	NR	Control subfield
8	R	Field link and sequence number

787	R	NONSPECIFIC RELATIONSHIP ENTRY
ind1	01	Note controller
ind2	b8	Display constant controller
a	NR	Main entry heading
b	NR	Edition
c	NR	Qualifying information
d	NR	Place, publisher, and date of publication
g	R	Relationship information
h	NR	Physical description
i	NR	Display text
k	R	Series data for related item
m	NR	Material-specific details
n	R	Note
o	R	Other item identifier
r	R	Report number
s	NR	Uniform title
t	NR	Title
u	NR	Standard Technical Report Number
w	R	Record control number
x	NR	International Standard Serial Number
y	NR	CODEN designation
z	R	International Standard Book Number
6	NR	Linkage
7	NR	Control subfield
8	R	Field link and sequence number

800	R	SERIES ADDED ENTRY--PERSONAL NAME
ind1	013	Type of personal name entry element
ind2	blank	Undefined
a	NR	Personal name
b	NR	Numeration
c	R	Titles and other words associated with a name
d	NR	Dates associated with a name
e	R	Relator term
f	NR	Date of a work
g	NR	Miscellaneous information
h	NR	Medium
j	R	Attribution qualifier
k	R	Form subheading
l	NR	Language of a work
m	R	Medium of performance for music
n	R	Number of part/section of a work 
o	NR	Arranged statement for music
p	R	Name of part/section of a work
q	NR	Fuller form of name
r	NR	Key for music
s	NR	Version
t	NR	Title of a work
u	NR	Affiliation
v	NR	Volume/sequential designation 
4	R	Relator code
6	NR	Linkage
8	R	Field link and sequence number

810	R	SERIES ADDED ENTRY--CORPORATE NAME
ind1	012	Type of corporate name entry element
ind2	blank	Undefined
a	NR	Corporate name or jurisdiction name as entry element
b	R	Subordinate unit
c	NR	Location of meeting
d	R	Date of meeting or treaty signing
e	R	Relator term
f	NR	Date of a work
g	NR	Miscellaneous information
h	NR	Medium
k	R	Form subheading
l	NR	Language of a work
m	R	Medium of performance for music
n	R	Number of part/section/meeting
o	NR	Arranged statement for music
p	R	Name of part/section of a work
r	NR	Key for music
s	NR	Version
t	NR	Title of a work
u	NR	Affiliation
v	NR	Volume/sequential designation
4	R	Relator code
6	NR	Linkage
8	R	Field link and sequence number

811	R	SERIES ADDED ENTRY--MEETING NAME
ind1	012	Type of meeting name entry element
ind2	blank	Undefined
a	NR	Meeting name or jurisdiction name as entry element
c	NR	Location of meeting
d	NR	Date of meeting
e	R	Subordinate unit
f	NR	Date of a work
g	NR	Miscellaneous information
h	NR	Medium
k	R	Form subheading
l	NR	Language of a work
n	R	Number of part/section/meeting
p	R	Name of part/section of a work
q	NR	Name of meeting following jurisdiction name entry element
s	NR	Version
t	NR	Title of a work
u	NR	Affiliation
v	NR	Volume/sequential designation
4	R	Relator code
6	NR	Linkage
8	R	Field link and sequence number

830	R	SERIES ADDED ENTRY--UNIFORM TITLE
ind1	blank	Undefined
ind2	0-9	Nonfiling characters
a	NR	Uniform title
d	R	Date of treaty signing
f	NR	Date of a work
g	NR	Miscellaneous information
h	NR	Medium
k	R	Form subheading
l	NR	Language of a work
m	R	Medium of performance for music
n	R	Number of part/section of a work
o	NR	Arranged statement for music
p	R	Name of part/section of a work
r	NR	Key for music
s	NR	Version
t	NR	Title of a work
v	NR	Volume/sequential designation
6	NR	Linkage
8	R	Field link and sequence number

841	NR	HOLDINGS CODED DATA VALUES

842	NR	TEXTUAL PHYSICAL FORM DESIGNATOR

843	R	REPRODUCTION NOTE

844	NR	NAME OF UNIT

845	R	TERMS GOVERNING USE AND REPRODUCTION NOTE

850	R	HOLDING INSTITUTION
ind1	blank	Undefined
ind2	blank	Undefined
a	R	Holding institution
8	R	Field link and sequence number

852	R	LOCATION
ind1	b012345678	Shelving scheme
ind2	b012	Shelving order
a	NR	Location
b	R	Sublocation or collection
c	R	Shelving location
e	R	Address
f	R	Coded location qualifier
g	R	Non-coded location qualifier
h	NR	Classification part
i	R	Item part
j	NR	Shelving control number
k	R	Call number prefix
l	NR	Shelving form of title
m	R	Call number suffix
n	NR	Country code
p	NR	Piece designation
q	NR	Piece physical condition
s	R	Copyright article-fee code
t	NR	Copy number
x	R	Nonpublic note
z	R	Public note
2	NR	Source of classification or shelving scheme
3	NR	Materials specified
6	NR	Linkage
8	NR	Sequence number

853	R	CAPTIONS AND PATTERN--BASIC BIBLIOGRAPHIC UNIT

854	R	CAPTIONS AND PATTERN--SUPPLEMENTARY MATERIAL

855	R	CAPTIONS AND PATTERN--INDEXES

856	R	ELECTRONIC LOCATION AND ACCESS
ind1	b012347	Access method
ind2	b0128	Relationship
a	R	Host name
b	R	Access number
c	R	Compression information
d	R	Path
f	R	Electronic name
h	NR	Processor of request
i	R	Instruction
j	NR	Bits per second
k	NR	Password
l	NR	Logon
m	R	Contact for access assistance
n	NR	Name of location of host
o	NR	Operating system
p	NR	Port
q	NR	Electronic format type
r	NR	Settings
s	R	File size
t	R	Terminal emulation
u	R	Uniform Resource Identifier
v	R	Hours access method available
w	R	Record control number
x	R	Nonpublic note
y	R	Link text
z	R	Public note
2	NR	Access method
3	NR	Materials specified
6	NR	Linkage
8	R	Field link and sequence number

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
ind1		Same as associated field
ind2		Same as associated field
6	NR	Linkage

886	R	FOREIGN MARC INFORMATION FIELD
ind1	012	Type of field
ind2	blank	Undefined
a	NR	Tag of the foreign MARC field
b	NR	Content of the foreign MARC field
2	NR	Source of data

887	R	NON-MARC INFORMATION FIELD
ind1	blank	Undefined
ind2	blank	Undefined
a	NR	Content of non-MARC field
2	NR	Source of data

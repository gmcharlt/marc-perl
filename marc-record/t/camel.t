# camel.t - Test creating a MARC record for the Camel book
#
# Bugs, comments, suggestions welcome: marc@petdance.com

use strict;
use integer;

use MARC::Record;

print "1..6\n";

my @errors = ();

sub error(@) {
	my $str = join( "", "Error: ", @_ );
	push( @errors, $str );
}


my $testno = 0;
sub judge($) {
	my $testname = shift;
	++$testno;

	my $status = @errors ? "not ok" : "ok";
	my @messages = map { "# $_" } ( "Test #$testno: $testname", @errors );
	print join( "\n", $status, @messages, "" );
}


# Test 1: Testing as_usmarc()
my $marc = MARC::Record->new();

if ( not $marc ) {
	error( "Constructor failed: $MARC::Record::ERROR" );
} else {
	$marc->leader("00000nam  22?????8a 4500"); # The ????? represents meaningless digits at this point
	my $nfields = $marc->add_fields(
		["001","fol05865967"],
		["003","IMchF"],
		["010", "","", 
			a => "   00055799",
			],
		[100, "1","",
			a => "Wall, Larry."
			],
		[245, "1","0",
			a => "Programming Perl / ",
			c => "Larry Wall, Tom Christiansen & Jon Orwant.",
			],
		[250, "", "",
			a => "3rd ed.",
			],
		[260, "", "",
			a => "Cambridge, Mass. : ",
			b => "O'Reilly, ",
			c => "2000.",
			],
		[650, " ","0",
			a => "Perl (Computer program language)",
			],
		[700, "1"," ",
			a => "Christiansen, Tom.",
			],
		[700, "1"," ",
			a => "Orwant, Jon.",
			],
		);

	defined($nfields)	or error( "Couldn't add fields to record" );
	($nfields == 10) 	or error( "Was supposed to add 10 fields, but added $nfields" );

	my $expected = "00397nam  22001458a 4500001001200000003000600012010001600018100001700034245006800051250001200119260004300131650003700174700002300211700001700234\x1Efol05865967\x1EIMchF\x1E  \x1Fa   00055799\x1E1 \x1FaWall, Larry.\x1E10\x1FaProgramming Perl / \x1FcLarry Wall, Tom Christiansen & Jon Orwant.\x1E  \x1Fa3rd ed.\x1E  \x1FaCambridge, Mass. : \x1FbO'Reilly, \x1Fc2000.\x1E 0\x1FaPerl (Computer program language)\x1E1 \x1FaChristiansen, Tom.\x1E1 \x1FaOrwant, Jon.\x1E\x1D";

	($marc->as_usmarc eq $expected) or error( "USMARC format not what I expected" );
} # if constructor

judge( "as_usmarc()" );


# Test 2: as_string()
my $expected = join( "", <DATA> );
my $generated = $marc->as_formatted;
chomp $expected;
chomp $generated;
($generated eq $expected) or error( "String representation not what I expected" );
judge( "as_string()" );

# Test 3: multiple fields by number

if ( (my @addlauthors = $marc->field("700")) != 2 ) {
	error( "Didn't get 700 tags" );
} else {
	(($addlauthors[0]->subfield("a") eq "Christiansen, Tom.") &&
	 ($addlauthors[1]->subfield("a") eq "Orwant, Jon."))
	or error( "Didn't get both Tom and Jon back" );
}
judge( "multiple fields by number" );


# Test 4: multiple fields by the "XX" notation
if ( (my @addlauthors = $marc->field("7XX")) != 2 ) {
	error( "Didn't get 7XX tags" );
} else {
	(($addlauthors[0]->subfield("a") eq "Christiansen, Tom.") &&
	 ($addlauthors[1]->subfield("a") eq "Orwant, Jon."))
	or error( "Didn't get both Tom and Jon back" );
}
judge( "Multiple fields by 'XX' notation" );

# Test 5: field/subfield
$marc->subfield( 100, "a" ) eq "Wall, Larry." 
	or error( "Didn't get Larry's 100a" );
judge( "Field/subfield fetching" );

# Test 6: Reading from disk

my $filename = "t/camel.usmarc";
if ( not open( IN, $filename ) ) {
	error( "Can't open $filename: $!" );
} else {
	my $diskmarc;
	for my $n ( 1..8 ) {
		$diskmarc = MARC::Record::next_from_file( *IN );
		if ( not defined $diskmarc ) {
			error( "Crapped out reading record #$n from $filename" );
			last;
		}
	}
	
	if ( $diskmarc ) {
		if ( $diskmarc->subfield(245,"c") ne $marc->subfield(245,"c") ) {
			error( "MARC from $filename is different from what I built in memory" );
		}
	}
}
judge( "Reading from disk" );

__END__
LDR 00397nam  22001458a 4500
001     fol05865967
003     IMchF
010    _a   00055799
100 1  _aWall, Larry.
245 10 _aProgramming Perl / 
       _cLarry Wall, Tom Christiansen & Jon Orwant.
250    _a3rd ed.
260    _aCambridge, Mass. : 
       _bO'Reilly, 
       _c2000.
650  0 _aPerl (Computer program language)
700 1  _aChristiansen, Tom.
700 1  _aOrwant, Jon.

package MARC::XML;

use Carp;
use strict;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $XDEBUG $XTEST);

require 5.004;
require Exporter;
use MARC 1.07;
use XML::Parser 2.27; 

$VERSION = 0.4;
$XDEBUG = 0;
$XTEST = 0;
@ISA = qw(Exporter MARC);
@EXPORT= qw();
@EXPORT_OK= qw();

#### Not using these yet

#### %EXPORT_TAGS = (USTEXT	=> [qw( marc2ustext )]);
#### Exporter::export_ok_tags('USTEXT');
#### $EXPORT_TAGS{ALL} = \@EXPORT_OK;

sub xcarp {
    Carp::carp (@_) unless $XTEST;
}

####################################################################
# variables used in subroutines called by parser                   #
# not currently per-object, so one XML conversion at a time        #
####################################################################

my $count;
my $field;
my @subfields;
my $subfield;
my $i1;
my $i2;
my $fieldvalue;
my $subfieldvalue;
my $recordnum;
my $marc_obj;
my $reorder;
my $enthash;	# ref to entity decoding hash

####################################################################
# templates used to output headers                                 #
####################################################################

my $head1 = '<?xml version="1.0" encoding="%s" standalone="%s"?>';
my $head2 = '%s<!DOCTYPE marc SYSTEM "%s">';

####################################################################
# handlers for the XML elements, the so called "subs style".       #
####################################################################

sub record {
	$count++;
}

sub field {
	(my $expat, my $el, my %atts)=@_;
	$field=$atts{'type'};
	if ($field>9) {
	    $i1=$atts{i1};
	    $i2=$atts{i2};
	}
}

sub field_ {
	(my $expat, my $el)=@_;
	if ($field eq "000") {
	    $recordnum=$marc_obj->createrecord({leader=>$fieldvalue});
	}	
	elsif ($field < 10) {
	    $marc_obj->addfield({
		record=>$recordnum,
		field=>$field,
		ordered=>$reorder,
		value=>[$fieldvalue]
		});
	}
	else {
	    $marc_obj->addfield({
		record=>$recordnum,
		field=>$field,
		ordered=>$reorder,
		i1=>$i1,
		i2=>$i2,
		value=>[@subfields]
		});
	}
	$field=undef;
	$i1=undef;
	$i2=undef;
	$fieldvalue=undef;
	@subfields=();
}

sub subfield {
	(my $expat, my $el, my %atts)=@_;
	$subfield=$atts{type};
}

sub subfield_ {
	(my $expat, my $el)=@_;
	push(@subfields,$subfield,$subfieldvalue);
	$subfield=undef;
	$subfieldvalue=undef;
}

sub handle_char {
	(my $expat, my $string)=@_;
	if ($subfield) {$subfieldvalue.=$string}
	elsif ($field) {$fieldvalue.=$string}
}

sub handle_extent {
    my ($p, $base, $sys, $pub) = @_;
    print "handle_extent: $base, $sys, $pub\n" if ($XDEBUG);
    if (exists $$enthash{$sys}) {
	if ($subfield) {$subfieldvalue.=$$enthash{$sys}}
	elsif ($field) {$fieldvalue.=$$enthash{$sys}}
	return "";
    }
    local(*FOO);
    open(FOO, $sys) or die "Couldn't open entity $sys";
    return *FOO;
}

####################################################################
# new() is the constructor method for MARC::XML. new() takes two   #
# arguements which are used to automatically read in the entire    #
# contents of an XML file. If a format other than "xml" is         #
# specified then the MARC.pm new() constructor is called.          #
####################################################################
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $file=shift;
    my $format;
    if ($file) { $format = shift || "xml"; }
    my $rcount;
    my $marc;
    if ($file and $format=~/xml$/oi) {
	$marc = $class->SUPER::new();
	$reorder = shift || "n";
        unless (-e $file) {xcarp "File $file doesn't exist"; return}
	    #if the file doesn't exist return an error
	$rcount = _readxml($marc, $file);
    }
    else {
	$marc = $class->SUPER::new($file,$format);
    }
    bless($marc,$class);
    return $marc;
}

####################################################################
# simple wrapper methods to simplify outputting                    #
# just pass through all parameters except format                   #
####################################################################

sub output_header {
    my ($marc,$params)=@_;
    $params->{'format'} = "xml_header";
    return output($marc,$params);
}

sub output_body {
    my ($marc,$params)=@_;
    $params->{'format'} = "xml_body";
    return output($marc,$params);
}

sub output_footer {
    my ($marc,$params)=@_;
    $params->{'format'} = "xml_footer";
    return output($marc,$params);
}

####################################################################
# the output() method overloads the MARC::output method and allows #
# the user to output a MARC object as XML to a file or into a      #
# variable. If the format parameter is not used "xml" is assumed,  #
# and if the format is declared but it doesn't match "xml",        #
# "xml_header", "xml_body", or "xml_footer" then the output        #
# command is passed up to the MARC package to see what can be done #
# with it there.                                                   #
####################################################################
sub output {
    (my $marc, my $params)=@_;
    my $file=$params->{file};
    my $newline = $params->{lineterm} || "\n";
    my $basecode = $params->{encoding} || "US-ASCII";
    my $dtd = $params->{dtd_file} || "";
    my $stand = $params->{standalone} || $dtd ? "no" : "yes";
    my $output="";
    unless (exists $params->{'format'}) {
        $params->{'format'} = "xml";
        $params->{lineterm} = $newline;
    }
    if ($params->{'format'} =~ /xml$/oi) {
        $output = sprintf $head1, $basecode, $stand;
        $output .= sprintf $head2, $newline, $dtd if ($dtd);
        $output .= "$newline<marc>$newline$newline";
	$output .= _marc2xml($marc,$params);
        $output .= "</marc>$newline";
    }
    elsif ($params->{'format'} =~ /xml_header$/oi) {
        $output = sprintf $head1, $basecode, $stand;
        $output .= sprintf $head2, $newline, $dtd if ($dtd);
        $output .= "$newline<marc>$newline$newline";
    }
    elsif ($params->{'format'} =~ /xml_body$/oi) {
	$output=_marc2xml($marc,$params);
    }
    elsif ($params->{'format'} =~ /xml_footer$/oi) {
	$output="</marc>$newline";
    }
    else {
	return $marc->SUPER::output($params);
    }    
       #output to a file or return the $output
    if ($params->{file}) {
	if ($params->{file} !~ /^>/) {carp "Don't forget to use > or >>: $!"}
	open (OUT, "$params->{file}") || carp "Couldn't open file: $!";
        binmode OUT;
	print OUT $output;
	close OUT || carp "Couldn't close file: $!";
	return 1;
    }
      #if no filename was specified return the output so it can be grabbed
    else {
	return $output;
    }
}
    
####################################################################
# _readxml is an internal subroutine for reading in MARC data that #
# is encoded in XML. It is called via new()                        #
# XML::Parser must be installed in your Perl library for this to   #
# work. If no records are read in an error will be generated.      #
####################################################################
sub _readxml {
    $marc_obj = shift;	# must be package global
    my $file = shift;
    unless ($enthash) {
	$enthash = register_default();	# hash ref
    }
       #create the parser object and parse the xml file
    my $xmlfile = new XML::Parser(Style=>'Subs',
				  ParseParamEnt => 1,
				  ErrorContext  => 2,
				  Handlers => {Char    => \&handle_char,
				 	 ExternEnt => \&handle_extent}
				);
    $xmlfile->parsefile($file);
    unless ($count) {carp "Error reading XML $!";}
    return $count;    
}

####################################################################
# openxml() is a method for reading in an XML file.  It takes      #
# several parameters: file (name of the xml file) ; increment      #
# increment which defines how many records to read in ; and a      #
# reference to a charset hash used to decode xml entities          #
####################################################################
sub openxml {
    $marc_obj = shift;	# must be package global
    my $params = shift;
    my $file=$params->{file};
    if (not(-e $file)) {xcarp "File \"$file\" doesn't exist"; return} 
    $marc_obj->[0]{'format'}= 'xml'; #store format in object
    $count = 0;
    $marc_obj->[0]{'increment'}=$params->{'increment'} || 0;
        #store increment in the object, default is 0
    open (*file, $file);
    binmode *file;
    $marc_obj->[0]{'handle'}=\*file; #store filehandle in object
    my $handle = $marc_obj->[0]{'handle'};
    if (exists $params->{charset}) {
        $enthash = $params->{charset};	# hash ref
    }
    else {
        unless ($enthash) {
	    $enthash = register_default();	# hash ref
	}
    }
    my $p = new XML::Parser(Style=>'Subs',
			    ParseParamEnt => 1,
			    ErrorContext  => 2,
			    Handlers => {Char    => \&handle_char,
				ExternEnt => \&handle_extent}
			   );

	# Create the non-blocking parser
    $marc_obj->[0]{'expat'} = $p->parse_start;

    print "read in $count records\n" if $XDEBUG;
    if ($count==0) {$count="0 but true"}
    return $count;    
}

####################################################################
# closexml() will close a file-handle that was opened with         #
# openxml()                                                        #
####################################################################
sub closexml {
    my $marc = shift;
    $marc->[0]{'increment'}=0;
    if (not($marc->[0]{'handle'})) {
	xcarp "There isn't a MARC file to close"; 
	return;
    }

    my $ok = close $marc->[0]{'handle'};

    $marc->[0]{'expat'}->parse_done;
    $marc->[0]{'handle'}=undef;
    $marc->[0]{'expat'}=undef;
    return $ok;
}

####################################################################
# nextxml() will read in more records from a file that has         #
# already been opened with openxml(). the increment can be         #
# adjusted if necessary by passing a new value as a parameter. the # 
# new records will be APPENDED to the MARC object                  #
####################################################################
sub nextxml {
    $marc_obj=shift;
    my $increment=shift;
    my $handle = $marc_obj->[0]{'handle'};
    if (not $handle) {
	xcarp "There isn't a MARC file open"; 
	return;
    }
    $marc_obj->[0]{'increment'}=$increment;
    $count = 0;
    local $/ = "</record>";

    while (($increment==-1 or $count<$increment) and my $record=<$handle>) {
        $marc_obj->[0]{'expat'}->parse_more($record);
    }
    return $count;
}

sub register_default {
    # upper-register entities (8-bit to 7-bit)
    my @hexchar = (0x80..0x8c,0x8f..0xa0,0xaf,0xbb,
		   0xbe,0xbf,0xc7..0xdf,0xfc,0xfd,0xff);
    my %inchar = map {sprintf ("x%2.2X",int $_), chr($_)} @hexchar;

    $inchar{joiner} = chr(0x8d);	# zero width joiner
    $inchar{nonjoin} = chr(0x8e);	# zero width non-joiner
    $inchar{Lstrok} = chr(0xa1);	# latin capital letter l with stroke
    $inchar{Ostrok} = chr(0xa2);	# latin capital letter o with stroke
    $inchar{Dstrok} = chr(0xa3);	# latin capital letter d with stroke
    $inchar{THORN} = chr(0xa4);		# latin capital letter thorn (icelandic)
    $inchar{AElig} = chr(0xa5);		# latin capital letter AE
    $inchar{OElig} = chr(0xa6);		# latin capital letter OE
    $inchar{softsign} = chr(0xa7);	# modifier letter soft sign
    $inchar{middot} = chr(0xa8);	# middle dot
    $inchar{flat} = chr(0xa9);		# musical flat sign
    $inchar{reg} = chr(0xaa);		# registered sign
    $inchar{plusmn} = chr(0xab);	# plus-minus sign
    $inchar{Ohorn} = chr(0xac);		# latin capital letter o with horn
    $inchar{Uhorn} = chr(0xad);		# latin capital letter u with horn
    $inchar{mlrhring} = chr(0xae);	# modifier letter right half ring (alif)
    $inchar{mllhring} = chr(0xb0);	# modifier letter left half ring (ayn)
    $inchar{lstrok} = chr(0xb1);	# latin small letter l with stroke
    $inchar{ostrok} = chr(0xb2);	# latin small letter o with stroke
    $inchar{dstrok} = chr(0xb3);	# latin small letter d with stroke
    $inchar{thorn} = chr(0xb4);		# latin small letter thorn (icelandic)
    $inchar{aelig} = chr(0xb5);		# latin small letter ae
    $inchar{oelig} = chr(0xb6);		# latin small letter oe
    $inchar{hardsign} = chr(0xb7);	# modifier letter hard sign
    $inchar{inodot} = chr(0xb8);	# latin small letter dotless i
    $inchar{pound} = chr(0xb9);		# pound sign
    $inchar{eth} = chr(0xba);		# latin small letter eth
    $inchar{ohorn} = chr(0xbc);		# latin small letter o with horn
    $inchar{uhorn} = chr(0xbd);		# latin small letter u with horn
    $inchar{deg} = chr(0xc0);		# degree sign
    $inchar{scriptl} = chr(0xc1);	# latin small letter script l
    $inchar{phono} = chr(0xc2);		# sound recording copyright
    $inchar{copy} = chr(0xc3);		# copyright sign
    $inchar{sharp} = chr(0xc4);		# sharp
    $inchar{iquest} = chr(0xc5);	# inverted question mark
    $inchar{iexcl} = chr(0xc6);		# inverted exclamation mark
    $inchar{hooka} = chr(0xe0);		# combining hook above
    $inchar{grave} = chr(0xe1);		# combining grave
    $inchar{acute} = chr(0xe2);		# combining acute
    $inchar{circ} = chr(0xe3);		# combining circumflex
    $inchar{tilde} = chr(0xe4);		# combining tilde
    $inchar{macr} = chr(0xe5);		# combining macron
    $inchar{breve} = chr(0xe6);		# combining breve
    $inchar{dot} = chr(0xe7);		# combining dot above
    $inchar{diaer} = chr(0xe8);		# combining diaeresis
    $inchar{uml} = chr(0xe8);		# combining umlaut
    $inchar{caron} = chr(0xe9);		# combining hacek
    $inchar{ring} = chr(0xea);		# combining ring above
    $inchar{llig} = chr(0xeb);		# combining ligature left half
    $inchar{rlig} = chr(0xec);		# combining ligature right half
    $inchar{rcommaa} = chr(0xed);	# combining comma above right
    $inchar{dblac} = chr(0xee);		# combining double acute
    $inchar{candra} = chr(0xef);	# combining candrabindu
    $inchar{cedil} = chr(0xf0);		# combining cedilla
    $inchar{ogon} = chr(0xf1);		# combining ogonek
    $inchar{dotb} = chr(0xf2);		# combining dot below
    $inchar{dbldotb} = chr(0xf3);	# combining double dot below
    $inchar{ringb} = chr(0xf4);		# combining ring below
    $inchar{dblunder} = chr(0xf5);	# combining double underscore
    $inchar{under} = chr(0xf6);		# combining underscore
    $inchar{commab} = chr(0xf7);	# combining comma below
    $inchar{rcedil} = chr(0xf8);	# combining right cedilla
    $inchar{breveb} = chr(0xf9);	# combining breve below
    $inchar{ldbltil} = chr(0xfa);	# combining double tilde left half
    $inchar{rdbltil} = chr(0xfb);	# combining double tilde right half
    $inchar{commaa} = chr(0xfe);	# combining comma above
    if ($XDEBUG) {
        foreach my $str (sort keys %inchar) {
            printf "%s = %x\n", $str, ord($inchar{$str});
        }
    }
    return \%inchar;
}

####################################################################
# _marc2xml takes a MARC object as its input and converts it into  #
# XML. The XML is returned as a string                             #
####################################################################
sub _marc2xml {
    my ($marc,$params)=@_;
    my $output;
    my $newline = $params->{lineterm} || "\n";
    my @records;
    unless (exists $params->{charset}) {
        unless (exists $marc->[0]{xmlchar}) {
	    $marc->[0]{xmlchar} = ansel_default();	# hash ref
	}
	$params->{charset} = $marc->[0]{xmlchar};
    }
    if ($params->{records}) {@records=@{$params->{records}}}
    else {for (my $i=1;$i<=$#$marc;$i++) {push(@records,$i)}}
    foreach my $i (@records) {
	my $recout=$marc->[$i]; #cycle through each record
	$output.="<record>$newline";
	foreach my $fields (@{$recout->{array}}) { #cycle through each field 
	    my $tag=$fields->[0];
	    if ($tag<10) { #no indicators or subfields
		my $value = _char2xml($fields->[1], $params->{charset});
		$output.=qq(<field type="$tag">$value</field>$newline);
	    }
	    else { #indicators and subfields
		$output.=qq(<field type="$tag" i1="$fields->[1]" i2="$fields->[2]">$newline);
		my @subfldout = @{$fields}[3..$#{$fields}];		
		while (@subfldout) { #cycle through subfields
		    my $subfield_type = shift(@subfldout);
		    my $subfield_value = _char2xml( shift(@subfldout),
						   $params->{charset} );
		    $output .= qq(   <subfield type="$subfield_type">);
		    $output .= qq($subfield_value</subfield>$newline);
		} #finish cycling through subfields
		$output .= qq(</field>$newline);
	    } #finish tag test < 10
	}
	$output.="</record>$newline$newline"; #put an extra newline to separate records
    }
    return $output;
}

sub _char2xml {
    my @marc_string = split (//, shift);
    my $charmap = shift;
    local $^W = 0;	# no warnings
	# the simple case only works for single byte entities
    my $xml_string = join ('', map { ${$charmap}{$_} } @marc_string);
    return $xml_string;
}

sub ansel_default {
    my @hexchar = (0x00..0x08,0x0b,0x0c,0x0e..0x1f,0x80..0x8c,0x8f..0xa0,
		   0xaf,0xbb,0xbe,0xbf,0xc7..0xdf,0xfc,0xfd,0xff);
    my %outchar = map {chr($_), sprintf ("&x%2.2X;",int $_)} @hexchar;

    my @ascchar = map {chr($_)} (0x09,0x0a,0x0d,0x20,0x21,0x23..0x25,
				 0x28..0x3b,0x3d,0x3f..0x7f);
    foreach my $asc (@ascchar) { $outchar{$asc} = $asc; }

    $outchar{chr(0x22)} = '&quot;';	# quotation
    $outchar{chr(0x26)} = '&amp;';	# ampersand
    $outchar{chr(0x27)} = '&apos;';	# apostrophe
    $outchar{chr(0x3c)} = '&lt;';	# less than
    $outchar{chr(0x3e)} = '&gt;';	# greater than
    $outchar{chr(0x8d)} = '&joiner;';	# zero width joiner
    $outchar{chr(0x8e)} = '&nonjoin;';	# zero width non-joiner
    $outchar{chr(0xa1)} = '&Lstrok;';	# latin capital letter l with stroke
    $outchar{chr(0xa2)} = '&Ostrok;';	# latin capital letter o with stroke
    $outchar{chr(0xa3)} = '&Dstrok;';	# latin capital letter d with stroke
    $outchar{chr(0xa4)} = '&THORN;';	# latin capital letter thorn (icelandic)
    $outchar{chr(0xa5)} = '&AElig;';	# latin capital letter AE
    $outchar{chr(0xa6)} = '&OElig;';	# latin capital letter OE
    $outchar{chr(0xa7)} = '&softsign;';	# modifier letter soft sign
    $outchar{chr(0xa8)} = '&middot;';	# middle dot
    $outchar{chr(0xa9)} = '&flat;';	# musical flat sign
    $outchar{chr(0xaa)} = '&reg;';	# registered sign
    $outchar{chr(0xab)} = '&plusmn;';	# plus-minus sign
    $outchar{chr(0xac)} = '&Ohorn;';	# latin capital letter o with horn
    $outchar{chr(0xad)} = '&Uhorn;';	# latin capital letter u with horn
    $outchar{chr(0xae)} = '&mlrhring;';	# modifier letter right half ring (alif)
    $outchar{chr(0xb0)} = '&mllhring;';	# modifier letter left half ring (ayn)
    $outchar{chr(0xb1)} = '&lstrok;';	# latin small letter l with stroke
    $outchar{chr(0xb2)} = '&ostrok;';	# latin small letter o with stroke
    $outchar{chr(0xb3)} = '&dstrok;';	# latin small letter d with stroke
    $outchar{chr(0xb4)} = '&thorn;';	# latin small letter thorn (icelandic)
    $outchar{chr(0xb5)} = '&aelig;';	# latin small letter ae
    $outchar{chr(0xb6)} = '&oelig;';	# latin small letter oe
    $outchar{chr(0xb7)} = '&hardsign;';	# modifier letter hard sign
    $outchar{chr(0xb8)} = '&inodot;';	# latin small letter dotless i
    $outchar{chr(0xb9)} = '&pound;';	# pound sign
    $outchar{chr(0xba)} = '&eth;';	# latin small letter eth
    $outchar{chr(0xbc)} = '&ohorn;';	# latin small letter o with horn
    $outchar{chr(0xbd)} = '&uhorn;';	# latin small letter u with horn
    $outchar{chr(0xc0)} = '&deg;';	# degree sign
    $outchar{chr(0xc1)} = '&scriptl;';	# latin small letter script l
    $outchar{chr(0xc2)} = '&phono;';	# sound recording copyright
    $outchar{chr(0xc3)} = '&copy;';	# copyright sign
    $outchar{chr(0xc4)} = '&sharp;';	# sharp
    $outchar{chr(0xc5)} = '&iquest;';	# inverted question mark
    $outchar{chr(0xc6)} = '&iexcl;';	# inverted exclamation mark
    $outchar{chr(0xe0)} = '&hooka;';	# combining hook above
    $outchar{chr(0xe1)} = '&grave;';	# combining grave
    $outchar{chr(0xe2)} = '&acute;';	# combining acute
    $outchar{chr(0xe3)} = '&circ;';	# combining circumflex
    $outchar{chr(0xe4)} = '&tilde;';	# combining tilde
    $outchar{chr(0xe5)} = '&macr;';	# combining macron
    $outchar{chr(0xe6)} = '&breve;';	# combining breve
    $outchar{chr(0xe7)} = '&dot;';	# combining dot above
    $outchar{chr(0xe8)} = '&uml;';	# combining diaeresis (umlaut)
    $outchar{chr(0xe9)} = '&caron;';	# combining hacek
    $outchar{chr(0xea)} = '&ring;';	# combining ring above
    $outchar{chr(0xeb)} = '&llig;';	# combining ligature left half
    $outchar{chr(0xec)} = '&rlig;';	# combining ligature right half
    $outchar{chr(0xed)} = '&rcommaa;';	# combining comma above right
    $outchar{chr(0xee)} = '&dblac;';	# combining double acute
    $outchar{chr(0xef)} = '&candra;';	# combining candrabindu
    $outchar{chr(0xf0)} = '&cedil;';	# combining cedilla
    $outchar{chr(0xf1)} = '&ogon;';	# combining ogonek
    $outchar{chr(0xf2)} = '&dotb;';	# combining dot below
    $outchar{chr(0xf3)} = '&dbldotb;';	# combining double dot below
    $outchar{chr(0xf4)} = '&ringb;';	# combining ring below
    $outchar{chr(0xf5)} = '&dblunder;';	# combining double underscore
    $outchar{chr(0xf6)} = '&under;';	# combining underscore
    $outchar{chr(0xf7)} = '&commab;';	# combining comma below
    $outchar{chr(0xf8)} = '&rcedil;';	# combining right cedilla
    $outchar{chr(0xf9)} = '&breveb;';	# combining breve below
    $outchar{chr(0xfa)} = '&ldbltil;';	# combining double tilde left half
    $outchar{chr(0xfb)} = '&rdbltil;';	# combining double tilde right half
    $outchar{chr(0xfe)} = '&commaa;';	# combining comma above
    if ($XDEBUG) {
        foreach my $num (sort keys %outchar) {
            printf "%x = %s\n", ord($num), $outchar{$num};
        }
    }
    return \%outchar;
}

return 1;

__END__


####################################################################
#                  D O C U M E N T A T I O N                       #
####################################################################

=pod

=head1 NAME

MARC::XML - A subclass of MARC.pm to provide XML support.

=head1 SYNOPSIS

    use MARC::XML;

    #read in some MARC and output some XML
    $myobject = MARC::XML->new("marc.mrc","usmarc");
    $myobject->output({file=>">marc.xml",format=>"xml"});

    #read in some XML and output some MARC
    $myobject = MARC::XML->new("marc.xml","xml");
    $myobject->output({file=>">marc.mrc","usmarc");

=head1 DESCRIPTION

MARC::XML is a subclass of MARC.pm which provides methods for round-trip
conversions between MARC and XML. MARC::XML requires that you have the
CPAN modules MARC.pm and XML::Parser installed in your Perl library.
Version 1.04 of MARC.pm and 2.27 of XML::Parser (or later) are required.
As a subclass of MARC.pm a MARC::XML object will by default have the full
functionality of a MARC.pm object. See the MARC.pm documentation for details.

The XML file that is read and generated by MARC::XML is not associated with a 
Document Type Definition (DTD). This means that your files need to be
well-formed, but they will not be validated. When performing XML->MARC
conversion it is important that the XML file is structured in a particular
way. Fortunately, this is the same format that is generated by the MARC->XML
conversion, so you should be able to be able to move your data easily between
the two formats.

=head2 Downloading and Intalling

=over 4

=item Download

First make sure that you have B<MARC.pm> and B<XML::Parser> installed.
Both Perl extensions are available from the CPAN
http://www.cpan.org/modules/by-module, and they must be available in 
your Perl library for MARC::XML to work properly.

MARC::XML is provided in standard CPAN distribution format. Download the
latest version from http://www.cpan.org/modules/by-module/MARC/XML. It will
extract into a directory MARC-XML-version with any necessary subdirectories.
Once you have extracted the archive Change into the MARC-XML top directory
and execute the following command depending on your platform.

=item Unix

    perl Makefile.PL
    make
    make test
    make install

=item Win9x/WinNT/Win2000

    perl Makefile.PL
    perl test.pl
    perl install.pl

=item Test

Once you have installed, you can check if Perl can find it. Change to some
other directory and execute from the command line:

    perl -e "use MARC::XML"

If you B<do not> get any response that means everything is OK! If you get an
error like I<Can't locate method "use" via package MARC::XML>.
then Perl is not able to find MARC::XML--double check that the file copied
it into the right place during the install.

=back

=head2 Todo

=over 4

=item *

Checking for field and record lengths to make sure that data read in from
an XML file does not exceed the limited space available in a MARC record.

=item *

Support for MARC E<lt>-E<gt> Unicode character conversions.

=item *

MARC E<lt>-E<gt> EAD (Encoded Archival Description) conversion?

=item *

Support for MARC E<lt>-E<gt> DC/RDF (Dublin Core Metadata encoded in the
Resource Description Framework)?

=item *

Support for MARC E<lt>-E<gt> FGDC Metadata (Federal Geographic Data Committee)
conversion?

=back

=head2 Web Interface

A web interface to MARC.pm and MARC::XML is available at
http://libstaff.lib.odu.edu/cgi-bin/marc.cgi where you can upload records and
observe the results. If you'd like to check out the cgi script take a look at
http://libstaff.lib.odu.edu/depts/systems/iii/scripts/MARCpm/marc-cgi.txt
However, to get the full functionality you will want to install MARC.pm and
MARC::XML on your server or PC.

=head2 Sample XML file

Below is an example of the flavor of XML that MARC::XML will generate and read.
There are only four elements: the I<E<lt>marcE<gt>> pair that serves as the
root for the file; the I<E<lt>recordE<gt>> pair that encloses each record;
the I<E<lt>fieldE<gt>> pair which encloses each field; and the
I<E<lt>subfieldE<gt>> pair which encloses each subfield. In addition the
I<E<lt>fieldE<gt>> and I<E<lt>subfieldE<gt>> tags have three possible
attributes: I<type> which defines the specific tag or subfield ; as well as
I<i1> and I<i2> which allow you to define the indicators for a specific tag.

   <?xml version="1.0" encoding="UTF-8" standalone="yes"?>

   <marc>

   <record>
   <field type="000">00901cam  2200241Ia 45e0</field>
   <field type="001">ocm01047729 </field>
   <field type="003">OCoLC</field>
   <field type="005">19990808143752.0</field>
   <field type="008">741021s1884    enkaf         000 1 eng d</field>
   <field type="040" i1=" " i2=" ">
      <subfield type="a">KSU</subfield>
      <subfield type="c">KSU</subfield>
      <subfield type="d">GZM</subfield>
   </field>
   <field type="090" i1=" " i2=" ">
      <subfield type="a">PS1305</subfield>
      <subfield type="b">.A1 1884</subfield>
   </field>
   <field type="049" i1=" " i2=" ">
      <subfield type="a">VODN</subfield>
   </field>
   <field type="100" i1="1" i2=" ">
      <subfield type="a">Twain, Mark,</subfield>
      <subfield type="d">1835-1910.</subfield>
   </field>
   <field type="245" i1="1" i2="4">
      <subfield type="a">The adventures of Huckleberry Finn :</subfield>
      <subfield type="b">(Tom Sawyer's comrade) : scene, the Mississippi Valley : time, forty to fifty years ago /</subfield>
      <subfield type="c">by Mark Twain (Samuel Clemens) ; with 174 illustrations.</subfield>
   </field>
   <field type="260" i1=" " i2=" ">
      <subfield type="a">London :</subfield>
      <subfield type="b">Chatto &amp; Windus,</subfield>
      <subfield type="c">1884.</subfield>
   </field>
   <field type="300" i1=" " i2=" ">
      <subfield type="a">xvi, 438 p., [1] leaf of plates :</subfield>
      <subfield type="b">ill. ;</subfield>
      <subfield type="c">20 cm.</subfield>
   </field>
   <field type="500" i1=" " i2=" ">
      <subfield type="a">First English ed.</subfield>
   </field>
   <field type="500" i1=" " i2=" ">
      <subfield type="a">State B; gatherings saddle-stitched with wire staples.</subfield>
   </field>
   <field type="500" i1=" " i2=" ">
      <subfield type="a">Advertisements on p. [1]-32 at end.</subfield>
   </field>
   <field type="500" i1=" " i2=" ">
      <subfield type="a">Bound in red S cloth; stamped in black and gold.</subfield>
   </field>
   <field type="510" i1="4" i2=" ">
      <subfield type="a">BAL</subfield>
      <subfield type="c">3414.</subfield>
   </field>
   <field type="740" i1="0" i2="1">
      <subfield type="a">Huckleberry Finn.</subfield>
   </field>
   <field type="994" i1=" " i2=" ">
      <subfield type="a">E0</subfield>
      <subfield type="b">VOD</subfield>
   </field>
   </record>

   </marc>

=head1 METHODS

Here is a list of methods available to you in MARC::XML.

=head2 new()

MARC::XML overides MARC.pm's new() method to create a MARC::XML object. 
Similar to MARC.pm's new() it can take two arguments: a file name, and 
the format of the file to read in. However MARC::XML's new() gives you an 
extra format choice "XML" (which is also the default). Internally, the
XML source is converted to a series of B<addfield()> and B<createrecord()>
calls. The order of MARC tags is preserved by default. But if an optional
third argument is passed to new(), it is used as the I<ordered> option for
the B<addfield()> calls. Like MARC.pm, it is not possible to read only part
of an XML input file using new(). Some examples:

      #read in an XML file called myxmlfile.xml
   use MARC::XML;
   $x = MARC::XML->new("myxmlfile.xml","xml");
   $x = MARC::XML->new("needsort.xml","xml","y");

Since the full funtionality of MARC.pm is also available you can read in
other types of files as well. Although new() with no arguments will create
an object with no records, just like MARC.pm, XML format not supported by
openmarc() and nextmarc() for input. The openxml() and nextxml() methods
provide similar operation. And you can output from XML to a different
format source.

      #read in a MARC file called mymarcfile.mrc
   use MARC::XML;
   $x = MARC::XML->new("mymarcfile.mrc","usmarc"); 
   $x = MARC::XML->new(); 

=head2 output()

MARC::XML's output() method allows you to output the MARC object as an XML
file. It takes eight arguments: I<file>, I<format>, I<lineterm>, and
I<records> have the same function as in MARC.pm. If not specified, I<format>
defaults to "xml" and I<lineterm> defaults to "\n". A I<charset> parameter
accepts a hash-reference to a user supplied character translation table.
The internal default is based on the LoC "register.sgm" table supplied
with the LoC. SGML utilities. You can use the B<ansel_default> method to get
a hash-reference to it if you only want to modify a couple of characters.
See example below. The I<encoding>, I<dtd_file>, and I<standalone> arguments
correspond to the specified fields in an XML header. If not specified,
I<standalone> defaults to "yes" and I<encoding> to "US-ASCII". If an optional
I<dtd_file> is specified, a B<Document Type Declaration> is added to the
output to contain the data.

   use MARC::XML;
   $x = MARC::XML->new("mymarcfile.mrc","usmarc");
   $x->output({file=>">myxmlfile.xml",format=>"xml"});

Or if you only want to output the first record:

   $x->output({file=>">myxmlfile.xml",format=>"xml",records=>[1]});

If you like you can also output portions of the XML file using the I<format> 
options: I<xml_header>, I<xml_body>, and I<xml_footer>. Remember to prefix
your file name with a >> to append though. This example will output
record 1 twice.

   use MARC::XML;
   $x = MARC::XML->new("mymarcfile.mrc","usmarc");
   $x->output({file=>">myxmlfile.xml",format=>"xml_header"});
   $x->output({file=>">>myxmlfile.xml",format=>"xml_body",records=>[1]});
   $x->output({file=>">>myxmlfile.xml",format=>"xml_body",records=>[1]});
   $x->output({file=>">>myxmlfile.xml",foramt=>"xml_footer"});

Instead of outputting to a file, you can also capture the output in a
variable if you wish.

   use MARC::XML;
   $x = MARC::XML->new("mymarcfile.mrc","usmarc");
   $myxml = $x->output({format=>"xml"});

As with new() the full functionality of MARC.pm's output() method are
available to you as well. 
So you could read in an XML file and then output it as ascii text:

   use MARC::XML;
   $x = MARC::XML->new("myxmlfile.xml","xml");
   $x->output({file=>">mytextfile.txt","ascii");

=head1 NOTES

Please let us know if you run into any difficulties using MARC.pm--we'd be
happy to try to help. Also, please contact us if you notice any bugs, or
if you would like to suggest an improvement/enhancement. Email addresses 
are listed at the bottom of this page.

Development of MARC.pm and other library oriented Perl utilities is conducted
on the Perl4Lib listserv. Perl4Lib is an open list and is an ideal place to
ask questions about MARC.pm. Subscription information is available at
http://www.vims.edu/perl4lib

Two global boolean variables are reserved for test and debugging. Both are
"0" (off) by default. The C<$XTEST> variable disables internal error messages
generated using I<Carp>. It should only be used in the automatic test suite.
The C<$XDEBUG> variable adds verbose diagnostic messages.

=head1 EXAMPLES

The B<eg> subdirectory contains a few complete examples to get you started.

=head1 AUTHORS

Chuck Bearden cbearden@rice.edu

Bill Birthisel wcbirthisel@alum.mit.edu

Derek Lane dereklane@pobox.com

Charles McFadden chuck@vims.edu

Ed Summers ed@cheetahmail.com

=head1 SEE ALSO

perl(1), MARC.pm, MARC http://lcweb.loc.gov/marc , XML http://www.w3.org/xml .

=head1 COPYRIGHT

Copyright (C) 1999,2000, Bearden, Birthisel, Lane, McFadden, and Summers.
All rights reserved. This module is free software; you can redistribute
it and/or modify it under the same terms as Perl itself. 23 April 2000.
Portions Copyright (C) 1999,2000, Duke University, Lane.

=cut

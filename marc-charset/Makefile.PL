use 5.8.0;
use lib "lib";
use ExtUtils::MakeMaker;
use File::Find;
use File::Copy;
use Unicode::UCD qw( charinfo );
use MARC::Charset;
use MARC::Charset::Generic qw( :all );

find( \&filecheck, "." );

eval( 'use DB_File' );
if ( !$@ ) { makeDbs() }
else { print <<WARNING; exit(0); }

DB_File does not appear to be installed. You must have DB_File installed to
work with EastAsian character sets, and to reverse map UTF-8 to MARC-8
characters. You can download DB_File from CPAN.

WARNING


&WriteMakefile(
	NAME		=> 'MARC::Charset',
	DISTNAME	=> 'MARC-Charset',
	VERSION_FROM	=> 'lib/MARC/Charset.pm',
	ABSTRACT_FROM	=> 'lib/MARC/Charset.pm',
	PMLIBDIRS	=> [ qw( lib/ ) ],
	AUTHOR		=> 'Ed Summers <ehs@pobox.com>',
	PREREQ_PM	=> 
			    {
			    'Test::More'    => 0,
			    'DB_File'	    => 1,
			    },
	dist 		=> 
			    {
			    COMPRESS	    => 'gzip -9f', 
			    SUFFIX	    => 'gz',
			    },
	depend		=> 
			    { 
			    Makefile	    => '$(VERSION_FROM)'
			    },
	);


## this section looks for text data files to create BerkeleyDBs
## from. These dbs are used for large mappings, that are used off 
## disk instead of putting huge hashes into memory.
##
## Note: last I checked DB_File didn't handle UTF8 as values very well
## so we just store the character as an integer and unicodeify it when we 
## need to in MARC::Charset::EastAsian::lookup()
##
## The reverse mapping database maps the hex value of a unicode
## character to a delimited string which contains the MARC-8 character, 
## the character set it belongs to, and a flag indicating if it is a 
## combining character or not.

sub makeDbs {

    print "creating character mapping databases...this might take a while\n";

    ## create a berkeley db for our reverse mapping (UTF-8 => MARC-8)
    unlink( "lib/MARC/Charset/UTF8.db" ) if -f "lib/MARC/Charset/UTF8.db";
    tie( my %reverse, 'DB_File', 'lib/MARC/Charset/UTF8.db' )
	|| die 'unable to create lib/MARC/Charset/UTF8.db';

    ## we need a forward mapping db for EastAsian since it is so huge
    ## but we'll add to the reverse mapping as we go along
    unlink( "lib/MARC/Charset/EastAsian.db" ) 
	if -f "lib/MARC/Charset/EastAsian.db";
    tie( my %db, "DB_File", "lib/MARC/Charset/EastAsian.db" )
	|| die "unable to create lib/MARC/Charset/EastAsian.db: $!";
    open( IN, "data/EastAsian.txt" ) 
	|| die "couldn't find data/EastAsian.txt: $!";
    while ( my $line = <IN> ) {
	next if $line =~ /^#/; ## skip any comments
	my @cols = split/,/,$line;
	my @from = ( $cols[0] =~ /(..)(..)(..)/ );
	my $key;
	foreach ( @from ) { $key .= chr( hex($_) ); }
	my $value = hex( $cols[1] ); 
	$db{ $key } = $value;
	$reverse{ $value } = MARC::Charset::_pack( $key, CJK, 0 );
    }
    untie( %db );

    ## the order here is significant since there can be some overlap
    my @charsetCodes = (
	ASCII_DEFAULT, EXTENDED_LATIN, 
	BASIC_ARABIC, EXTENDED_ARABIC,
	BASIC_CYRILLIC, EXTENDED_CYRILLIC, 
	BASIC_GREEK, BASIC_HEBREW,
	GREEK_SYMBOLS, SUBSCRIPTS, SUPERSCRIPTS
    );

    no strict;
    foreach my $code ( @charsetCodes ) {

	$charset = MARC::Charset::_getCharset( $code );
	$marc2unicode = ref( $charset ) . '::marc2unicode';

	while ( my ($marc8,$utf8) = each %{ $marc2unicode } ) {
	    my $ord = ord( $utf8 );
	    my $char = charinfo( $ord );
	    ## if there is already a mapping for this character we don't
	    ## overwrite the existing one
	    next if exists( $reverse{ $ord } ); 
	    $reverse{ $ord } = MARC::Charset::_pack( $marc8, $code, 
		$char->{ combining } );
	}

    }
    untie( %reverse ); 

}

untie( %reverse );

if ( shift eq 'sfdocs' ) {
    print "making HTML and PDF for SourceForge\n";
    mkdir("sfdocs");
    find( { wanted => \&sfdocs, no_chdir => 1 }, "lib" ); 
    unlink <*~~>;
    system( "tar cvfz sfdocs.tar.gz sfdocs/ > /dev/null");
    system( "rm -rf sfdocs" );
}


## make sure files aren't in mid-edit

sub filecheck {
	unlink if /~$/;	# Remove any vi backup files
	die "Aborting: Swapfile $_ found" if /\.swp$/;
}


## build documentation for sourceforge

sub sfdocs {
    if ( $File::Find::name =~ m|.+/(.+)\.pm$| ) {
	my $html = "$1.html";
	my $pdf = "$1.pdf";
	system( "pod2html $File::Find::name > sfdocs/$html" );
	system( "pod2pdf $File::Find::name" );
	move( "$File::Find::name.pdf", "sfdocs/$pdf" );
    }
}



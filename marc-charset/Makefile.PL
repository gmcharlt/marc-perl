use 5.8.0;
use strict;
use ExtUtils::MakeMaker;
use File::Find;
use File::Copy;

find( \&filecheck, "." );

eval( 'use DB_File' );
if ( !$@ ) { makeDbs() }
else { print <<WARNING; exit(0); }

DB_File not installed, so we can't build East Asian character
database. This is BAD if you want to work with EastAsian character 
data. DB_File is used to lower the memory footprint of MARC::Charset when 
working with EastAsian character data. Please install DB_File available from 
you nearest CPAN mirror. 

WARNING


sub filecheck {
	unlink if /~$/;	# Remove any vi backup files
	die "Aborting: Swapfile $_ found" if /\.swp$/;
}

&WriteMakefile(
	NAME		=> 'MARC::Charset',
	DISTNAME	=> 'MARC-Charset',
	VERSION_FROM	=> 'lib/MARC/Charset.pm',
	ABSTRACT_FROM	=> 'lib/MARC/Charset.pm',
	PMLIBDIRS	=> [ qw( lib/ ) ],
	AUTHOR		=> 'Ed Summers <ehs@pobox.com>',
	PREREQ_PM	=> {
			    'Test::More'    => 0,
			    'DB_File'	    => 1,
			    },
	dist 		=> {
			    COMPRESS => 'gzip -9f', 
			    SUFFIX => 'gz',
			    },
	depend		=> { 
			    Makefile => '$(VERSION_FROM)'
			    },
	);


## this section looks for text data files to create BerkeleyDBs
## from. These dbs are used for large mappings, that are used off 
## disk instead of putting huge hashes into memory.
##
## Note: last I check DB_File didn't handle UTF8 as values very well
## so we just store the hex as a string and unicodeify it when we need
## to in MARC::Charset::EastAsian::lookup()
##
## The idea here was to make it easy to extend this code if we wanted
## to use Berkeley DBs for other character lookups. But it's just East
## Asian at the moment.

sub makeDbs {
    foreach my $db ( 'EastAsian' ) {
	next if ! -f "data/$db.txt";
	tie( my %db, "DB_File", "lib/MARC/Charset/$db.db" )
	    || die "unable to create lib/MARC/Charset/$db.db: $!";
	open( IN, "data/$db.txt" ) 
	    || die "couldn't find data/$db.txt: $!";
	print "creating DB_File lib/MARC/Charset/$db.db\n";
	while ( my $line = <IN> ) {
	    next if $line =~ /^#/; ## skip any comments
	    my @cols = split/,/,$line;
	    my @from = ( $cols[0] =~ /(..)(..)(..)/ );
	    my $key;
	    foreach ( @from ) { $key .= chr( hex($_) ); }
	    my $value = $cols[1];
	    $db{ $key } = $value;
	}
	untie(%db);
    }
}


if ( shift eq 'sfdocs' ) {
    print "making HTML and PDF for SourceForge\n";
    mkdir("sfdocs");
    find( { wanted => \&sfdocs, no_chdir => 1 }, "lib" ); 
    unlink <*~~>;
    system( "tar cvfz sfdocs.tar.gz sfdocs/ > /dev/null");
    system( "rm -rf sfdocs" );
}

sub sfdocs {
    if ( $File::Find::name =~ m|.+/(.+)\.pm$| ) {
	my $html = "$1.html";
	my $pdf = "$1.pdf";
	system( "pod2html $File::Find::name > sfdocs/$html" );
	system( "pod2pdf $File::Find::name" );
	move( "$File::Find::name.pdf", "sfdocs/$pdf" );
    }
}



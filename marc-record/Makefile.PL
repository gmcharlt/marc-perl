use 5.005;
use strict;
use ExtUtils::MakeMaker;
use File::Find;
use File::Copy;

find( \&filecheck, "." );

sub filecheck {
	unlink if /~$/;	# Remove any vi backup files
	die "Aborting: Swapfile $_ found" if /\.swp$/;
}

&WriteMakefile(
	NAME		=> 'MARC::Record',
	DISTNAME	=> 'MARC-Record',
	VERSION_FROM	=> 'lib/MARC/Record.pm',
	ABSTRACT_FROM	=> 'lib/MARC/Record.pm',
	PMLIBDIRS	=> [ qw( lib/ ) ],
	AUTHOR		=> 'Andy Lester <andy@petdance.com>',
	PREREQ_PM	=> {
			    'Test::More' => 0,
			    },
	EXE_FILES	=> [ qw( pl/marcdump pl/marclint ) ],
	dist 		=> {
			    COMPRESS => 'gzip -9f', 
			    SUFFIX => 'gz',
			    },
	depend		=> { 
			    Makefile => '$(VERSION_FROM)'
			    },
	
	);


## this is a handy routine for building PDF and HTML documentation
## from POD for the marcpm.sf.net website

if ( shift eq 'sfdocs' ) {
    print "making HTML and PDF for SourceForge, sfdocs.tar.gz\n";
    mkdir("sfdocs");
    find( { wanted => \&sfdocs, no_chdir => 1 }, "lib" ); 
    unlink <*~~>;
    system( "tar cvfz sfdocs.tar.gz sfdocs/ > /dev/null");
    system( "rm -rf sfdocs" );
}

sub sfdocs {
    if ( $File::Find::name =~ m{.+/(.+)\.(pm|pod)$} ) {
	my $html = "$1.html";
	my $pdf = "$1.pdf";
	system( "pod2html $File::Find::name > sfdocs/$html" );
	system( "pod2pdf $File::Find::name" );
	move( "$File::Find::name.pdf", "sfdocs/$pdf" );
    }
}


use 5.6.0;
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
	NAME		=> 'MARC::Charset',
	DISTNAME	=> 'MARC-Charset',
	VERSION_FROM	=> 'lib/MARC/Charset.pm',
	ABSTRACT_FROM	=> 'lib/MARC/Charset.pm',
	PMLIBDIRS	=> [ qw( lib/ ) ],
	AUTHOR		=> 'Ed Summers <ehs@pobox.com>',
	PREREQ_PM	=> {
			    'Test::More' => 0,
			    },
	dist 		=> {
			    COMPRESS => 'gzip -9f', 
			    SUFFIX => 'gz',
			    },
	depend		=> { 
			    Makefile => '$(VERSION_FROM)'
			    },
	);

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



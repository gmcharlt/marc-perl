use 5.6.0;
use strict;
use ExtUtils::MakeMaker;

use File::Find;

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
	EXE_FILES	=> [ qw( pl/marc2unicode ) ],
	dist 		=> {
			    COMPRESS => 'gzip -9f', 
			    SUFFIX => 'gz',
			    },
	depend		=> { 
			    Makefile => '$(VERSION_FROM)'
			    },
	);


use 5.005;
use strict;
use ExtUtils::MakeMaker;

use File::Find;

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
	PREREQ_PM	=> {},
	EXE_FILES	=> [ qw( pl/marcdump pl/marclint pl/lif2marc ) ],
	dist 		=> {
				COMPRESS => 'gzip -9f', 
				SUFFIX => 'gz',
				},
	);


use strict;
use ExtUtils::MakeMaker;

&WriteMakefile(
    NAME          => 'MARC::File::MARCMaker',
    DISTNAME      => 'MARC-File-MARCMaker',
    VERSION_FROM  => 'lib/MARC/File/MARCMaker.pm',
    AUTHOR        => 'Bryan Baldus <eijabb@cpan.org>',
    META_MERGE    => {
        'meta-spec' => { version => 2 },
        resources   => {
            repository => {
                type => 'git',
                url  => 'https://github.com/perl4lib/marc-perl.git',
                web  => 'https://github.com/perl4lib/marc-perl/tree/master/marc-marcmaker',
            },
            bugtracker => {
                web => 'https://github.com/perl4lib/marc-perl/issues',
            },
        },
    },
    LICENSE       => 'perl',
    PREREQ_PM     => {
                        'Test::More' => 0,
                        'MARC::Record' => 0,
                     },
    EXE_FILES     => [ qw( bin/mkr2mrc bin/mrc2mkr ) ],
);

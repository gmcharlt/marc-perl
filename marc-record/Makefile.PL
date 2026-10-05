# vi:et:sw=4 ts=4
require v5.8.2;
use strict;
use ExtUtils::MakeMaker;

&WriteMakefile(
    NAME            => 'MARC::Record',
    DISTNAME        => 'MARC-Record',
    VERSION_FROM    => 'lib/MARC/Record.pm',
    ABSTRACT_FROM   => 'lib/MARC/Record.pm',
    PMLIBDIRS       => [ qw( lib/ ) ],
    AUTHOR          => 'Galen Charlton <gmcharlt@gmail.com>',
    LICENSE         => 'perl',
    META_MERGE      => {
        'meta-spec' => { version => 2 },
        resources   => {
            repository => {
                type => 'git',
                url  => 'https://github.com/perl4lib/marc-perl.git',
                web  => 'https://github.com/perl4lib/marc-perl/tree/master/marc-record',
            },
            bugtracker => {
                web => 'https://github.com/perl4lib/marc-perl/issues',
            },
        },
    },
    PREREQ_PM       => {
        'Test::More' => 0,
        'File::Spec' => 0,
        'File::Find' => 0,
        'Carp' => 0,
    },
    EXE_FILES       => [ qw( bin/marcdump ) ],
    dist            => {
        COMPRESS => 'gzip -9f',
        SUFFIX => 'gz',
    },
    depend          => {
        Makefile => '$(VERSION_FROM)'
    },
    clean           => { FILES => 'MARC-Record-*' },
    
);

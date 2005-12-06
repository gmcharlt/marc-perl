use 5.8.0;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'MARC::Charset',
    DISTNAME        => 'MARC-Charset',
    VERSION_FROM    => 'lib/MARC/Charset.pm',
    ABSTRACT_FROM   => 'lib/MARC/Charset.pm',
    AUTHOR          => 'Ed Summers <ehs@pobox.com>',
    PREREQ_PM       => {'Test::More' => 0, 'DB_File' => 1},
);

use lib 'lib';
use MARC::Charset::Compiler;

print "compiling marc8/utf8 database, please be patient\n";
my $compiler = MARC::Charset::Compiler->new();
$compiler->compile('etc/codetables.xml');

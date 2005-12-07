use 5.8.0;
use ExtUtils::MakeMaker;

my $ok = WriteMakefile(
    NAME            => 'MARC::Charset',
    DISTNAME        => 'MARC-Charset',
    VERSION_FROM    => 'lib/MARC/Charset.pm',
    ABSTRACT_FROM   => 'lib/MARC/Charset.pm',
    AUTHOR          => 'Ed Summers <ehs@pobox.com>',
    PREREQ_FATAL    => 1,
    PREREQ_PM       => {
                            'Test::More'        => 0, 
                            'XML::SAX'          => 0,
                            'Class::Accessor'   => 0,
                       },
);

# get the compiler from the lib directory and use it to compile
# the LoC XML mapping file into a database 

eval('use lib "lib"; use MARC::Charset::Compiler');

print "compiling marc8/utf8 database, please be patient\n";
my $compiler = MARC::Charset::Compiler->new();
$compiler->compile('etc/codetables.xml');

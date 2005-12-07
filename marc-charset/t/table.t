use Test::More qw(no_plan);
use strict;
use warnings;

use_ok('MARC::Charset::Table');

# constructor
my $table = MARC::Charset::Table->new();
isa_ok($table, 'MARC::Charset::Table');

# underlying db
isa_ok($table->db(), 'HASH', 'db()');
like($table->db_path(), qr|MARC/Charset/Table|, 'db_path()');

# fake the table into thinking it's a hash don't want to change the 
# real db that was created when we ran Makefile.PL
$table->{db} = {};

# add a code
my $code = MARC::Charset::Code->new();
$code->name('UPPERCASE POLISH L');
$code->marc('A1');
$code->ucs('0141');
$code->charset('45');
$table->add_code($code);

# see if we can get it back
my $retrieved_code = $table->get_code($code->hash_code());
is($retrieved_code->to_string(), $code->to_string(), 'add_code() & get_code()');



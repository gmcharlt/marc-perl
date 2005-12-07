package MARC::Charset::Table;

use strict;
use warnings;
use POSIX;
use AnyDBM_File;
use MARC::Charset::Code;
use MARC::Charset::Constants qw(:all);
use Storable qw(freeze thaw);

=head2 new()

The consturctor.

=cut

sub new
{
    my $class = shift;
    my $self = bless {}, ref($class) || $class;
    $self->_init(O_RDWR);
    return $self;
}


=head2 add_code()

Add a MARC::Charset::Code to the table.

=cut


sub add_code
{
    my ($self, $code) = @_;
    my $key = $code->hash_code();
    $self->{db}->{$key} =  freeze($code);
}


=head2 get_code()

Retrieve a code using the hash key.

=cut

sub get_code
{
    my ($self, $key) = @_;
    my $db = $self->db();
    my $frozen = $db->{$key};
    return thaw($frozen) if $frozen;
    return undef;
}


=head2 lookup()

Looks up MARC::Charset::Code entry using a character set code and a MARC-8 
value.

    use MARC::Charset::Constants qw(HEBREW);
    $code = $table->lookup(HEBREW, chr(0x60));

=cut

sub lookup
{
    my ($self, $charset, $marc8) = @_;
    $charset = BASIC_LATIN if $charset eq ASCII_DEFAULT;
    return $self->get_code(sprintf('%s:%s', $charset, $marc8));
}


=head2 db()

Returns a reference to a tied character database. MARC::Charset::Table
wraps access to the db, but you can get at it if you want.

=cut

sub db 
{
    return shift->{db};
}


=head2 db_path()

Returns the path to the character encoding database. Can be called 
statically too: 

    print MARC::Charset::Table->db_path();

=cut

sub db_path
{
    my $path = $INC{'MARC/Charset/Table.pm'};
    $path =~ s/\.pm$//;
    return $path;
}


=head2 brand_new()

An alternate constructor which removes the existing database and starts
afresh. Be careful with this one, it's really only used on MARC::Charset
installation.

=cut

sub brand_new 
{
    my $class = shift;
    my $self = bless {}, ref($class) || $class;
    $self->_init(O_CREAT|O_RDWR);
    return $self;
}


# helper function for initializing table internals

sub _init 
{
    my ($self,$opts) = @_;
    tie my %db, 'AnyDBM_File', db_path(), $opts, 0644;
    $self->{db} = \%db;
}





1;

package MARC::Charset;

=head1 NAME

MARC::Charset - A module for doing MARC-8/UTF8 translation

=cut 

use 5.8.0;
use strict;
use base qw( Exporter );

our $VERSION = 0.4;

=head1 SYNOPSIS

 use MARC::Charset;

 ## create a MARC::Charset object
 my $charset = MARC::Charset->new();

 ## a string containing the Ansel value for a copyright symbol 
 my $ansel = chr(0xC3) . ' copyright 1969'.

 ## the same string, but now encoded in UTF8!
 my $utf8 = $charset->to_utf8($extLatin);

=head1 DESCRIPTION

MARC::Charset is a package that allows you to easily convert between
the MARC-8 character encodings and Unicode (UTF-8). The Library of Congress 
maintains some essential mapping tables and information about the MARC-8 and 
Unicode environments at:

 http://www.loc.gov/marc/specifications/spechome.html

MARC::Charset is essentially a Perl implementation of the specifications 
found at LC, and supports the following character sets:

=over 4 

=item * Latin (Basic/Extended + Greek Symbols, Subscripts and Superscripts)

=item * Hebrew

=item * Cyrillic (Basic + Extended)

=item * Arabic (Basic + Extended)

=item * Greek

=item * East Asian Characters 

Includes 13,478 "han" characters, Japanese Hiragana and Katakana (172 
characters), Korean Hangul (2,028 characters), East Asian Punctuation 
Marks (25 characters), "Component Input Method" Characters (35 characters)

=back

=cut


## Packages for default character sets, and other small ones
## We will load larger character sets dynamically as needed to hopefully 
## save a bit on our memory footprint

use MARC::Charset::Controls;
use MARC::Charset::ASCII;
use MARC::Charset::Ansel;
use MARC::Charset::Subscripts;
use MARC::Charset::Superscripts;
use MARC::Charset::GreekSymbols;

my $controls = MARC::Charset::Controls->new();


## Constants for object attributes
## That's right, it's a blessed array so we can get any speed pickup 
## we can get when pulling stuff later

use constant G0			=> 0;
use constant G1			=> 1;
use constant DIAGNOSTICS	=> 2;


## Constants for escaping to different character sets
## we allow export of these constants for testing purposes

## Technique #1

use constant ESCAPE		=> chr(0x1B);
use constant GREEK_SYMBOLS	=> chr(0x67);
use constant SUBSCRIPTS		=> chr(0x62);
use constant SUPERSCRIPTS	=> chr(0x70);
use constant ASCII_DEFAULT	=> chr(0x73);

## Technique #2 

use constant SINGLE_G0_A	=> chr(0x28);
use constant SINGLE_G0_B	=> chr(0x2C);
use constant MULTI_G0_A		=> chr(0x24);
use constant MULTI_G0_B		=> chr(0x24) . chr(0x2C);

use constant SINGLE_G1_A	=> chr(0x29);
use constant SINGLE_G1_B	=> chr(0x2D);
use constant MULTI_G1_A		=> chr(0x24) . chr(0x29);
use constant MULTI_G1_B		=> chr(0x24) . chr(0x2D);

use constant BASIC_ARABIC	=> chr(0x33);
use constant EXTENDED_ARABIC	=> chr(0x34);
use constant BASIC_LATIN	=> chr(0x42);
use constant EXTENDED_LATIN	=> chr(0x45);
use constant CJK		=> chr(0x31);
use constant BASIC_CYRILLIC	=> chr(0x4E);
use constant EXTENDED_CYRILLIC	=> chr(0x51);
use constant BASIC_GREEK	=> chr(0x53);
use constant BASIC_HEBREW	=> chr(0x32);

our %EXPORT_TAGS = ( all => 
	[ qw( 
	ESCAPE  GREEK_SYMBOLS  SUBSCRIPTS  SUPERSCRIPTS  ASCII_DEFAULT 
	SINGLE_G0_A  SINGLE_G0_B  MULTI_G0_A  MULTI_G0_B  SINGLE_G1_A 
	SINGLE_G1_B  MULTI_G1_A  MULTI_G1_B  BASIC_ARABIC  
	EXTENDED_ARABIC  BASIC_LATIN  EXTENDED_LATIN CJK  BASIC_CYRILLIC  
	EXTENDED_CYRILLIC BASIC_GREEK BASIC_HEBREW
	) ]
    );

our @EXPORT_OK = qw(
	ESCAPE  GREEK_SYMBOLS  SUBSCRIPTS  SUPERSCRIPTS  ASCII_DEFAULT 
	SINGLE_G0_A  SINGLE_G0_B  MULTI_G0_A  MULTI_G0_B  SINGLE_G1_A 
	SINGLE_G1_B  MULTI_G1_A  MULTI_G1_B  BASIC_ARABIC  
	EXTENDED_ARABIC  BASIC_LATIN  EXTENDED_LATIN CJK  BASIC_CYRILLIC  
	EXTENDED_CYRILLIC BASIC_GREEK BASIC_HEBREW
    );




=head1 METHODS

=head2 new()

The constructor which will return  MARC::Charset object. If you like 
you can pass in the default G0 and G1 charsets (using the g0 and g1
parameters, but if you don't ASCII/Ansel will be assumed.

 ## for standard characters sets: ASCII and Ansel
 my $cs = MARC::Charset->new(); 

 ## or if you want to specify Arabic Basic + Extended as the G0/G1 character
 ## sets. 
 my $cs = MARC::Charset->new( 
    g0 => MARC::Charset::ArabicBasic->new(),
    g1 => MARC::Charset::ArabicExtended->new()
 );

If you would like diagnostics turned on pass in the DIAGNOSTICS 
parameter and set it to a value that will evaluate to true (eg. 1).

 my $cs = MARC::Charset->new( diagnostics => 1 );

=cut 

sub new {

    my ($class,%args) = @_;
    my $self = bless [ ], ref($class) || $class;

    ## lowercase all the parameters 
    %args = map { lc($_) => $args{$_} } keys(%args);

    $self->[ DIAGNOSTICS ] = $args{ diagnostics };

    ## set the default working graphical charset 0 (G0)
    if (ref($args{ g0 }) =~ /^MARC::Charset/ ) {
	$self->g0($args{ g0 });
    } else {
	$self->g0( MARC::Charset::ASCII->new() );
    }

    ## set the default working graphical charset 1 (G1)
    if (ref($args{ g1 }) =~ /^MARC::Charset/ ) {
	$self->g1($args{ g1 });
    } else {
	$self->g1( MARC::Charset::Ansel->new() );
    }

    return($self);

}


=head2 to_utf8()

Pass to_utf8() a string of MARC8 encoded characters and get back a string
of UTF8 characters. to_utf8() will handle escape sequences within the string 
that change the working character sets to Greek, Hebrew, Arabic (Basic + 
Extended), Cyrillic (Basic + Extended), and East Asian. 

=cut

sub to_utf8 ($) {

    my ($self,$str) = @_;

    ## we delegate the work to an internal method which takes 
    ## a reference to a string (to avoid copying if the string is very long), 
    ## as well as the initial left and right index which will 
    ## change as _marc2unicode is called recursively
    return( $self->_marc2utf8(\$str,0,length($str)) );

}


=head2 g0() 

Returns an object representing the character set that is being used as 
the first graphic character set (G0). If you pass in a MARC::Charset::* 
object you will set the G0 character set, and as a side effect you'll get the 
previous G0 value returned to you. You probably don't ever need to call this 
since character set changes are handled when you call to_utf8(), but it's here 
if you want it.

 ## set the G0 character set to Greek
 my $charset = MARC::Charset->new();
 $charset->g0( MARC::Charset::Greek->new() );

=cut

sub g0 {
    my ($self,$arg) = @_;
    return( $self->_g(0,$arg) );
}


=head2 g1()

Same as g0() above, but operates on the second graphic set that is available.

=cut


sub g1 {
    my ($self,$arg) = @_;
    return( $self->_g(1,$arg) );
}
	

=head1 TODO

=over 4

=item * to_marc8()

A function for going from Unicode to MARC-8 character encodings.

=back

=head1 SEE ALSO

=over 4

=item L<MARC::Charset::ASCII>

=item L<MARC::Charset::Ansel>

=item L<MARC::Charset::ArabicBasic>

=item L<MARC::Charset::ArabicExtended>

=item L<MARC::Charset::Controls>

=item L<MARC::Charset::CyrillicBasic>

=item L<MARC::Charset::CyrillicExtended>

=item L<MARC::Charset::EastAsian>

=item L<MARC::Charset::Greek>

=item L<MARC::Charset::GreekSymbols>

=item L<MARC::Charset::Hebrew>

=item L<MARC::Charset::Subscripts>

=item L<MARC::Charset::Superscripts>

=back

=head1 VERSION HISTORY

=over 4

=item * 

v.01 - 2002.07.17 (ehs)

=back 

=cut


=head1 AUTHORS

=over 4

=item Ed Summers <ehs@pobox.com>

=back

=cut



## Internal Subroutines & Methods


## This is our workhorse for doing the translation, and is normally 
## only called by to_utf8() which optimizes some stuff by making sure 
## _marc2unicode() gets a reference to a string, a left index, a right index 

sub _marc2utf8 {

    my ($self,$strRef) = @_;
    my $index = 0;
    my $length = length($$strRef);
    my $newString = '';
    my $combining = '';
    
    CHAR_LOOP: while ( $index < $length ) {

	my @G = ( $self->[G0], $self->[G1], $controls );
	my $new;
	my $saveIndex = $index;

	CHARSET_LOOP: foreach my $g ( @G ) {

	    my $charSize = $g->getCharSize();
	    my $old = substr( $$strRef, $index, $charSize );
	    if ( $old =~ /^\x1B/ ) { 
		my $newIndex = $self->_escape($strRef,$index,$length);
		if ( $newIndex != $index ) { 
		    $index = $newIndex;
		    next CHAR_LOOP;
		}
	    }

	    if ( $g->combining($old) ) {
		$combining .= $g->lookup($old);
		$index += $charSize;
		next CHAR_LOOP;
	    }

	    $new = $g->lookup( $old );
	    if ( defined($new) ) {
		$index += $charSize;
		last CHARSET_LOOP;
	    }

	}

	if ( ! defined( $new ) and $combining eq '' ) { 
	    if ( $self->[ DIAGNOSTICS ] ) {
		my $g0 = $self->[G0];
		my $g1 = $self->[G1];
		_warning(
		    "no mapping to a valid character at position ".
		    ($saveIndex+1) .  ': considered ' .
		    _getHex( $strRef, $g0, $saveIndex ) . " in " . $g0->name(). 
		    ' ; ' . 
		    _getHex( $strRef, $g1, $saveIndex ) . " in " . $g1->name().
		    ' ; ' . 
		    _getHex( $strRef, $controls, $saveIndex ) . " in ".
		    $controls->name()
		);
	    }
	    $index++;
	}
	
	else {
	    $newString .= $new . $combining;
	    $combining = '';
	}

    }

    return( $newString.$combining ); 

}

sub _escape($$$$) {

    ## this stuff is kind of scary ... for an explanation of what is 
    ## going on here check out the MARC-8 specs at LC. 
    ## http://lcweb.loc.gov/marc/specifications/speccharmarc8.html
    ## see the section "Technique 2: Other Alternate Graphic Character Sets"

    my ($self,$strRef,$left,$right) = @_;

    ## if we don't have at least one character after the escape
    ## then this can't be a character escape sequence
    return($left) if ($left+1 >= $right); 

    my $escChar1 = substr($$strRef,$left+1,1);
    my $newLeft = $left+2;

    my ( $newCharset, $setNumber );

    ## the first method of escaping to small character sets

    if ( $escChar1 eq GREEK_SYMBOLS ) {
	$newCharset = MARC::Charset::GreekSymbols->new();
    } elsif ( $escChar1 eq SUBSCRIPTS ) {
	$newCharset = MARC::Charset::Subscripts->new();
    } elsif ( $escChar1 eq SUPERSCRIPTS ) {
	$newCharset = MARC::Charset::Superscripts->new();
    } elsif ( $escChar1 eq ASCII_DEFAULT ) {
	$newCharset = MARC::Charset::ASCII->new();
    }

    if ($newCharset) {
	$self->g0($newCharset); 
	return($newLeft);
    }

    ## the second more complicated method of escaping to bigger charsets 

    return($left) if ($left+2 >= $right);
    $newLeft = $left+3;

    my $escChar2 = substr($$strRef,$left+2,1);
    my $escChars = $escChar1.$escChar2;


    if ( $escChar1 eq SINGLE_G0_A or $escChar1 eq SINGLE_G0_B ) {
	$setNumber = 0;
	$newCharset = _getCharset( $escChar2 );
    }

    elsif ( $escChar1 eq SINGLE_G1_A or $escChar1 eq SINGLE_G1_B ) {
	$setNumber = 1;
	$newCharset = _getCharset( $escChar2 );
    }

    elsif ( ( $escChars eq MULTI_G1_A  or $escChars eq MULTI_G1_B ) and 
	    ($left + 3 < $right) ) {
	$setNumber = 1;
	$newLeft = $left+4;
	$newCharset = _getCharset( substr( $$strRef, $left+3, 1 ) );
    }

    elsif ( $escChars eq MULTI_G0_B and ($left + 3 < $right ) ) {
	$setNumber = 0;
	$newLeft = $left+4;
	$newCharset = _getCharset( substr( $$strRef, $left+3, 1 ) );
    }

    elsif ( $escChar1 eq MULTI_G0_A ) {
	$setNumber = 0;
	$newCharset = _getCharset( $escChar2 );
    }

    if ($newCharset) {
	$self->_g( $setNumber, $newCharset );
	return($newLeft);
    } else {
	_warning( "invalid character escape at position $left" );
	return($left);
    }
	
}

sub _g {
    my ($self,$g,$arg) = @_;
    if (ref($arg) =~ /^MARC::Charset::/) {
	my $tmp = $self->[ $g ];
	$self->[ $g ] = $arg;
	return( $tmp );
    }
    return($self->[ $g ]);
}

sub _warning {
    my $message = shift;
    print STDERR __PACKAGE__ . " : $message\n";
}

sub _getCharset {

    my $code = shift;

    ## not the use of 1; to ensure that the eval doesn't emit warnings

    if ( $code eq BASIC_ARABIC ) { 
	eval( "use MARC::Charset::ArabicBasic; 1;" );
	return( MARC::Charset::ArabicBasic->new() );
    } 
    
    elsif ( $code eq EXTENDED_ARABIC ) {
	eval( "use MARC::Charset::ArabicExtended; 1;" );
	return( MARC::Charset::ArabicExtended->new() );
    } 
    
    elsif ( $code eq BASIC_LATIN ) {
	eval( "use MARC::Charset::ASCII; 1;" );
	return( MARC::Charset::ASCII->new() );
    } 

    elsif ( $code eq EXTENDED_LATIN ) {
	eval( "use MARC::Charset::Ansel; 1;" );
	return( MARC::Charset::Ansel->new() );
    }
    
    elsif ( $code eq CJK ) {
	eval( "use MARC::Charset::EastAsian; 1;" );
	return( MARC::Charset::EastAsian->new() );
    } 
    
    elsif ( $code eq BASIC_CYRILLIC ) {
	eval( "use MARC::Charset::CyrillicBasic; 1;" );
	return( MARC::Charset::CyrillicBasic->new() );
    } 
    
    elsif ( $code eq EXTENDED_CYRILLIC ) { 
	eval( "use MARC::Charset::CyrillicExtended; 1;" );
	return( MARC::Charset::CyrillicExtended->new() );
    } 
    
    elsif ( $code eq BASIC_GREEK ) {
	eval( "use MARC::Charset::Greek; 1;" );
	return( MARC::Charset::Greek->new() );
    } 
    
    elsif ( $code eq BASIC_HEBREW ) {
	eval( "use MARC::Charset::Hebrew; 1;" );
	return( MARC::Charset::Hebrew->new() );
    } 
    
    else {
	_warning( sprintf("unknown charset hex(%x)",$code) );
	return(undef);
    }

}

## internal sub which will return a string describing the hex values
## at a particular position in a string for a given graphical character
## set. It takes into consideration the character size (8/24 bits) when 
## generating hex values. It is primarily used when generating warnings. 

sub _getHex {
    my ( $strRef, $g, $i ) = @_;
    my $hex = '';
    my $literal = '';
    for ( my $j=$i; $j < $i+$g->getCharSize(); $j++ ) {
	my $char = substr( $$strRef, $j, 1 );
	$literal .= $char;
	$hex .= _hexify( $char ) .  ' ';
    }
    chop($hex);
    return( "$literal ($hex)" );
}

sub _hexify {
    return sprintf( "0x%02X", ord( shift ) );
}

sub _hexifyU {
    return sprintf( "0x%04X", ord( shift ) );
}

1;

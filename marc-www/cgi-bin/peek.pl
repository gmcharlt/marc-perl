#!/usr/bin/perl

use strict;
use Socket;
use CGI;


open(IN,"access.log");

## results will be a hash of arrayrefs, so that the access times
## can be paired with a unique host name

my %results = ();
my %cache = ();
my ($requestor, $time, $hostName);

while (<IN>) {

	## reset 
	$hostName = undef;

	## read in a line of the log
	chomp();
	($requestor,$time) = split /: /;

	## Some might already be readable
	$hostName = $requestor if $requestor =~ /[a-z]/;

	## Try to use the cache if we've looked it up already
	$hostName = $cache{$requestor} if exists($cache{$requestor});

	## If not look it up
	if (!$hostName) {
		$hostName = gethostbyaddr(inet_aton($requestor), AF_INET);
		$cache{$requestor} = $hostName; ## store lookup in cache
	}

	## Store the hostname/time away in a hash of arrayrefs
	push (@{$results{$hostName}}, $time);

}

## Output HTML

my ($count, $color);
my $cgi = new CGI;

print
#	$cgi->header(),
	$cgi->start_html(
		-title => "Who's Been Using the MARC.pm Web Interface",
		-style => {-src => 'http://marcpm.sourceforge.net/style.css'}
		),
	$cgi->start_center(),
	$cgi->h1("Who's Been Using the MARC.pm Web Interface"),
	$cgi->hr(),
	$cgi->start_table(
		-border=>'0',
		-cellpadding=>'0',
		-cellspacing=>'0'
		),
	$cgi->th(["Host","Access Times"]);

foreach $hostName (sort(keys(%results))) {
	$count++;
	$color = "#ccccff";
	$color = "#cccccc" if $count&1;
	print 
		$cgi->Tr({-bgcolor=>$color}, [
		$cgi->td(
			{-valign=>'top'},
			[$hostName,join("<br>\n",@{$results{$hostName}})])
		]);
}

print 
	$cgi->end_table(),
	$cgi->hr(),
	$cgi->end_center(),
	$cgi->i(scalar localtime(time)),
	$cgi->end_html();


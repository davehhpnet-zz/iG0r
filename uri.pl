#!/usr/bin/env perl

use URI::Title;

my $url = $ARGV[0];

my $title = URI::Title::title($url);

print "\n\n$title\n\n";

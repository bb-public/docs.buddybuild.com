#!/usr/bin/perl

use strict;
use warnings;

use File::Spec::Functions;
use Getopt::Std;

our %options;
getopts('hvd:D:', \%options);

usage() if $options{h};

our $VERBOSE = $options{v} ? 1 : 0;
sub DEBUG {
  return unless $VERBOSE;
  print $_ for @_;
}

my $dir = $options{d} or usage("No scan directory provided!");
our $dicts = $options{D} or usage("No dictionary path provided!");

my $bbdict = catfile($dicts, 'buddybuild');
my $usdict = catfile($dicts, 'en_US');
our $hunspell_command = "hunspell -d $bbdict,$usdict -l";

print "Checking spelling in '$dir'...\n";
our @files = findadoc($dir);
DEBUG "File scanning complete.\n\n";
my $results = check_spelling(@files);

unless (scalar keys %$results) {
  print "No spelling errors found!\n";
  exit 0;
}

print "Spelling errors found!\n";
my $max = 0;
foreach my $key (keys %$results) {
  my $l = length $key;
  $max = $l if $l > $max;
}
my $indent = " " x $max;

foreach my $key (sort keys %$results) {
  my $label = sprintf "%". $max ."s", $key;
  my $result = $results->{$key};
  foreach my $path (sort keys $result) {
    printf "%s  %2dx %s\n", $label, $result->{$path}, $path;
    $label = $indent;
  }
}
exit 1;

sub findadoc {
  my $dir = shift;

  my @files;
  DEBUG "Scanning '$dir'...\n";
  opendir(my $dh, $dir)
    or die "Cannot open directory '$dir': $!\n";

  while (my $file = readdir $dh) {
    next if $file eq '.';
    next if $file eq '..';

    my $path = catfile($dir, $file);
    if (-d $path) {
      push @files, findadoc($path);
      next;
    }
    next unless $file =~ m/\.adoc$/;
    DEBUG "Found '$path'\n";
    push @files, $path;
  }

  closedir $dh;
  return @files;
}

sub check_spelling {
  my %results;
  foreach my $file (@_) {
    DEBUG "Checking spelling in '$file'...\n";
    my $command = $hunspell_command ." ". $file;
    my $output = `$command`;
    next unless length $output;
    foreach my $line (split m/\n/, $output) {
      DEBUG "Bad spelling '$line'\n";
      $results{$line} = {} unless exists $results{$line};
      $results{$line}->{$file} = 0 unless exists $results{$line}->{$file};
      $results{$line}->{$file}++;
    }
  }
  DEBUG "Done checking spelling.\n";
  return \%results;
}

sub usage {
  my $msg = shift;

  print "ERROR: $msg\n\n" if $msg;
  print <<USAGE;
Usage:
$0 [-hv] -d <directory to scan> -D <path to dictionaries>

Scans a directory for '*.adoc' files, runs the hunspell spellcheck tool
on each, and emits any spelling errors detected (exit code 1, if so).

Options:
 -h  This help text.
 -d  The directory to scan.
 -D  The path to the hunspell dictionaries.
 -v  Verbose output.
USAGE

  exit $msg ? 1 : 0;
}

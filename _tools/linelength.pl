#!/usr/bin/perl

use strict;
use warnings;

use File::Spec::Functions;
use Getopt::Std;

our %options;
getopts('hvd:l:', \%options);

usage() if $options{h};

our $VERBOSE = $options{v} ? 1 : 0;

sub DEBUG {
  return unless $VERBOSE;
  print $_ for @_;
}

my $dir = $options{d} or usage("No scan directory provided!");
my $length = $options{l} || 80;

print "Checking line lengths in '$dir'...\n";
our @files = findadoc($dir);
DEBUG "File scanning complete.\n\n";
my $results = check_length($length, @files);

unless (scalar keys %$results) {
  print "No files exceed line length of $length!\n";
  exit 0;
}

print "Line length violations found!\n";
foreach my $file (sort keys %$results) {
  print "In '$file':\n";
  foreach my $details (@{ $results->{$file} }) {
    printf "  Line %d: %d characters\n", $details->{line}, $details->{chars};
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

sub check_length {
  my $length = shift;

  my %results;
  foreach my $file (@_) {
    DEBUG "Checking line length in '$file'...\n";
    open my $fh, '<', $file
      or die "Couldn't open file '$file': $!\n";
    chomp(my @lines = <$fh>);
    close $fh;

    my $count = 0;
    my $in_source = 0;
    my $delimiter = '';

    foreach my $line (@lines) {
      $count++;
      DEBUG "Line $count: '$line'\n";

      # identify source blocks
      if ($line =~ m/\[source[^\]]*\]/) {
        $in_source = 1;
        next;
      }

      # process source blocks
      if ($in_source) {
        if ($line =~ m/^(-|=)+$/) {
          if (length $delimiter and $delimiter eq $1) {
            DEBUG "End delimiter for source block found.\n";
            $delimiter = '';
            next;
          }
          if ($delimiter eq '') {
            DEBUG "Source block start delimiter found.\n";
            $delimiter = $1;
            next;
          }
        }
        DEBUG "Skipping source content...\n";
        next;
      }

      # Skip titles, because they have to appear on one line
      if ($line =~ m/^=+ /) {
        DEBUG "Skipping title\n";
        next;
      }

      # skip links+images, as they often have long URLs that cannot split
      if ($line =~ m/(link|image):[^\[]+\[/) {
        DEBUG "Skipping a $1\n";
        next;
      }

      # skip URLs
      if ($line =~ m@(ht|f)tps?://@) {
        DEBUG "Skipping a URL\n";
        next;
      }

      if (length $line > $length) {
        DEBUG "Line length violation for '$line'\n";
        $results{$file} = [] unless exists $results{$file};
        push @{$results{$file}}, {
          line  => $count,
          chars => length $line,
        };
      }
    }
  }
  DEBUG "Done checking line lengths.\n";
  return \%results;
}

sub usage {
  my $msg = shift;

  print "ERROR: $msg\n\n" if $msg;
  print <<USAGE;
Usage:
$0 [-hv] -d <directory to scan> -l <maximum length>

Scans a directory for '*.adoc' files, checks the maximum line length
within each, and emits a report of which lines in which files are
too long.
on each, and emits any spelling errors detected (exit code 1, if so).

Options:
 -h  This help text.
 -d  The directory to scan.
 -l  The line length limit; lines longer than this are reported.
     Defaults to 80.
 -v  Verbose output.
USAGE

  exit $msg ? 1 : 0;
}

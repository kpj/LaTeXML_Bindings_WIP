use strict;
use warnings;
use Carp;
use Getopt::Long;
use Data::Dumper;
use YAML::Tiny;


sub load_profile {
  my ($file) = @_;
  print STDERR "(Loading '$file'... ";

  my $config;
  eval { $config = YAML::Tiny->read($file)->[0] }
    or croak("\nInvalid profile '$@'");
  
  print STDERR ")\n"; 
  return $config; }

sub merge_profiles {
  my ($cfg_main, $cfg_sub) = @_;
  
  for my $section (keys %$cfg_sub) {
    for my $key (keys %{$$cfg_sub{$section}}) {
      @{$$cfg_main{$section}{$key}}{keys %{$$cfg_sub{$section}{$key}}} = values %{$$cfg_sub{$section}{$key}}; } }

  return $cfg_main; }

sub get_file_extension {
  my ($file) = @_;
  my ($ext) = $file =~ /\.([^.]+)$/;
  return $ext; }

sub usage {
  die("Usage: $0 [stuff] <source>\n"); }

sub main {
  # load commandline parameters
  my $opts = {};
  GetOptions(
    "profile=s"     => \$$opts{profile},
    "destination=s" => \$$opts{destination}) or usage();

  # load source file
  if (scalar @ARGV != 1) {
    usage(); }
  my $source = $ARGV[0];
  
  # let the merging begin!
  our $cfg = load_profile("LaTeXML.ltxprofile");

  my $source_extension = get_file_extension($source);
  if ($source_extension eq 'tex' or $source_extension eq 'bib') {
    my $new_cfg = load_profile("$source_extension.ltxprofile");
    $cfg = merge_profiles($cfg, $new_cfg); }

  my ($key, $value);
  while (($key, $value) = each %$opts) {
    if (defined $value) {
      $$cfg{$key} = $value;
  } }

  print Dumper $cfg; }

main();

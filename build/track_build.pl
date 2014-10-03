#!/usr/bin/perl -w
use strict;
use warnings;

use XML::Simple;
use Data::Dumper;
use Switch;
use POSIX qw(strftime);

die "usage: $0 [--options] <required_file_1> <required_file_2...>\n
EpiTools Version Tracker v.0.1 build S001 (beta)

    => Please at least specify a file to track " unless @ARGV > 0;


# Collect arguments from cli creating a new hash
my $ARGV_HASH;
for(my $i=1; $i<=$#ARGV; $i=$i+2)
{
    $ARGV_HASH->{$ARGV[$i]} = $ARGV[$i+1];
}

# -----------------------------------------------------
# If this script has been called with an xml file path as first arg, then parse
# it and store its memory location (reference)
my $inputfile = XMLin($ARGV[0]);

#print $xmlfile->{programm_authors} . "\n";
# -----------------------------------------------------
# Update informations contained in release.xml according to the level of commit

if (exists($ARGV_HASH->{branch}))
{
    # initialization of variables
    my $version = 0;
    my $date_version = 'na';
    my $release = 0;
    my $date_release= 'na';
    
    # check if xml file contains the following values
    if (exists($inputfile->{version})){ $version = $inputfile->{version};}
    if (exists($inputfile->{release})){ $release = $inputfile->{release};}
    if (exists($inputfile->{date_version})){ $date_version = $inputfile->{date_version};}
    if (exists($inputfile->{date_release})){ $date_release = $inputfile->{date_release};}   


    switch($ARGV_HASH->{branch})
    {
        # in case the branch where commit has happened is exactly "master"
        case "master"
        {
            
            # Default values are taken from release.xml file. In case of build
            # triggered by commit and no value is assigned to $ARGV_HASH->{version}
            # since JIRA did not pass the value, then maintain the current version
            # and increase release value of 1.
            
            # if this build is triggered only by a commit into master branch,
            # then increase release value
            
            $release = $inputfile->{release} + 1;
            $date_release = strftime "%a %d %b %Y %H:%M:%S (UTC %z)", localtime;
            
            # JIRA VERSION RELEASE TRIGGER
            # Non default values are taken from ARGV_HASH
            if (exists($ARGV_HASH->{version}))
            {
                $version = $ARGV_HASH->{version};
                $release = 0;
                $date_version = strftime "%a %d %b %Y %H:%M:%S (UTC %z)", localtime;

            }
            

        }

        # in case the branch where commit has happened is exactly "development"
        case "develop"
        {            
            # if this build is triggered only by a commit into development branch,
            # then increase release value of 0.1 each time
            
            $release = $inputfile->{release} + 0.1;
            $date_release = strftime "%a %d %b %Y %H:%M:%S (UTC %z)", localtime;
            
        }
        
        # in case the branch where commit has happened contains the word "release"
        #case /release/i
        #{
        #}
        
        # when none of the previous cases are satisfied
        else
        {
            print "WARN: Branch name is not recognised";
        }

    }
    
    $inputfile->{release} = $release;
    $inputfile->{date_release} = $date_release;

    $inputfile->{version} = $version;
    $inputfile->{date_version} = $date_version;
}


# Change BUILD values

my $build = '';
my $date_build = '';

if (exists($inputfile->{build})){ $build = $inputfile->{build};}
if (exists($inputfile->{date_version})){ $date_build = $inputfile->{date_build};}

my $head_build = strftime "%b", localtime;
my $head_build_date = strftime "%a %d %b %Y %H:%M:%S (UTC %z)", localtime;
$build =  $head_build .'-0'. $ARGV_HASH->{build_uid};
$date_build = $head_build_date .' with build key ' . $ARGV_HASH->{build_key};

$inputfile->{build} = $build;
$inputfile->{date_build} = $date_build;


# ------------------------------------------------------
# Write the xml file containing the updated informations

# Remove the old release.xml file from file system
#unlink $ARGV[0];

## Open output file
open(my $fh, '>', $ARGV[0]) or die "Could not open file '$ARGV[0]' $!";


print $fh '<?xml version="1.0" encoding="utf-8"?>'."\n";
print $fh "<main>\n";
foreach my $key (sort(keys %{$inputfile}))
{
    print $fh "\t<$key>$inputfile->{$key}</$key>\n";
}
print $fh "</main>\n";
exit;

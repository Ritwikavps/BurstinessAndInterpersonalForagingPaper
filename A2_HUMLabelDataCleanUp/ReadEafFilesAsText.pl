#!usr/local/bin/perl
#
#Ritwika VPS
#Nov 2021
#UCLA, Dpmt of Comm

#Script to extract time series data and human labels from 5 minute human labelled segments

use strict;
use warnings;

# This tool allows you to read .eaf files and read it into a txt file that MATLAB can read (I have an alternative in-perl way of doing whatever MATLAB does, except
#I keep getting an error because of variable scopes, and because of time, I am using this quick fix)

# Takes 2 command line arguments:
# 1: The (path and) file name of the input file. (e.g. "e20070225_191245_003110.eaf")
# 2: The (path and) file name of the the line-by-line txt file. (e.g. "e20070225_191245_003110EAF.txt")

# Instructions:
# 1.) Open up a unix shell (e.g., the Terminal application under Utilities on Mac or Cygwin on Windows)
# 2.) Navigate to the directory where "ReadEafFilesAsText.pl" is located (e.g. ~/Desktop/lena-its-tools/)
# 3.) Run ReadEafFilesAsText.pl with the (path and) file name of the input eaf file as the first argument, 
      #the (path and) file name of the output file as the second argument;
      #(e.g. perl ReadEafFilesAsText.pl e20070225_191245_003110.eaf e20070225_191245_003110EAF.txt)

#Open input and output files
open INPUTFILE, $ARGV[0] or die "Could not open input file " . $ARGV[0] . "\n";
open EAFTXTFILE, ">", $ARGV[1] or die "Could not open eaf txt output file" . $ARGV[1] . "\n";

#Go through line by line;
while (my $line = <INPUTFILE>){

	chomp($line);
	my $newline = $line;
	print EAFTXTFILE "$newline\n";

		
}

close(INPUTFILE);
close(EAFTXTFILE);



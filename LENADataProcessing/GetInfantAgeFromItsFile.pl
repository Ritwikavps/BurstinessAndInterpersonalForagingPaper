#!/usr/local/bin/perl
#
#Ritwika VPS, Feb 2021
#Script to parse .its files to get infant age
#The its files have both infant DOB and the date (and time) of recording. We can use this info to compute infant age in days (with some potential error -- +/- 1 day -- because we are 
#not accounting for the exact time of the infant's birth etc)

use strict; use warnings; #standard pragma: to restrict unsafe constructs and to display all warnings, respectively 

#the first argument of the function (script?) is the input file while the second argument is the output file. The ">" modifier is to specify that the 
#outfile will be written into (there are other modifiers for reading from a file and appending to a file). \n is for newline

open INPUTFILE, $ARGV[0] or die "Could not open input file " . $ARGV[0] . "\n"; 
open OUTPUTFILE, ">", $ARGV[1] or die "Could not open output file " . $ARGV[1] . "\n";

#Because this is literally my first Perl script, I am simply going to set this up so that it reads the DOB of infant and the recording date into a text file.
#My plan is to then write a bash script to run this on a folder of .its files, and then combine all the info with MATLAB
#This is obvioulsy not the best way to do this and a more experienced programmer may choose to write all the DOBs from all the .its files in a folder into a single text file
#But I, as of now, have no clue how to do that

#Go through input file line by line (the current variable is $line, 'my' specifies that this is a local variable; the while loop is going to go through the file in <>

while (my $line = <INPUTFILE>){
	
	#removes newline (\n) character at the end of the line
	chomp($line);

	#Check if the current line contains the string ChildInfo dob=
	#The binding operator =~ followed by the matching check m// checks if the string on the left contains the string on the right (inside //)
	if ($line=~ m/ChildInfo dob=/){
	
		#if yes
	
		#define new string (variable?) dob. We will remove unwanted bits from this later
		my $dob = $line;
		$dob =~ s/.*ChildInfo dob="//g;
		
		#The s///g searches (s) the $dob string (variable) for the regexp text between // and replaces (g) with whatever is between // preceding g
		#In this case, .*ChildInfo dob =" is replaced by blank
		#now, remove everything following the dob value (after ") as well
		$dob =~ s/".*//g;

		$dob = "DOB is" . $dob; #add text identifying DOB

		print OUTPUTFILE "$dob\n"; #write dob into file w newline at end
		#TIL that because $dob etc are local variables, they don't (?) exist outside of the for/while loop?

		last; #end once found
	}
}

#To find recording data, do this again (not the best way to do this, but I am a beginner and my focus is on getting it done rather than doing it extremely elegantly
while (my $line = <INPUTFILE>){

        #removes newline (\n) character at the end of the line
        chomp($line);

        #Check if the current line contains the string Recording num=
	#The first such instance will contain the recording date (a number of later lines will also have the recording data but we will terminate as soon
	#as we find the first one 
        if ($line=~ m/Recording num=/){

                #if yes

		my $recordingdate = $line;
		$recordingdate =~ s/.*Recording num="//g;

		#also remove the bit that says startClockTime="
		$recordingdate =~ s/.*startClockTime="//g;

		#Also remove anything after T as well
		$recordingdate =~ s/T.*//g;

		$recordingdate = "Recording date is" . $recordingdate;

		print OUTPUTFILE "$recordingdate\n";
		
		last; 
	}
}

close(INPUTFILE);
close(OUTPUTFILE);

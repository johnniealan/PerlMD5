=begin
# Copyright (C) 2016 Johnnie J. Alan

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
=cut

use strict;
use warnings;

# Packages for this tool
use Digest::MD5;
use Archive::Tar;
use Getopt::Std;
 
# local functions
sub option_mgmt();
sub calcMd5();
sub pringErr($);

# Global variable
our %options=();
our $tarName = ();
our $output = ();
our $tarNameProvided =0;
our $usage = "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++".
             "\nSimple tool to create checksum for files present in Tar archive.".
             "\nThis tool does not extract files to HDD, it uses local memory".
	     "\nThe output will be stored in ouput file.".
             "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++".
             "\n\nusage:perl tarchecksum -f <tar file name> -o <output file>".
             "\nDefault:output file is <tar file name>.txt".
             "\nNOTE:his tool supports only MD5 for now.".
             "\nCopyright (C) 2016 Johnnie J. Alan (johnniealan\@gmail.com)\n\n";

getopts("hf:o:", \%options);

# Getting the command line option
option_mgmt();

if ( $tarNameProvided == 0 ) 
{
   print "**** ERROR : Mandatory parameter missing, tar file name ***** \n\n";
   print $usage;
   exit(0);
}
# Calculating MD5 checksum
calcMd5();

=begin
# Function to manage input parameters
=cut
sub option_mgmt()
{
    if ( $options{h} )
    {
       print $usage;
       exit(0);
    }
    elsif ( $options{f} )
    {
       $tarName = $options{f};
       $tarNameProvided = 1;
    }
   
    if ( $options{o})
    {
       $output = $options{o};
    }
    else
    {
       if ( $tarNameProvided )
       {
          $output = $tarName.".txt";
       }
    }
}

=begin
# Function opens tar bar and reads the list of files
# The file content is read and fed to Digest packages for creating checksum
=cut
sub calcMd5()
{
   open outputHdl, "+> $output" or die "cannot open < $output: $!";

   my $tarListIter = Archive::Tar->iter( $tarName, 1 ); 
   while( my $file = $tarListIter->() ) 
   { 
      my $file_name = $file->name; 
      
      # ignoring checksum for directory, soft/harlink, char/block dev, fifo,
      # socket, label, longlink. 
      # add the file types if you need checksum
      # my $validFileType = $file->is_file() | $file->is_unknown() | $file->is_symlink;

      my $validFileType = $file->is_file() | $file->is_unknown();
      if ( $validFileType ) 
      {
         print outputHdl Digest::MD5->new->add($file->data)->hexdigest, "  $file_name\n";
      }
   }
   close outputHdl
}

#!/usr/bin/perl
# find all .txt files in a directory
# verify ansible-playbook created per host .txt file of command output

# name: copy output to file
#       copy:
#         content: "{{ output.stdout[0] }}
#         dest: "output-{{ inventory_hostname }}.txt"

# find text files in a directory
 $dirname = '/home/netadmin/awk/parse_out/';			# directory to search
 opendir(DIR, $dirname) or die "could not open $dirname\n";	# open directory
 @textfile = grep(/\.txt$/,readdir(DIR));			# only .txt files
 foreach $textfile(@textfile)					# for each file in directory
 {
	  print "$textfile\n";
 }


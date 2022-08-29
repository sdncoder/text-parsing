#!/usr/bin/perl
#
# Parse output from IOS-XR Ansible playbooks.
# iosxr_command tasks:
#
#sh run | hostname
#sh version | i Software
#sh ip int brief
#
# files from playbook in parse_out folder one per host
# output created 
=pod
file: sh_ver-100.125.252.240.txt
----------------------------------------------
hostname chi-srcore-B-pr01
MgmtEth0/RP0/CPU0/0            100.125.252.240 Up              Up       management
Cisco IOS XR Software Version 7.5.1
=cut

#find files in a directory
$dirname = '/home/netadmin/awk/parse_out/';			# directory to search
opendir(DIR, $dirname) or die "could not open $dirname\n";	# open directory
@textfile = grep(/\.txt$/,readdir(DIR));
foreach $textfile(@textfile)
 {
	print "file: $textfile\n";
 	print "----------------------------------------------";
	my $filename = "/home/netadmin/awk/parse_out/$textfile";
 	my $encoding = ":encoding(UTF-8)";
 	my $handle = undef;

 	open($handle, "< $encoding", $filename) || die "$0: cannot open $filename $!";
 	$line = <$handle>;
	 	$line =~ s/,/\n/g;
	$line =~ s/]//g;
	$line =~ s/,//g;
	$line =~ s/\[//g;
	$line =~ s/~.+//g;
	$line =~ s/u//g;
	$line =~ s/Bu.+//g;

	print "$line"; 
 }

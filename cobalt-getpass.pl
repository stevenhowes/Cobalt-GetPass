#!/usr/bin/perl

# Retrieves usernames/passwords of all users on Cobalt, and older BlueQuartz servers.
# Will not work on newer BlueQuartz/BlueOnyx boxes. Sorry.

# Created by Steve Howes. Free to use and distribute. No warranty. If it breaks,
# you get what you pay for - sorry ;)

# Thanks to Rickard Osser for bugfix

use strict;
use warnings;

sub decode_pw
{
	my $plain = shift;
	my $crypt;

	foreach ( unpack('C*', $plain) )
	{
		$crypt .= pack('C*', $_ ^= hex('ff'));
	}

	return $crypt;
}


opendir(DIR, "/usr/sausalito/codb/objects");
my @FILES=readdir(DIR);
my @FILESSORT = sort { $a cmp $b }  @FILES;
my $i=0;
foreach(@FILESSORT)
{
	if(substr($FILES[$i],0,1) ne ".")
	{
		my $class = "";
		my $name = "";
		my $pw = "";
		my $classfile = "/usr/sausalito/codb/objects/" . $FILES[$i] . "/.CLASS";
		open(DAT, $classfile) || die("Could not open .CLASS file: " . $classfile);
		$class=<DAT>;
		close(DAT);
		if($class eq "User")
		{
			my $namefile = "/usr/sausalito/codb/objects/" . $FILES[$i] . "/.name";
			open(DAT, $namefile) || die("Could not open .name file: " . $namefile);
			$name=<DAT>;
			close(DAT);

			my $pwfile = "/usr/sausalito/codb/objects/" . $FILES[$i] . "/APOP.apop_password";

			if ( -e $pwfile)
			{
				open(DAT, $pwfile) || die("Could not open APOP.apop_password file: " . $pwfile);
				$pw=decode_pw(<DAT>);
				close(DAT);
			}
			print($name . " " . $pw . "\n");
		}
	}
	$i++;
}


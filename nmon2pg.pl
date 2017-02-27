#!/usr/bin/perl
# Program name: nmon2pg.pl
# Inject un fichier NMON dans une base Postgreas
# Base Postrges initialise par scrip init_nmon_db_pg.sql
# Author - Peponas Thomas

$nmon2pg_ver="0.2 Jan 2017";

use POSIX;
use Date::Manip;
use Switch;
use warnings;
use strict;
use feature "switch";
use DBI;
use Getopt::Long;

# Autoflush STDOUT
$| = 1;



####################################################################
#############		Main Program 			############
####################################################################



my $dbhost="127.0.0.1";             # server name
my $nmon_file;
my $skip_regexp;
my $only_regexp;
my $debug=0;
my $help=0;
my $n;
my $i;

# Get options
GetOptions(
    "dbhost=s"  => \$dbhost,
    "skip=s"	=> \$skip_regexp,
    "only=s"	=> \$only_regexp,
    "help"              => \$help,
    "debug"             => \$debug,
    ) || die("There is invalid option.  Use --help or --man.\n");

my $driver   = "Pg"; 
my $database = "nmon";
my $dsn = "DBI:$driver:dbname=$database;host=$dbhost;port=5432";
my $userid = "postgres";
my $password = "postgres";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 })
                      or die $DBI::errstr;

my $aix_version;

	# On parse le fichier Ligne par Ligne 

foreach $nmon_file (@ARGV) {
	print "\nimport: ".$nmon_file;
	my %label;
	my %class;
	my %pid;
	my $serial="";
	my $hostname="";
	my $line;
	my %ZZZZ;
	my %copydata;
	my $values;
	
	$aix_version="unknow";
	open(NMON,$nmon_file) or die ("Pas de fichier nmon en entrée");
	foreach $line (<NMON>) {
		if ($aix_version =~ /5\.3/) { next; }
		chomp($line);
		my @cols=split(/,/,$line);
		if ($skip_regexp && $cols[0] =~ /$skip_regexp/) {
			if ($debug)  {print "Skip ".$cols[0]."\n"; }
			next;
		}
		if ($only_regexp &&  ! $cols[0] =~ /$only_regexp/) {
			next;
		}
		
		if ($debug) { print "$line \n" }
		switch ($cols[0]) { 
			case( "AAA") { 
				if ($cols[1] =~ /AIX/) {
					$aix_version=$cols[2];
					if ($aix_version =~ /5\.3/) { 
						print "Version 5.3 not support\n";
						next;
					}
				}
				if ($cols[1] =~ /SerialNumber/) { $serial=$cols[2]; }
				if ($cols[1] =~ /host/) 	{ $hostname=lc($cols[2]); }
			}
			case (/^DISKBUSY|^DISKREAD|^DISKREADSERV|^DISKRIO|^DISKRXFER|^DISKSERV|^DISKWAIT|^DISKWIO|^DISKWRITE|^DISKWRITESERV|^DISKXFER|^DISKAVGRIO|^DISKAVGWIO|^DISKBSIZE|^VG.+/) {
				if ( $cols[1] =~ /^T[0-9]+/) {
					# insert values
                                        $n=@{$label{$cols[0]}};
                                        for($i=0;$i<$n;$i++){
						push(@{$copydata{$cols[0]}},"$serial,$hostname,$ZZZZ{$cols[1]},$label{$cols[0]}[$i],$cols[$i+2]");
	                                   #     print "Insert into ".$cols[0]." values (".$serial.",".$hostname.",to_timestamp(".$ZZZZ{$cols[1]}."),".$label{$cols[0]}[$i].",".$cols[$i+2].");\n";
					}
				} else {
					# initialise tableau id 
					$n=@cols;
					$label{$cols[0]}=[];
					for($i=2;$i<$n;$i++){
						push(@{$label{$cols[0]}},$cols[$i]);
					}
				}

			} 
case (/FILE/) {} 
case (/IOADAPT/) {} 
case (/JFSFILE/) {} 
case (/JFSINODE/) {} 
			case(/^LPAR|^CPU_ALL|^MEM|^MEMNEW|^MEMUSE/) {
				$n=@cols;
				if ( $cols[1] =~ /^T[0-9]+/) {
					$values=join(",",@cols[2..$n-1]);
#	                                print "Insert into ".$cols[0]." values (".$serial.",".$hostname.",to_timestamp(".$ZZZZ{$cols[1]}."),".$values.");\n";
					push(@{$copydata{$cols[0]}},"$serial,$hostname,$ZZZZ{$cols[1]},$values");
					#my $stmt = qq(Insert into $cols[0] values ($serial,$hostname,to_timestamp($ZZZZ{$cols[1]}),$values));
					#my $rv = $dbh->do($stmt) or die $DBI::errstr;
				} else  {
					$copydata{$cols[0]}=[];
				}
			} 
#case (/NET|NETERROR|NETPACKET|NETSIZE/) {} 
#case /PAGE/| {} 
#case /PAGING/ {} 
#case /POOLS/ {} 
			case(/^TOP/) {
				$n=@cols;
				if ( $cols[2] && $cols[2] =~ /^T[0-9]+/) {
					$values=join(",",@cols[3..$n-1]);
					push(@{$copydata{$cols[0]}},"$serial,$hostname,$ZZZZ{$cols[2]},$cols[1],$values");
				}
			} 
			case /^UARG/ {
				my $command="";
				$n=@cols;
                                if ( $cols[1] =~ /^T[0-9]+/) {
					if ($line =~ /THCNT/) { next; }
					$cols[3] =~ s/-/0/g;
					$cols[5] =~ s/\ /0/g;
					$command=join(",",@cols[8..$n-1]);
					#print $cols[$n-1]."\n";
                                        $values=join(",",@cols[2..7]);
#                                       print "Insert into ".$cols[0]." values (".$serial.",".$hostname.",to_timestamp(".$ZZZZ{$cols[1]}."),".$values.",".$command.");\n";
                                        push(@{$copydata{$cols[0]}},"$serial,$hostname,$ZZZZ{$cols[1]},$values");
                                        #my $stmt = qq(Insert into $cols[0] values ($serial,$hostname,to_timestamp($ZZZZ{$cols[1]}),$values));
                                        #my $rv = $dbh->do($stmt) or die $DBI::errstr;
                                } else  {
                                        $copydata{$cols[0]}=[];
                                }
			} 
			case(/^WLMMEM|^WLMCPU|^WLMBIO/) {
				if ( $cols[1] =~ /^T[0-9]+/) {
                                        # insert values		
					$n=@{$class{$cols[0]}};
                                        for($i=0;$i<$n;$i++){
						push(@{$copydata{$cols[0]}},"$serial,$hostname,$ZZZZ{$cols[1]},$class{$cols[0]}[$i],$cols[$i+2]");
#					my $stmt = qq(Insert into $cols[0] values ($serial,$hostname,to_timestamp($ZZZZ{$cols[1]}),$class{$cols[0]}[$i],$cols[$i+2]));
#					my $rv = $dbh->do($stmt) or die $DBI::errstr;
		#			print "Insert into ".$cols[0]." values (".$serial.",".$hostname.",to_timestamp(".$ZZZZ{$cols[1]}."),".$class{$cols[0]}[$i].",".$cols[$i+2].");\n";
					}
                                } else {
					$copydata{$cols[0]}=[];
                                        # initialise tableau id
                                        $n=@cols;
                                        $class{$cols[0]}=[];
                                        for($i=2;$i<$n;$i++){
                                                push(@{$class{$cols[0]}},$cols[$i]);
                                        }
                                }
			} 
			case(/^ZZZZ/) { 
		#		$ZZZZ{$cols[1]}=UnixDate($cols[3]." ".$cols[2],'%s');
				my @hhmmss=split(':',$cols[2]);
				$hhmmss[2]=floor($hhmmss[2]/30)*30;
				$cols[2]=join(':',@hhmmss);
				$ZZZZ{$cols[1]}=$cols[3]." ".$cols[2];
				
			}
		}
	}
	close (NMON);
	
	if ($aix_version =~ /5\.3/) { next; }

	foreach my $key (keys %copydata) {
	if ($debug) {
		print "Parsing $key\n";
	} else {
		print ".";
	}
        $dbh->do("COPY $key FROM STDIN WITH DELIMITER ','");
        foreach my $row (@{$copydata{$key}}) {
		if ($key =~ /UARG/ && $row =~ /topas_nmon/) {
			print $row."\n";
			next;
		}
                $row =~ s/,,/,0,/g;
                $dbh->pg_putcopydata($row."\n");
        }
        $dbh->pg_putcopyend();
}
} 

	
$dbh->disconnect();
	
exit(0);


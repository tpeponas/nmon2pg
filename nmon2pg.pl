#!/usr/bin/perl
# Program name: nmon2pg.pl
# Inject un fichier NMON dans une base Postgreas
# Base Postrges initialise par scrip init_nmon_db_pg.sql
# Author - Peponas Thomas

$nmon2pg_ver="0.2 Jan 2017";

use POSIX;
use Switch;
use warnings;
use strict;
use feature "switch";
use DBI;
use Getopt::Long;
use Net::OpenSSH;
use Config::IniFiles;

# Autoflush STDOUT
$| = 1;

# Parameter

my $dbhost="127.0.0.1";             # server name
my $dbuserid = "nmon";
my $dbpassword = "nmon";
my $dbname="nmon";
my $ssh_host;
my $ssh_username=undef;
my $ssh_password=undef;
my $ssh_hosts_list=undef;
my $ssh_filename=undef;
my $nmon_file;
my $skip_regexp;
my $only_regexp;
my $debug=0;
my $help=0;
my $round_time=0;
my $n;
my $i;
my $id;
my $NMON;
my $cfg;

# Get options
GetOptions(
    "dbhost=s"  => \$dbhost,
    "dbusername=s"  => \$dbuserid,
    "dbpassword=s" => \$dbpassword,
    "dbname=s" => \$dbname,
    "ssh_username=s" => \$ssh_username,
    "ssh_password=s" => \$ssh_password,
    "skip=s"	=> \$skip_regexp,
    "round_time" 	=> \$round_time,
    "help"              => \$help,
    "debug"             => \$debug,
    ) || die("There is invalid option.  Use --help or --man.\n");



if ($help) {
    print_help();
    exit(0);

}


my $driver   = "Pg"; 
my $dsn = "DBI:$driver:dbname=$dbname;host=$dbhost;port=5432";
my $dbh = DBI->connect($dsn, $dbuserid, $dbpassword, { RaiseError => 0 })
                      or die $DBI::errstr;

my $aix_version;


sub print_help {
    print "Nmon2pg.pl : Perl Script to import Nmon file to a postgres Database \n";
    print "Options: \n";
    print "--ssh_username : username to get remote nmon file\n";
    print "--ssh_password : password for ssh_username to get remote nmon file\n";
    print "--hosts_list : Hosts list on which to get nmon file\n";
    print "--ssh_filename : patterne for nmon file to get on host_list \n";
    print "--dbhost : Databse postgresql server (default localhost ) \n";
    print "--dbuserid : Database postgresql username (default nmon) \n";
    print "--dbpassword : Database postgresql password (default nmon) \n";
    print "--dbname : Databse postgresql name (defautl nmon) \n";
    print "--skip_regexp : Dot not import skip pattern of nmon file (exemple : DISK.*|NET.*)\n";
}

sub init_var {
    $cfg=Config::IniFiles->new( -file => "$ENV{'HOME'}/.nmon2pg.ini");

    if (!$ssh_username) { $ssh_username=$cfg->val( 'SSH', 'username' ); }
    if (!$ssh_password) { $ssh_password=$cfg->val( 'SSH', 'password' ); }
    if (!$ssh_hosts_list) { $ssh_hosts_list=$cfg->val( 'SSH', 'hosts' ); }
    if (!$ssh_filename) { $ssh_filename=$cfg->val( 'SSH', 'filename' ); }
    
    if (!$dbhost) { $dbhost=$cfg->val( 'DB','host'); }
    if (!$dbuserid) { $dbuserid=$cfg->val( 'DB','username'); }
    if (!$dbpassword) { $dbpassword=$cfg->val( 'DB','password'); }
    if (!$dbname) { $dbname=$cfg->val( 'DB','name'); }
    if (!$skip_regexp) { $skip_regexp=$cfg->val( 'MAIN','skip'); }
    
}

####################################################################
#############           Main Program                    ############
####################################################################   

    
init_var();


foreach $nmon_file (@ARGV) {
	print "\nimport: ".$nmon_file." ";
	my %label;
	my %class;
	my %pid;
	my $serial="";
	my $hostname="";
	my $line;
	my %ZZZZ;
	my %copydata;
	my $values;
	my @interfaces;
	my @ioadapt;
	my $ssh_file;
	my $pid;
	my $ssh_sess;

	# On Controle si acces vers SHH ou fichier local 
	#
	#

	$aix_version="unknow";
	if ( $nmon_file =~ /^.*:\/.*/) {
			if ($ssh_username && $ssh_password) {
				$ssh_host=$nmon_file;
				$ssh_host =~ s/:\/.*$//g;
				$ssh_sess = Net::OpenSSH->new( $ssh_host, user => $ssh_username , password => $ssh_password  );
				$ssh_file=$nmon_file;
				$ssh_file =~ s/^.*://g;
				($NMON,$pid) = $ssh_sess->pipe_out("cat ".$ssh_file);
			} else {
			       	die "Must provide ssh username and password\n";
			}
	} else {
		open($NMON,$nmon_file) or die ("Pas de fichier nmon en entrée");
	}
	foreach $line (<$NMON>) {
		if ($aix_version =~ /5\.3/) { next; }
		chomp($line);
		my @cols=split(/,/,$line);
		if ($skip_regexp && $cols[0] =~ /$skip_regexp/) {
			if ($debug)  {print "Skip ".$cols[0]."\n"; }
			next;
		}
		
	#	if ($debug) { print "$line \n" }
		switch ($cols[0]) { 
			case( "AAA") { 
				if ($cols[1] =~ /AIX/) {
					$aix_version=$cols[2];
					if ($aix_version =~ /5\.3/) { 
						print "Version 5.3 not supportied\n";
						next;
					}
				}
				if ($cols[1] =~ /SerialNumber/) { $serial=$cols[2]; }
				if ($cols[1] =~ /host/) 	{ $hostname=lc($cols[2]); $hostname =~ s/-/_/g; }
			}
			case (/^DISK.+|^VG.+|PAGING/) {
				if ( $cols[1] =~ /^T[0-9]+/) {
					# insert values
                                        $n=@{$label{$cols[0]}};
                                        for($i=0;$i<$n;$i++){
						push(@{$copydata{$cols[0]}},"$serial;$hostname;$ZZZZ{$cols[1]};$label{$cols[0]}[$i];$cols[$i+2]");
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
			case (/IOADAPT/) {
				if ( $cols[1] =~ /^T[0-9]+/) {
                                        $n=@ioadapt;
                                        for($i=0;$i<$n;$i++) {
                                                push(@{$copydata{$cols[0]}},"$serial;$hostname;$ZZZZ{$cols[1]};$ioadapt[$i];$cols[$i*3+2];$cols[$i*3+3];$cols[$i*3+4]");
                                        }
                                } else  {
                                        $n=@cols;
                                        # Inititalisation des nom des adapters
                                        for($i=2;$i<$n;$i=$i+3) {
                                                $cols[$i] =~ s/_read.*//;
						$cols[$i] =~ s/\ /_/g;
                                                push(@ioadapt,$cols[$i]);
                                        }
                                }
			} 
case (/JFSFILE/) {} 
case (/JFSINODE/) {} 
			case(/^LPAR|^CPU_ALL|^MEM|^MEMNEW|^MEMUSE|^PAGE|^FILE|^PROC/) {
				$n=@cols;
				if ( $cols[1] =~ /^T[0-9]+/) {
					$values=join(";",@cols[2..$n-1]);
					push(@{$copydata{$cols[0]}},"$serial;$hostname;$ZZZZ{$cols[1]};$values");
				} else  {
					$copydata{$cols[0]}=[];
				}
			} 
			case(/^PCPU[0-9]+|^SCPU[0-9]+/) {
				$n=@cols;
				$id=$cols[0];
				$id=~ s/[SP]CPU//;
				$cols[0]=~ s/[0-9]+//;
				if ( $cols[1] =~ /^T[0-9]+/) {
					$values=join(";",@cols[2..$n-1]);
					push(@{$copydata{$cols[0]}},"$serial;$hostname;$ZZZZ{$cols[1]};$id;$values");
				} else {
					$copydata{$cols[0]}=[];
				}
			}
			case ("NET") {
				if ( $cols[1] =~ /^T[0-9]+/) {
					$n=@interfaces;
					for($i=0;$i<$n;$i++) {
						push(@{$copydata{$cols[0]}},"$serial;$hostname;$ZZZZ{$cols[1]};$interfaces[$i];$cols[$i+2];$cols[$i+$n+2]");
					}
                                } else  {
					$n=@cols;
					# Inititalisation des nom interface
					for($i=2;$i<($n-2)/2+2;$i++) {
						$cols[$i] =~ s/-read.*//;
						push(@interfaces,$cols[$i]);
					}
                                }

			} 
			case (/NETSIZE|NETPACKET/) {
				if ( $cols[1] =~ /^T[0-9]+/) {
					$n=@interfaces;
                                        for($i=0;$i<$n;$i++) {
                                                push(@{$copydata{$cols[0]}},"$serial;$hostname;$ZZZZ{$cols[1]};$interfaces[$i];$cols[$i+2];$cols[$i+$n+2]");
                                        }
                                }
			} 
			case ("NETERROR") {	
				if ( $cols[1] =~ /^T[0-9]+/) {
					$n=@interfaces;
                                        for($i=0;$i<$n;$i++) {
                                                push(@{$copydata{$cols[0]}},"$serial;$hostname;$ZZZZ{$cols[1]};$interfaces[$i];$cols[$i+2];$cols[$i+$n+2];$cols[$i+(2*$n)+2]");
					}
				}
			} 
#case /POOLS/ {} 
			case(/^TOP/) {
				$n=@cols;
				if ( $cols[2] && $cols[2] =~ /^T[0-9]+/) {
					$values=join(";",@cols[3..$n-1]);
					push(@{$copydata{$cols[0]}},"$serial;$hostname;$ZZZZ{$cols[2]};$cols[1];$values");
				}
			} 
			case /^UARG/ {
				my $command="";
				$n=@cols;
                                if ( $cols[1] =~ /^T[0-9]+/) {
					if ($line =~ /THCNT/) { next; }
					$cols[3] =~ s/-/0/g;
					$cols[5] =~ s/\ /0/g;
					$command=substr(join(",",@cols[8..$n-1]),0,256);
					$command =~ s/;/\\;/g;
                                        $values=join(";",@cols[2..7]);
                                        push(@{$copydata{$cols[0]}},"$serial;$hostname;$ZZZZ{$cols[1]};$values;$command");
                                } else  {
                                        $copydata{$cols[0]}=[];
                                }
			} 
			case(/^WLMMEM|^WLMCPU|^WLMBIO/) {
				if ( $cols[1] =~ /^T[0-9]+/) {
                                        # insert values		
					$n=@{$class{$cols[0]}};
                                        for($i=0;$i<$n;$i++){
						push(@{$copydata{$cols[0]}},"$serial;$hostname;$ZZZZ{$cols[1]};$class{$cols[0]}[$i];$cols[$i+2]");
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
				if ($round_time) {
					$hhmmss[2]=floor($hhmmss[2]/30)*30;
					$cols[2]=join(':',@hhmmss);
				}
				$ZZZZ{$cols[1]}=$cols[3]." ".$cols[2];
				
			}
		}
	}
	close ($NMON);
	
	if ($aix_version =~ /5\.3/) { next; }

	foreach my $key (keys %copydata) {
		print ".";
        $dbh->do("COPY $key FROM STDIN WITH DELIMITER ';'");

        foreach my $row (@{$copydata{$key}}) {
		if ($key =~ /UARG/ && $row =~ /topas_nmon/) {
			next;
		}
                $row =~ s/;;/;0;/g;
		if ($debug) {
			print("$key :$row\n");
		}
                $dbh->pg_putcopydata($row."\n");
        }
        $dbh->pg_putcopyend();
}


} # Fin boulce fichier



$dbh->disconnect();
	
exit(0);


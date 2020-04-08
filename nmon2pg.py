#!/usr/bin/env python3

# TPEP import AIX nmon file to postrges database

import paramiko
import io
import argparse
import re
import psycopg2
import configparser


class NMON_Import:

    def __init__(self,skip,pg_dbhost="10.193.128.234",pg_dbname="nmon",pg_dbuser="nmon",pg_dbpass="nmon"):
        self.skip=skip
        self.lines_pattern=['^AAA','^DISK.+|^VG.+|^PAGING|^WLM|^NET','^LPAR|^CPU_ALL|^MEM|^MEMNEW|^MEMUSE|^PAGE|^FILE|^PROC|^SUMMARY','^TOP','^ZZZZ','^UARG','^PROCAIO']
        self.lines_proc=[self.proc_info,self.proc_label_value,self.proc_metrics,self.proc_top,self.proc_zzzz,self.proc_uarg,self.proc_skip]
        self.host=""
        self.serial=""
        self.debug=0
        self.copydata=dict()
        self.zzzz=dict()
        self.labels=dict()
        self.version=0;

        try:
            self.db_conn=psycopg2.connect(host=pg_dbhost,dbname=pg_dbname,user=pg_dbuser,password=pg_dbpass)
        except:
            print("Unable to connect to Postgres host:"+pg_dbhost+" dbname: "+pg_dbname+" Username: "+pg_dbuser+" Password: "+pg_dbpass)
        

    def proc_info(self,line):
        line_tab=line.split(',')
        if (re.match('host',line_tab[1])):
            self.host=line_tab[2].strip();
        if (re.match('Serial',line_tab[1])):
            self.serial=line_tab[2].strip();
        if (re.match('AIX',line_tab[1])):
            self.version=line_tab[2].strip();
            
    def proc_label_value(self,line):
        line_tab=line.strip().split(',')
        if line_tab[0] in self.copydata:
            line_tab[1]=self.zzzz[line_tab[1]]
            for i in range(len(self.labels[line_tab[0]])):
                self.copydata[line_tab[0]].write(self.serial+","+self.host+","+line_tab[1]+","+self.labels[line_tab[0]][i]+","+line_tab[i+2]+"\n")
        else:
            self.copydata[line_tab[0]]=io.StringIO();
            self.labels[line_tab[0]]=[];
            for i in iter(line_tab[2:]):
                self.labels[line_tab[0]].append(i.strip())
        
    def proc_metrics(self,line):
        line_tab=line.split(',')
        if line_tab[0] in self.copydata:
            line_tab[1]=self.zzzz[line_tab[1]]
            self.copydata[line_tab[0]].write(self.serial+","+self.host+","+','.join(line_tab[1:]).replace(',,',',0,'));
        else:
            self.copydata[line_tab[0]]=io.StringIO();
            
        
    def proc_top(self,line):
        line_tab=line.split(',')
        if line_tab[0] in self.copydata and re.match("[0-9]+",line_tab[1]):
            line_tab[2]=self.zzzz[line_tab[2]]
            self.copydata[line_tab[0]].write(self.serial+","+self.host+','+line_tab[2]+','+line_tab[1]+','+','.join(line_tab[3:]));
        else:
            self.copydata[line_tab[0]]=io.StringIO();

    def proc_uarg(self,line):
        line_tab=line.strip().split(',')
        if line_tab[0] in self.copydata:
            line_tab[1]=self.zzzz[line_tab[1]]
            self.copydata[line_tab[0]].write(self.serial+","+self.host+","+','.join(line_tab[1:8])+',"'+"full_command\n");
        else:
            self.copydata[line_tab[0]]=io.StringIO();
            
            
    def proc_zzzz(self,line):
        line_tab=line.split(',')
        self.zzzz[line_tab[1]]=line_tab[3].strip()+" "+line_tab[2].strip();

    def proc_skip(self,line):
        if (self.debug):
            print ("Skip:",line)

    def parse_line(self,line):
        for pattern,case in zip(self.lines_pattern,self.lines_proc):
            if (re.search(pattern,line)):
                case(line)

    def flush(self):
        for key in self.copydata.keys():
            cur = self.db_conn.cursor()
            self.copydata[key].seek(0);
            try:
                print("Import "+key+" for "+self.host);
                cur.copy_from(self.copydata[key],key,sep=',',null='#')
                self.db_conn.commit()
                cur.close()
            except:
                self.db_conn.rollback()
                print ("Caught Data error during copy "+key+ " for "+ self.host)
            cur.close()
            
                           
        
    def parse_file(self,file):
        self.copydata=dict()
        self.zzzz=dict()
        self.labels=dict()
        for line in iter(file):
            if (self.skip and (re.match(self.skip.strip(),line))):
                if (self.debug):
                    print ("Skip:",line)
            else:
                if (self.debug):
                    print ("Parse:",line)
                self.parse_line(line)
        self.flush()
                
                


config = configparser.ConfigParser()
config.read(os.environ['HOME']+'/.nmon2pg.ini')

parser = argparse.ArgumentParser()
parser.add_argument("--skip", help="Skip Regexp",default=config.get('MAIN','skip',fallback=None))
parser.add_argument("--dbhost",help="Postgres Database Host",default=config.get('DB','host',fallback="127.0.0.1"))
parser.add_argument("--dbname",help="Postgres Database Nmon",default=config.get('DB','name',fallback="nmon"))
parser.add_argument("--dbuser",help="Postgres Database user",default=config.get('DB','username',fallback="nmon"))
parser.add_argument("--dbpass",help="Postgres Database password",default=config.get('DB','password',fallback="nmon"))
parser.add_argument("--ssh_host",help="ssh hostname for remote connection",default=config.get('SSH','hosts',fallback=None))
parser.add_argument("--ssh_username",help="ssh username for remote connection",default=config.get('SSH','username',fallback=None))
parser.add_argument("--ssh_password",help="ssh password for remote connection",default=config.get('SSH','password',fallback=None));
parser.add_argument("--ssh_file",help="ssh remote file");
parser.add_argument("-f",type=argparse.FileType('r'), nargs='+');
args = parser.parse_args()


dbhost=args.dbhost
dbuser=args.dbuser
dbpass=args.dbpass
dbname=args.dbname


NMON=NMON_Import(skip=args.skip,pg_dbhost=dbhost,pg_dbname=dbname,pg_dbuser=dbuser,pg_dbpass=dbpass);

if (args.f is None and args.ssh_host):
    host_list=args.ssh_host.split(',')
    for host in iter(host_list):
        ssh=paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            ssh.connect(host,username=args.ssh_username,password=args.ssh_password)
        except:
            print ("Can not ssh connect to "+host);

        stdin, stdout, stderr = ssh.exec_command("ls "+args.ssh_file);
        for f in iter(stdout):
            print("import "+host+" file:"+f.strip());
            ftp = ssh.open_sftp()
            remote_file=ftp.open(f.strip())
            try:
                NMON.parse_file(remote_file)
            except:
                print("Pb Parse "+host);
                
            remote_file.close()
            ftp.close()
        ssh.close()
            
else:
    for nmon_file in args.f:
        NMON.parse_file(nmon_file)
        nmon_file.close();

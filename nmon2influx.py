#!/usr/bin/env python3

# TPEP import AIX nmon file to influxdb

import paramiko
import io
import argparse
import re
import configparser
import time
import pprint


from influxdb import InfluxDBClient

class NMON_Import:

    def __init__(self,skip,only,pg_dbhost="127.0.0.1",pg_dbname="nmon",pg_dbuser="nmon",pg_dbpass="nmon"):
        self.skip=skip
        self.only=only
        self.lines_pattern=['^AAA','^BBBP','^DISK.+|^VG.+|^PAGING|^WLM|^NET|^NPIV|^SEA|^IOADAPT|^LAN','^LPAR|^CPU_ALL|^MEM|^MEMNEW|^MEMUSE|^PAGE|^FILE|^PROC|^SUMMARY|^PCPU_ALL|^SCPU_ALL','^TOP','^ZZZZ','^UARG','^PROCAIO','^.CPU[0-9]+']
        self.lines_proc=[self.proc_info,self.proc_BBBP,self.proc_label_value,self.proc_metrics,self.proc_top,self.proc_zzzz,self.proc_uarg,self.proc_skip,self.proc_xcpuxx]
        self.host=""
        self.serial=""
        self.debug=0
        self.copydata=dict()
        self.json_body=[];
        self.col_name=dict()
        self.zzzz=dict()
        self.labels=dict()
        self.version=0
        self.copydata["INFO_HDISK"]=io.StringIO()

        self.influx_client=InfluxDBClient("127.0.0.1","8086",database='nmon');
        

    def proc_info(self,line):
        line_tab=line.split(',')
        if (re.match('host',line_tab[1])):
            self.host=line_tab[2].strip();
        if (re.match('Serial',line_tab[1])):
            self.serial=line_tab[2].strip();
        if (re.match('AIX',line_tab[1])):
            self.version=line_tab[2].strip();

    def proc_BBBP(self,line):
        if (re.search('m hdisk',line)):
            hdisk=re.search('"m (hdisk[0-9]+) .*"',line).group(1).strip()
            hdisk_type=re.search('".*-L[0-9]+\s+(.*)"',line).group(1).strip()
            
    def proc_label_value(self,line):
        r=line.replace(',,',',0,')
        line_tab=r.strip().split(',')
        if line_tab[0] in self.copydata:
            line_tab[1]=self.zzzz[line_tab[1]]
            epoch=int(time.mktime(time.strptime(line_tab[1],"%d-%b-%YT%H:%M:%SZ")))
            for i in range(len(self.labels[line_tab[0]])):
                self.json_body.append( {
                    "measurement":line_tab[0],
                    "tags": {
                        "serial":self.serial,
                        "host":self.host,
                        "label":self.labels[line_tab[0]][i]
                    },
                    "time":epoch,
                    "fields" : {
                        "value" : float(line_tab[i+2])
                    }
                })
        else:
            self.copydata[line_tab[0]]=True;
            self.labels[line_tab[0]]=[];
            for i in iter(line_tab[2:]):
                self.labels[line_tab[0]].append(i.strip())

    def proc_xcpuxx(self,line):
        r=line.replace(',,',',0,')
        line_tab=r.strip().split(',')
        fields=dict()
        cpu_id=re.search('^.CPU([0-9]+),.*',line).group(1).strip()
        cpu_type=re.search('(^.CPU)[0-9]+,.*',line).group(1).strip()

        if cpu_type in self.copydata and (re.match("T[0-9]+",line_tab[1])):
            line_tab[1]=self.zzzz[line_tab[1]]
            epoch=int(time.mktime(time.strptime(line_tab[1],"%d-%b-%YT%H:%M:%SZ")))
            l=len(self.col_name[cpu_type])
            for i in range(l-1):
                fields[self.col_name[cpu_type][i]]=float(line_tab[i+2])
            self.json_body.append( {
                "measurement":cpu_type,
                "tags": {
                    "serial":self.serial,
                    "host":self.host,
                    "id":cpu_id
                },
                "time":epoch,
                "fields" : fields
            })
        else:
            self.copydata[cpu_type]=True;
            self.col_name[cpu_type]=line_tab[2:]
                   
        
    def proc_metrics(self,line):
        r=line.replace(',,',',0,')
        line_tab=r.strip().split(',')
        fields=dict()
        if line_tab[0] in self.copydata:
            line_tab[1]=self.zzzz[line_tab[1]]
            t=line_tab[0]+",serial="+self.serial+",host="+self.host+" ";
            l=len(self.col_name[line_tab[0]])
            for i in range(l-1):
                fields[self.col_name[line_tab[0]][i]]=float(line_tab[i+2])
            epoch=int(time.mktime(time.strptime(line_tab[1],"%d-%b-%YT%H:%M:%SZ")))
            t=t+self.col_name[line_tab[0]][l-1]+"="+line_tab[l+1]+" "+str(epoch)
    #        print(t)

            self.json_body.append( {
                "measurement":line_tab[0],
                "tags": {
                    "serial":self.serial,
                    "host":self.host
                },
                "time":epoch,
                "fields" : fields
            })
        else:
            self.copydata[line_tab[0]]=True;
            self.col_name[line_tab[0]]=line_tab[2:]
            
                        
        
    def proc_top(self,line):
        line_tab=line.strip().split(',')
        fields=dict()
        if line_tab[0] in self.copydata and re.match("[0-9]+",line_tab[1]):
            line_tab[2]=self.zzzz[line_tab[2]]
            epoch=int(time.mktime(time.strptime(line_tab[2],"%d-%b-%YT%H:%M:%SZ")))
            l=len(self.col_name[line_tab[0]])
            for i in range(l-3):
                fields[self.col_name[line_tab[0]][i]]=float(line_tab[i+3])
            
            self.json_body.append( {
                "measurement":line_tab[0],
                "tags": {
                    "serial":self.serial,
                    "host":self.host,
                    "pid":int(line_tab[1]),
                    "cmd":line_tab[13]
                },
                "time":epoch,
                "fields" : fields
            })
        else:
            self.copydata[line_tab[0]]=True
            self.col_name[line_tab[0]]=line_tab[3:]
            
    def proc_uarg(self,line):
        line_tab=line.strip().split(',')
        if line_tab[0] in self.copydata:
            line_tab[1]=self.zzzz[line_tab[1]]
        else:
            self.copydata[line_tab[0]]=True;
            
            
    def proc_zzzz(self,line):
        line_tab=line.split(',')
        self.zzzz[line_tab[1]]=line_tab[3].strip()+"T"+line_tab[2].strip()+"Z";

    def proc_skip(self,line):
        if (self.debug):
            print ("Skip:",line)

    def parse_line(self,line):
        for pattern,case in zip(self.lines_pattern,self.lines_proc):
            if (re.search(pattern,line)):
                case(line)

    def flush(self):
#        pprint.pprint(self.json_body)
        self.influx_client.write_points(self.json_body,time_precision='s',batch_size=65535);
        self.json_body=[];
        
    def parse_file(self,file):
        self.copydata=dict()
        self.zzzz=dict()
        self.labels=dict()
        for line in iter(file):
            if (re.match("^ZZZZ|^AAA",line)):
                if (self.debug):
                    print ("ZZZZ:",line)
                self.parse_line(line)
            elif (self.only):
                if (re.match(self.only.strip(),line)):
                    if (self.debug):
                        print ("Only:",line)
                    self.parse_line(line)
                else:
                    pass                
            elif (self.skip and (re.match(self.skip.strip(),line))):
                if (self.debug):
                    print ("Skip:",line)
            else:
                if (self.debug):
                    print ("Parse:",line)
                self.parse_line(line)
        self.flush()
                
                


config = configparser.ConfigParser()
config.read('/home/tpeponas/.nmon2pg.ini')

parser = argparse.ArgumentParser()
parser.add_argument("--skip", help="Skip Regexp",default=config.get('MAIN','skip',fallback=None))
parser.add_argument("--only", help="Only Tab Regexp",default=config.get('MAIN','only',fallback=None))
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


NMON=NMON_Import(skip=args.skip,only=args.only,pg_dbhost=dbhost,pg_dbname=dbname,pg_dbuser=dbuser,pg_dbpass=dbpass);

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
            ftp.get(f.strip(),'/tmp/tmp_nmon2pg')
            ftp.close()
            remote_file=open('/tmp/tmp_nmon2pg',encoding='latin1')
            NMON.parse_file(remote_file)
            remote_file.close()
        ssh.close()
            
else:
    for nmon_file in args.f:
        NMON.parse_file(nmon_file)
        nmon_file.close();

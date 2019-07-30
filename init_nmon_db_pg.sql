


drop  table CPU_ALL CASCADE;
drop  table PCPU CASCADE;
drop  table SCPU CASCADE;
drop  table MEM CASCADE;
drop  table MEMNEW CASCADE;
drop  table MEMUSE CASCADE;
drop  table LPAR CASCADE;
drop  table DISKAVGRIO CASCADE;
drop  table DISKAVGWIO CASCADE;
drop  table DISKBSIZE CASCADE;
drop  table DISKBUSY CASCADE;
drop  table DISKREAD CASCADE;
drop  table DISKREADSERV CASCADE;
drop  table DISKRIO CASCADE;
drop  table DISKRXFER CASCADE;
drop  table DISKSERV CASCADE;
drop  table DISKWAIT CASCADE;
drop  table DISKWIO CASCADE;
drop  table DISKWRITE CASCADE;
drop  table DISKWRITESERV CASCADE;
drop  table DISKXFER CASCADE;
drop  table WLMCPU CASCADE;
drop  table WLMMEM CASCADE;
drop  table WLMBIO CASCADE;
drop  table VGBUSY CASCADE;
drop  table VGREAD CASCADE;
drop  table VGSIZE CASCADE;
drop  table VGWRITE CASCADE;
drop  table VGXFER CASCADE;
drop  table TOP CASCADE;
drop  table UARG CASCADE;
drop  table PAGE CASCADE;
drop  table PAGING CASCADE;
drop  table NET CASCADE;
drop  table NETPACKET CASCADE;
drop  table NETSIZE CASCADE;
drop  table NETERROR CASCADE;
drop  table IOADAPT CASCADE;
drop  table FILE CASCADE;
drop  table PROC CASCADE;
drop  table SUMMARY CASCADE;
drop  table NPIV CASCADE;


create  table CPU_ALL (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
	user_pct	real,
	sys_pct		real,
	wait_pct	real,
	idle_pct	real,
	busy		real,
	PhysicalCPUs	integer ) ;

create  table PCPU (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
	id		integer,
	puser        real,
        psys         real,
        pwait        real,
        pidle        real) ;


create  table SCPU (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        id              integer,
        suser        real,
        ssys         real,
        swait        real,
        sidle        real) ;

create  table MEM (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
	realfree_pct	real,
	virtualfree_pct	real,
	realfree_MB	real,
	virtualfree_MB	real,
	realtotal_MB	real,
	virtualtotal_MB	real ) ;

create  table MEMNEW (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
	process_pct	real,
	fscache_pct	real,
	system_pct	real,
	free_pct	real,
	pinned_pct	real,
	user_pct	real ) ;

create  table MEMUSE (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
	numperm_pct		real,
	minperm_pct		real,
	maxperm_pct		real,
	minfree_pct		real,
	maxfree_pct		real,
	numclient_pct	real,
	maxclient_pct	real,
	lruable_pages	real default 0.0) ;
	


create  table LPAR (
	Serial		char(16),
	host		char(16),
	nmon_time		timestamp with time zone,
	PhysicalCPU	real,
	virtualCPUs	integer,
	logicalCPUs	integer,
	poolCPUs	integer,
	entitled	real,
	weight		integer,
	PoolIdle	real,
	usedAllCPU_pct	real,
	usedPoolCPU_pct	real,
	SharedCPU	integer,
	Capped		integer,
	EC_User_pct	real,
	EC_Sys_pct	real,
	EC_Wait_pct	real,
	EC_Idle_pct	real,
	VP_User_pct	real,
	VP_Sys_pct	real,
	VP_Wait_pct	real,
	VP_Idle_pct	real,
	Folded		integer,
	Pool_id	integer ) ;

create  table DISKAVGRIO (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
	label		char(8),
	value		real ) ;

create  table DISKAVGWIO (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create  table DISKBSIZE (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(8),
	value           real ) ;
	
create  table DISKBUSY (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create  table DISKREAD (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(8),
	value           real ) ;

create  table DISKREADSERV (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create  table DISKRIO (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create  table DISKRXFER (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create  table DISKSERV (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create  table DISKWAIT (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create  table DISKWIO (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create  table DISKWRITE (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create  table DISKWRITESERV (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create  table DISKXFER (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(8),
	value           real ) ;

create  table WLMCPU (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(64),
        value           real ) ;


create  table WLMMEM (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(64),
        value           real ) ;


create  table WLMBIO (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(64),
        value           real ) ;


create  table VGBUSY (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
	label		char(32),
	value           real ) ;

create  table VGREAD (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label              char(32),
        value           real ) ;

create  table VGSIZE (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label              char(32),
        value           real ) ;

create  table VGWRITE (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label              char(32),
        value           real ) ;

create  table VGXFER (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label              char(32),
        value           real ) ;

create  table TOP (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
	pid		integer,
	cpu_pct		real,
	usr_pct		real,
	sys_pct		real,
	Threads		integer,
	Size		integer,
	ResText		integer,
	ResData		integer,
	CharIO		integer,
	ram_pct		real,
	Paging		integer,
	Command		char(256),
	WLMclass	char(64) ) ;

create  table UARG (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
	pid             integer,
	PPID		integer,
	COMM		char(64),
	THCOUNT		integer,	
	username	char(8),
	GROUPname	char(8), 
	full_command 	varchar(256)) ;

create  table PAGE (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
	faults		real,
	pgin		real,
	pgout		real,
	pgsin		real,
	pgsout		real,
	reclaims 	real,
	scans		real,
	cycles		real ) ;


create  table PAGING (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(32),
        value           real ) ;

create  table NET (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(32),
 	value		real);

create  table NETPACKET (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(32),
        value           real );

create  table NETSIZE (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(32),
        value        	real);


create  table NETERROR (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(32),
	value 		real);
	
create  table IOADAPT (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(32),
	read	real,
	write	real,
	tps	real ) ;

create  table FILE (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
	iget		real,
	namei		real,
	dirblk		real,
	readch		real,
	writech		real,	
	ttyrawch	real,
	ttycanch	real,
	ttyoutch	real ) ;


create  table PROC (
	Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
	Runnable	real,
	Swap_in		 real,
	pswitch		real,
	syscall		real,
	read		real,
	write		real,
	fork		real,
	exec		 real,
	sem		real,
	msg		real,
	asleep_bufio	real,
	asleep_rawio	real,
	asleep_diocio	real ) ;

create  table SUMMARY (
	Serial		char(16),
	host		char(16),
	nmon_time		timestamp with time zone,
	Processes	integer,
	pct_usr		real,
	pct_sys		real,
	ResTextKB	real,
	ResDataKB	real,
	CharIOKB	real,
	paging		real,
	Command		char(256));

create  table NPIV (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(64),
        value           real ) ;


create  table SEA (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(64),
        value           real ) ;

create  table NPIV (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(64),
        value           real ) ;

create  table SEACHPHY (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(64),
        value           real ) ;

create  table SEA (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(64),
        value           real ) ;

create  table SEAPACKET  (
        Serial          char(16),
        host            char(16),
        nmon_time            timestamp with time zone,
        label           char(64),
        value           real ) ;


SELECT create_hypertable('CPU_ALL','nmon_time');
SELECT create_hypertable('PCPU','nmon_time');
SELECT create_hypertable('SCPU','nmon_time');
SELECT create_hypertable('MEM','nmon_time');
SELECT create_hypertable('MEMNEW','nmon_time');
SELECT create_hypertable('MEMUSE','nmon_time');
SELECT create_hypertable('LPAR','nmon_time');
SELECT create_hypertable('DISKAVGRIO','nmon_time');
SELECT create_hypertable('DISKAVGWIO','nmon_time');
SELECT create_hypertable('DISKBSIZE','nmon_time');
SELECT create_hypertable('DISKBUSY','nmon_time');
SELECT create_hypertable('DISKREAD','nmon_time');
SELECT create_hypertable('DISKREADSERV','nmon_time');
SELECT create_hypertable('DISKRIO','nmon_time');
SELECT create_hypertable('DISKRXFER','nmon_time');
SELECT create_hypertable('DISKSERV','nmon_time');
SELECT create_hypertable('DISKWAIT','nmon_time');
SELECT create_hypertable('DISKWIO','nmon_time');
SELECT create_hypertable('DISKWRITE','nmon_time');
SELECT create_hypertable('DISKWRITESERV','nmon_time');
SELECT create_hypertable('DISKXFER','nmon_time');
SELECT create_hypertable('WLMCPU','nmon_time');
SELECT create_hypertable('WLMMEM','nmon_time');
SELECT create_hypertable('WLMBIO','nmon_time');
SELECT create_hypertable('VGBUSY','nmon_time');
SELECT create_hypertable('VGREAD','nmon_time');
SELECT create_hypertable('VGSIZE','nmon_time');
SELECT create_hypertable('VGWRITE','nmon_time');
SELECT create_hypertable('VGXFER','nmon_time');
SELECT create_hypertable('TOP','nmon_time');
SELECT create_hypertable('UARG','nmon_time');
SELECT create_hypertable('PAGE','nmon_time');
SELECT create_hypertable('PAGING','nmon_time');
SELECT create_hypertable('NET','nmon_time');
SELECT create_hypertable('NETPACKET','nmon_time');
SELECT create_hypertable('NETSIZE','nmon_time');
SELECT create_hypertable('NETERROR','nmon_time');
SELECT create_hypertable('IOADAPT','nmon_time');
SELECT create_hypertable('FILE','nmon_time');
SELECT create_hypertable('PROC','nmon_time');
SELECT create_hypertable('SUMMARY','nmon_time');
SELECT create_hypertable('NPIV','nmon_time');


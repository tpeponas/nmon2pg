


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
drop table SUMMARY CASCADE;


create UNLOGGED table CPU_ALL (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
	user_pct	real,
	sys_pct		real,
	wait_pct	real,
	idle_pct	real,
	busy		real,
	PhysicalCPUs	integer ) ;

create UNLOGGED table PCPU (
        Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
	id		integer,
	puser        real,
        psys         real,
        pwait        real,
        pidle        real) ;


create UNLOGGED table SCPU (
        Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        id              integer,
        suser        real,
        ssys         real,
        swait        real,
        sidle        real) ;

create UNLOGGED table MEM (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
	realfree_pct	real,
	virtualfree_pct	real,
	realfree_MB	real,
	virtualfree_MB	real,
	realtotal_MB	real,
	virtualtotal_MB	real ) ;

create UNLOGGED table MEMNEW (
        Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
	process_pct	real,
	fscache_pct	real,
	system_pct	real,
	free_pct	real,
	pinned_pct	real,
	user_pct	real ) ;

create UNLOGGED table MEMUSE (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
	numperm_pct		real,
	minperm_pct		real,
	maxperm_pct		real,
	minfree_pct		real,
	maxfree_pct		real,
	numclient_pct	real,
	maxclient_pct	real,
	lruable_pages	real default 0.0) ;
	


create UNLOGGED table LPAR (
	Serial		char(16),
	host		char(16),
	time		timestamp with time zone,
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

create UNLOGGED table DISKAVGRIO (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
	label		char(8),
	value		real ) ;

create UNLOGGED table DISKAVGWIO (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create UNLOGGED table DISKBSIZE (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(8),
	value           real ) ;
	
create UNLOGGED table DISKBUSY (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create UNLOGGED table DISKREAD (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(8),
	value           real ) ;

create UNLOGGED table DISKREADSERV (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create UNLOGGED table DISKRIO (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create UNLOGGED table DISKRXFER (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create UNLOGGED table DISKSERV (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create UNLOGGED table DISKWAIT (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create UNLOGGED table DISKWIO (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create UNLOGGED table DISKWRITE (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create UNLOGGED table DISKWRITESERV (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(8),
	value           real ) ;


create UNLOGGED table DISKXFER (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(8),
	value           real ) ;

create UNLOGGED table WLMCPU (
        Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(64),
        value           real ) ;


create UNLOGGED table WLMMEM (
        Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(64),
        value           real ) ;


create UNLOGGED table WLMBIO (
        Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(64),
        value           real ) ;


create UNLOGGED table VGBUSY (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
	label		char(32),
	value           real ) ;

create UNLOGGED table VGREAD (
        Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label              char(32),
        value           real ) ;

create UNLOGGED table VGSIZE (
        Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label              char(32),
        value           real ) ;

create UNLOGGED table VGWRITE (
        Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label              char(32),
        value           real ) ;

create UNLOGGED table VGXFER (
        Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label              char(32),
        value           real ) ;

create UNLOGGED table TOP (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
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

create UNLOGGED table UARG (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
	pid             integer,
	PPID		integer,
	COMM		char(64),
	THCOUNT		integer,	
	username	char(8),
	GROUPname	char(8), 
	full_command 	varchar(256)) ;

create UNLOGGED table PAGE (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
	faults		real,
	pgin		real,
	pgout		real,
	pgsin		real,
	pgsout		real,
	reclaims 	real,
	scans		real,
	cycles		real ) ;


create UNLOGGED table PAGING (
        Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(32),
        value           real ) ;

create UNLOGGED table NET (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(32),
 	value		real);

create UNLOGGED table NETPACKET (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(32),
        value           real );

create UNLOGGED table NETSIZE (
        Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(32),
        value        	real);


create UNLOGGED table NETERROR (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(32),
	value 		real);
	
create UNLOGGED table IOADAPT (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
        label           char(32),
	read	real,
	write	real,
	tps	real ) ;

create UNLOGGED table FILE (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
	iget		real,
	namei		real,
	dirblk		real,
	readch		real,
	writech		real,	
	ttyrawch	real,
	ttycanch	real,
	ttyoutch	real ) ;


create UNLOGGED table PROC (
	Serial          char(16),
        host            char(16),
        time            timestamp with time zone,
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

create UNLOGGED table SUMMARY (
	Serial		char(16),
	host		char(16),
	time		timestamp with time zone,
	Processes	integer,
	pct_usr		real,
	pct_sys		real,
	ResTextKB	real,
	ResDataKB	real,
	CharIOKB	real,
	paging		real,
	Command		char(256));


create table INFO_SERVEUR(serial char(16),type char(32),rate real);


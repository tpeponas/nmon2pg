
drop table CPU_ALL;
drop table MEM;
drop table MEMNEW;
drop table MEMUSE;
drop table LPAR;
drop table DISKAVGRIO;
drop table DISKAVGWIO;
drop table DISKBSIZE;
drop table DISKBUSY;
drop table DISKREAD;
drop table DISKREADSERV;
drop table DISKRIO;
drop table DISKRXFER;
drop table DISKSERV;
drop table DISKWAIT;
drop table DISKWIO;
drop table DISKWRITE;
drop table DISKWRITESERV;
drop table DISKXFER;
drop table WLMCPU;
drop table WLMMEM;
drop table WLMBIO;
drop table VGBUSY;
drop table VGREAD;
drop table VGSIZE;
drop table VGWRITE;
drop table VGXFER;
drop table TOP;
drop table UARG;
drop table PAGE;
drop table PAGING;


create table CPU_ALL (
	Serial          char(16),
        host            char(16),
        time            timestamp,
	user_pct	real,
	sys_pct		real,
	wait_pct	real,
	idle_pct	real,
	busy		real,
	PhysicalCPUs	integer);

create table MEM (
	Serial          char(16),
        host            char(16),
        time            timestamp,
	realfree_pct	real,
	virtualfree_pct	real,
	realfree_MB	real,
	virtualfree_MB	real,
	realtotal_MB	real,
	virtualtotal_MB	real);

create table MEMNEW (
        Serial          char(16),
        host            char(16),
        time            timestamp,
	process_pct	real,
	fscache_pct	real,
	system_pct	real,
	free_pct	real,
	pinned_pct	real,
	user_pct	real);

create table MEMUSE (
	Serial          char(16),
        host            char(16),
        time            timestamp,
	numperm_pct		real,
	minperm_pct		real,
	maxperm_pct		real,
	minfree_pct		real,
	maxfree_pct		real,
	numclient_pct	real,
	maxclient_pct	real,
	lruable_pages	real);
	


create table LPAR (
	Serial		char(16),
	host		char(16),
	time		timestamp,
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
	Pool_id	integer);

create table DISKAVGRIO (
	Serial          char(16),
        host            char(16),
        time            timestamp,
	label		char(8),
	value		real);

create table DISKAVGWIO (
	Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(8),
	value           real);


create table DISKBSIZE (
	Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(8),
	value           real);
	
create table DISKBUSY (
	Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(8),
	value           real);


create table DISKREAD (
	Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(8),
	value           real);

create table DISKREADSERV (
	Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(8),
	value           real);


create table DISKRIO (
	Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(8),
	value           real);


create table DISKRXFER (
	Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(8),
	value           real);


create table DISKSERV (
	Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(8),
	value           real);


create table DISKWAIT (
	Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(8),
	value           real);


create table DISKWIO (
	Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(8),
	value           real);


create table DISKWRITE (
	Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(8),
	value           real);


create table DISKWRITESERV (
	Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(8),
	value           real);


create table DISKXFER (
	Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(8),
	value           real);

create table WLMCPU (
        Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(64),
        value           real);


create table WLMMEM (
        Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(64),
        value           real);


create table WLMBIO (
        Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(64),
        value           real);


create table VGBUSY (
	Serial          char(16),
        host            char(16),
        time            timestamp,
	label		char(32),
	value           real);

create table VGREAD (
        Serial          char(16),
        host            char(16),
        time            timestamp,
        label              char(32),
        value           real);

create table VGSIZE (
        Serial          char(16),
        host            char(16),
        time            timestamp,
        label              char(32),
        value           real);

create table VGWRITE (
        Serial          char(16),
        host            char(16),
        time            timestamp,
        label              char(32),
        value           real);

create table VGXFER (
        Serial          char(16),
        host            char(16),
        time            timestamp,
        label              char(32),
        value           real);

create table TOP (
	Serial          char(16),
        host            char(16),
        time            timestamp,
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
	WLMclass	char(64));

create table UARG (
	Serial          char(16),
        host            char(16),
        time            timestamp,
	pid             integer,
	PPID		integer,
	COMM		char(64),
	THCOUNT		integer,	
	username	char(8),
	GROUPname	char(8));

create table PAGE (
	Serial          char(16),
        host            char(16),
        time            timestamp,
	faults		real,
	pgin		real,
	pgout		real,
	pgsin		real,
	pgsout		real,
	reclaims 	real,
	scans		real,
	cycles		real);


create table PAGING (
        Serial          char(16),
        host            char(16),
        time            timestamp,
        label           char(32),
        value           real);



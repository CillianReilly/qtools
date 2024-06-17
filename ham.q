// hdb analysis and maintenance 

\d .log
msg:{-1" ### "sv(-3_string .z.p;x;y);}
out:msg"OUT"
wrn:msg"WRN"
err:msg"ERR"
\d .

exists:0<count key@
dde:{where[0<count each x]#x}		// drop dictionary empties

// dbmaint allpaths does not respect .Q.view
paths:{.Q.dd'[.Q.pd;].Q.pv,\:x}
dotd:{paths x,`.d}

lastpath:{.Q.dd[.Q.d0[];x]}
lastdotd:{lastpath x,`.d}

usage:{
	-1"usage: q ham.q <path to hdb> -tables [tables] -par [partitions] -level [0-8] -dbmaint [01]";-1"";
	-1"path to hdb is mandatory. all other flags are optional and defaults are described below";-1"";
	-1"tables : tables to analyse. default is all partitioned tables in the hdb";
	-1"par    : partitions to analyse. default is all partitions in the hdb, otherwise restricts using .Q.view";
	-1"dbmaint: perform maintenance on the hdb. default is 0 (no maintenance)";
	-1"level  : level of analysis, least to most intensive. default is 6";
	-1"      0: check if specified tables exist in specified partitions";
	-1"      1: check if .d files exist in specified partitions";
	-1"      2: check if partition field (.Q.pf) exists in the .d file per partiton";
	-1"      3: check if partition field (.Q.pf) exists on disk per partition";
	-1"      4: check if all columns in the .d file exist in the same partition";
	-1"      5: check if all columns from the latest partition exist in each partition";
	-1"      6: check if the order of columns per partition matches that of the latest partition";
	-1"      7: check if the column types per partition match that of the latest partition";
	-1"      8: check if column counts are consistent across columns per partition";
	-1"wlevel  : level of warnings, least to most intensive. default is 2";
	-1"      0: check if enumeration files exist in the hdb root e.g. sym";
	-1"      1: check if all columns on disk exist in the .d file of the same partition";
	-1"      2: check if all column attributes match those of the latest partition";
	-1"      2: check if all foreign keys match those of the latest partition";
	}

/ -------- analysis -------- /

al0:{
	.log.out"analysis level 0: checking existence of table(s)...";
	t:x!.Q.pv where each not exists each'paths each x;
	if[any 0<count each t;.log.err"analysis level 0: table(s) missing from partition(s):";show t];
	t
	}

al1:{
	.log.out"analysis level 1: checking existence of .d file(s)...";
	d:x!.Q.pv where each not exists each'dotd each x;
	if[any 0<count each d;.log.err"analysis level 1: .d file missing from partition(s):";show d];
	d
	}

al2:{
	.log.out"analysis level 2: checking if partition field (",string[.Q.pf],") exists in .d file...";
 	d:x!.Q.pv where each .Q.pf in''@[get;;`]each'dotd each x;
	if[any 0<count each d;.log.err"analysis level 2: partition field (",string[.Q.pf],") exists in .d file of partition(s):";show d];
	d
	}

al3:{
	.log.out"analysis level 3: checking if partition field (",string[.Q.pf],") exists on disk...";
	d:x!.Q.pv where each exists each'paths each x,'.Q.pf;
	if[any 0<count each d;.log.err"analysis level 3: partition field (",string[.Q.pf],") exists on disk in partition(s):";show d];
	d
	}

al4:{
	.log.out"analysis level 4: comparing contents of .d file(s) to columns in the same partition...";
	c:key each'paths each x;
	d:@[get;;1#`]each'dotd each x;
	d:x!dde each .Q.pv!/:d except''c;
	if[any 0<count each d;.log.err"analysis level 4: .d file specifies columns not found in the same partition:";show d];
	d
	}

al5:{
	.log.out"analysis level 5: checking for existence of columns from latest partition...";
	c:x!dde each .Q.pv!/:{last[c]except/:c:get each dotd x}each x;
	if[any 0<count each c;.log.err"analysis level 5: column(s) missing from partition(s):";show c];
	c
	}

al6:{
	.log.out"analysis level 6: checking order of columns vs latest partition...";
	d:@[get;;`]each'dotd each x;
	d:x!.Q.pv where each not(last each d)~/:'d;
	if[any 0<count each d;.log.err"analysis level 6: order of columns is incorrect in partition(s):";show d];
	d
	}

al7:{
	.log.out"analysis level 7: comparing column types to latest...";
	t:@[.Q.ty each .Q.V@;;{#[;" "]count@}]each'paths each x;
	t:x!dde each .Q.pv!/:where each'not t0=/:'t@\:'key each t0:last each t;
	if[any 0<count each t;.log.err"analysis level 7: column type(s) not matching latest partition:";show t];
	t
	}

al8:{
	.log.out"analysis level 8: checking column counts per partition...";
	c:flip each get each''paths each'x,/:'get each lastdotd each x;
	c:x!.Q.pv where each(any 1_differ count each)each'c;
	if[any 0<count each c;.log.err"analysis level 8: column counts not consistent per partition(s):";show c];
	c
	}


/ -------- warnings -------- /

wl0:{
	.log.out"warning level 0: checking for existence of enumeration(s)...";
	e:{distinct key each d where(type each d:.Q.V x)within 20 76}each x;
	e:x!e where each not e in key`:.;
	if[any 0<count each e;.log.err"warning level 0: enumeration(s) missing from hdb directory: ";show e];
	e
	}

wl1:{
	.log.out"warning level 1: comparing columns to .d file in the same partition...";
	c:1_''key each'paths each x;
	d:@[get;;1#`]each'dotd each x;
	c:x!dde each .Q.pv!/:c except''d;
	if[any 0<count each c;.log.out"warning level 1: columns found on disk not specified in .d file of the same partition...";show c];
	c
	}

wl2:{
	.log.out"warning level 2: comparing column attributes to latest...";
	a:@[attr each .Q.V@;;{{count[x]#`}}]each'paths each x;
	a:x!dde each .Q.pv!/:where each'not a0=/:'a@\:'key each a0:last each a;
	if[any 0<count each a;.log.out"warning level 2: column attribute(s) not matching latest partition:";show a];
	a
	}

wl3:{
	.log.out"warning level 3: comparing foreign keys to latest...";
	f:@[.Q.fk each .Q.V@;;{{count[x]#`}}]each'paths each x;
	f:x!dde each .Q.pv!/:where each'not f0=/:'f@\:'key each f0:last each f;
	if[any 0<count each f;.log.out"warning level 3: foreign key(s) not matching latest partition:";show f];
	f
	}

/ -------- maintenance -------- /

ml0:{
	.log.out"maintenance level 0: running .Q.chk against hdb location...";
	.log.wrn"maintenance level 0: .Q.chk does not respect .Q.view - filling ALL partitions...";
	p:@[.Q.chk;`:.;{.log.err"error running .Q.chk: ",x;exit 1}];
	.log.out"maintenance level 0: successfully filled ",string[sum not()~/:p]," partition(s)";
	}

ml1:{
	.log.out"maintenance level 1: populating .d file(s) with columns found in partition...";
	x:dde x 1;
	d:dotd each key x;
	c0:(get last@)each d;
	(d@'i)set''c0 inter/:'key each'(paths each key x)@'i:.Q.pv?value x;
	.log.out"maintenance level 1: successfully wrote ",string[sum count each x]," .d file(s)";	
	}

ml2:{
	.log.out"maintenance level 2: removing partition field (",string[.Q.pf],") from .d file...";
	x:dde x 2;
	{x set except[;.Q.pf]get x}each'(dotd each key x)@'.Q.pv?value x;
	.log.out"maintenance level 2: successfully removed partition field (",string[.Q.pf],") from ",string[sum count each x]," .d filei(s)"
	}

ml3:{
	.log.out"maintenance level 3: removing partition field (",string[.Q.pf],") file(s) from disk...";
	x:dde x 3;
	.os.del each'(paths each key[x],'`date)@'.Q.pv?value x;
	.log.out"maintenance level 3: successfully removed ",string[sum count each x]," partition field file(s) from disk";
	}

ml4:{
	.log.out"maintenance level 4: removing missing columns from .d file(s)...";
	x:dde x 4;
	d:(dotd each key x)@'.Q.pv?key each value x;
	d set''(get each'd)except''value each value x;
	.log.out"maintenance level 4: successfully removed columns from ",string[sum count each x]," .d file(s)";
	}

ml5:{
	.log.out"maintenance level 5: adding missing columns to partition(s) and .d file(s)...";
	x:dde x 5;
	{ p:paths[x].Q.pv?key y;
	  t:c!$[;" "]upper .Q.ty each lastpath[x]c:distinct raze value y;
	  add1col''[p;value y;t value y]
	  }'[key x;value x];
	.log.out"maintenance level 5: successfully wrote all missing column(s)";
	}

ml6:{
	.log.out"maintenance level 6: re-ordering columns to match latest partition...";
	x:dde x 6;
	p:(paths each key x)@'.Q.pv?x;
	d:get each'lastdotd each key x;
	reordercols0\:'[p;d];
	.log.out"maintenance level 6: successfully re-ordered ",string[sum count each x]," partitions";
	}

ml7:{
	.log.out"maintenance level 7: casting columns to match latest partition...";
	x:dde x 7;
	{ p:paths[x].Q.pv?key y;
	  t:c!(eval($;)@)each'type each lastpath[x]c:distinct raze value y;
	  fn1col''[p;value y;t value y]
	  }'[key x;value x];
	.log.out"maintenance level 7: sucessfully cast ",string[sum count each x]," column(s)"	
	}

ml8:{
	.log.out"maintenance level 8: padding truncated column(s) with nulls to max column length per partition...";
	x:dde x 8;
	p:(paths each key x)@'.Q.pv?value x;
	d0:get each lastdotd each key x;
	a:{(max[c]-c:count each x)#'x[;-1]}each'p@\:'d0;
	@'[;d0;,;]'[p;a];
	.log.out"maintenance level 8: successfully padded truncated column(s)";
	}

lh:{
        .log.out"attempting to load hdb: ",x;
        @[.Q.l;`$x;{.log.err"error loading hdb: ",x;exit 1}];
        .log.out"hdb loaded succesfully";
        .log.out"partitioned table(s) loaded: ",", "sv string key .Q.pn;
        ;.log.out"total partition count: ",string count .Q.pv;
        }

ld:{
	// curl https://raw.githubusercontent.com/KxSystems/kdb/master/utils/dbmaint.q >> $QHOME/dbmaint.q
	.log.out"loading dbmaint.q...";
	@[system;"l dbmaint.q";{.log.err"error loading dbmaint.q: ",x;exit 1}];
	@[`.;`stdout;:;{}];	// mute dbmaint logs
	}

pa:{
	.log.out"parsing command-line arguments...";
	d:`hdb`tables`par`dbmaint`level`wlevel!(`:.^hsym`$first .z.x;key .Q.pn;.Q.pv;0;6;1);
	a:.Q.def[d;].Q.opt x;
	a:`tables _@[a;`t;:;key[.Q.pn]inter a`tables];
	a:@[a;`level`wlevel;til 1+];
	a
	}

rp:{
	.log.out"restricting hdb partitions using .Q.view..."
	@[.Q.view;x;{.log.err"error calling .Q.view: ",x;exit 1}];
	.log.out"restricted partition count: ",string count .Q.pv;
	}

ra:{
	.log.out"running analysis level(s): ",string[last x`level]," and below...";
	k:([]level:x`level);
	af:`$"al",/:string x`level;
	t:k!af@\:x`t;
	.log.out"finished running initial analysis";
	t
	}

rw:{
	.log.out"running warning(s): ",string[last x`wlevel]," and below...";
	k:([]level:x`wlevel);
	wf:`$"wl",/:string x`wlevel;
	t:k!wf@\:x`t;
	.log.out"finished running warnings";
	t
	}

rm:{
	level:first where any 0<count each'flip value x;
	if[null level;:x];

	.log.out"re-running analysis level ",string[level]," pre-maintenance...";
	af:`$"al",string level;
	x:@[x;level;:;]af key first x;

	if[not any count each x level;
		.log.out"issues at analysis level ",string[level]," have been resolved already";
		:x
		];

	mf:value`$"ml",string level;
	@[mf;x;{.log.err"error running maintenance: ",x}];

	.log.out"re-running analysis level ",string[level]," post-maintenance...";
	@[x;level;:;]af key first x
	}

init:{
	lh first x;
	a:pa x;
	rp distinct a[`par],last .Q.pv;

	ar:ra a;
	show ar;

	wr:rw a;
	show wr;
	

	if[not 2 any/count each'flip value ar;
		.log.out"no hdb issues found during analysis";
		exit 0
		];

	if[not a`dbmaint;
		.log.out"dbmaint flag is set to false, exiting...";
		exit 0;
		];

	ld[];
	.log.out"running applicable maintenance level(s): ",string[last a`level]," and below...";
	mr:rm/[ar];
	show mr;
	.log.out"finished running maintenance";
	}

if[not count .z.x;usage[];exit 1]
init .z.x;

exit 0

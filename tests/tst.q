// Generic unit test framework
\l log.q
\d .tst

utl.dbg:`dbg in key .Q.opt .z.X

utl.true:{
	if[not -1 10h~type each(x;y);.log.err"utl.true: Incorrect argument types: ",", "sv string type each(x;y);:0b];
	if[not x;.log.err y];
	x
	}
utl.logTestInfo:{.log.out"Running ",string[x]," unit test(s)..."}
utl.nsFuncs:{x where 100=('[type;value])each x:` sv'x,'1_key[x]except`setUp`tearDown}
utl.testDic:{x!count[x]#0b}
utl.createTests:{y set utl.testDic utl.nsFuncs x}
utl.runTests:{x set f!utl.pex each f:key x}
utl.compVars:{raze(x;y)except\:x inter y:(),y}

utl.pex:{
	@[value x;[];
	{.log.err"Error running test: ",string[y],", error: ",x;0b}[;x]
	]}

utl.loadTests:{
	f:f where like[;"*.q"]f:key[x]except`tst.q;
	.log.out"Loading test files found: ",", "sv string f;
	system each"l ",/:(1_string x),/:"/",/:string f;
	}

utl.test:{
	t:` sv x,`tests;
	utl.createTests[x;t];
	if[`setUp in key x;x[`setUp][]];
	utl.logTestInfo each(x;count value t);
	utl.runTests t;
	if[`tearDown in key x;x[`tearDown][]];
	utl.true[all value t;"Failing ",string[x]," tests: ",", "sv string where not value t];
	.log.out"Finished runnning ",string[x]," tests"
	}

utl.checkResults:{
	results:value each` sv/:x,'`tests;
	pass:2 all/results;
	$[pass;
		.log.out"All unit tests passing";
		.log.err"Number of failed tests: ",string 2 sum/not results
	];
	pass
	}

utl.testFile:{utl.true[-11=type key x;"File not found: ",1_string x]}

utl.testVars:{
        k:key[x]except`;
        utl.true[asc[k]~ asc y;string[x]," variable(s) not defined: ",", "sv string utl.compVars[k;y]]
        }

utl.testRootVars:{
	utl.true[all v;"Root variables not defined: ",", "sv string x where not v:in[;key`.]x,:()]
	}

utl.testOutput:{
	out:x each y;
	utl.true[out~z;utl.outputDiff[x;out;z]]
	}

utl.outputDiff:{
	d:(y;z)@\:where not(~').(),/:(y;z);
	if[10<>abs first type each z;d:string d];
	d:", "sv/:d;
	string[x]," does not have expected output(s): expected: [",(d 0),"], got: [",(d 1),"]"
	}

utl.init:{
	utl.loadTests`:tests;
	modules:key[`.tst]except``utl;
	.log.out"Starting unit tests...";
	utl.test each modules;
	result:utl.checkResults modules;
	if[not utl.dbg;exit not result]
	}

utl.init[]

\d .

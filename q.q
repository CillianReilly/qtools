CLI:1^first"J"$.Q.opt[.z.x]`cli

if[CLI;
	clear:{1"\033[H\033[J";};
	paste:{value last{not"\n"~2 first/x}{1(x[1],)\read0[0],` sv enlist""}/(" ";"")};
	resize:{system"c ",first system"stty size"};
	resize[]
	]

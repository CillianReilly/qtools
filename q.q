CLI:1^first"J"$.Q.opt[.z.x]`cli

if[CLI;
	clear:{1"\033[H\033[J";};
	resize:{system"c ",first system"stty size"};
	resize[]
	]

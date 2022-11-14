CLI:1^first"J"$.Q.opt[.z.x]`cli

if[CLI;
	clear:{1"\033[H\033[J";};
	// {value{x,read0 0}/[""]}	// No comments or blank lines
	paste:{value({$[(""~r:read0 0)and not x;(x;"");(x+/124-7h$"{}"inter r;y,` sv enlist r)]}.)/[(0;"")]};
	resize:{system"c ",first system"stty size"};
	resize[]
	]

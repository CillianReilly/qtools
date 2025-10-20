CLI:1^first"J"$.Q.opt[.z.x]`cli

clear:{1"\033[H\033[J";};
// {value{x,read0 0}/[""]}  // No comments or blank lines
paste:{value{$[(""~r:read0 0)and not sum 124-7h$x inter"{}";x;x,` sv enlist r]}/[""]};
resize:{system"c ",first system"stty size"};

CLI:1^first"J"$.Q.opt[.z.x]`cli
if[CLI;resize[]]

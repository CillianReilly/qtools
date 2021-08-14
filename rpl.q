//Replication - point at target process to emulate CLI 

if[not"-port"in .z.X;0N!"Usage:q rpl.q -port <port> [-host <host>]";exit 1]

params:.Q.opt .z.x
addr:`$":"sv enlist[""],first each params`host`port
handle:@[hopen;addr;{-1"Couldn't connect to ",string[y],": ",x;exit 1}[;addr]]

.z.pi:{	y:-1_y;
	if[(y~"\\\\")or y like"exit *";value y];
	show @[x;y;{"'",x}]
	}handle

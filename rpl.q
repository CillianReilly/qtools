//Replication - point at target process to emulate CLI 

addr:`$":",first .z.x,count[.z.x]_enlist":5000"
handle:@[hopen;addr;{-1"Couldn't connect to ",string[y],": ",x;exit 1}[;addr]]

.z.pi:{	y:-1_y;
	if[(y~"\\\\")or y like"exit *";value y];
	show @[x;y;{"'",x}]
	}handle

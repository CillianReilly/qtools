if[not"-cmd"in .z.X;0N!"Usage: q rrc.q :5010 -cmd <cmd> [-async]";exit 1]

params:.Q.opt .z.x
cmd:first params`cmd
async:(`async in key params)or any cmd like/:("*\\\\*";"*exit *")

addr:`$":",first .z.x,count[.z.x]_enlist":5000"
handle:(1 -1 async)*@[hopen;addr;{-1"Couldn't connect to ",string[y],": ",x;exit 1}[;addr]];
r:handle cmd;if[async;handle[]]

if[not async;-1 $[10=abs type r;r;.Q.s1 r]];
exit 0

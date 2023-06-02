\d .utl

cfg.enc:(!). flip(
	("+";"%2B");
	("?";"%3F");
	(")";"%29");
	("{";"%7B");
	("}";"%7D");
	(",";"%2C");
	("#";"%23");
	("/";"%2F");
	(" ";"+")
	)
cfg.dec:(!). reverse each(value;key)@\:cfg.enc

// Deprecated by .Q.btoa in kdb+ 3.6
enc.base64:{.Q.b6 2 sv/:00b,/:0N 6#b,{((6*1+x div 6)-x)#0b}count b:raze 0b vs/:4h$x}
dec.base64:{`char$2 sv/:0N 8##[;b]8*div[;8]count b:raze 2_/:0b vs/:4h$.Q.b6?x}

http.get:{x"\r\n"sv("GET ",y," HTTP/1.0";"Host: ",(3+s?":")_s:1_string x;z;"";"")}
http.post:{[url;ep;rh;req]url"\r\n"sv("POST ",ep," HTTP/1.1";"Host: ",9_string url;rh;"";req;"";"")}

http.pt:{(0^4+first x ss"\r\n\r\n")_x}
http.jk:{.j.k 2{reverse min[x?"{}"]_x}/x}
http.map:{raze ssr/[x;key y;value y]}
http.dec:http.map[;cfg.dec]
http.enc:http.map[;cfg.enc]
http.genRH:"\r\n"sv(,').(key;value)@\:
http.parseRC:{"J"$x 0 1 2+first x ss"[0-9][0-9][0-9]"}
http.parseRH:{(!).(`code;http.parseRC x),'(`$except\:[;"-"]@;::)@'flip((0,'i+/:(s?\:":"))_'s:1_r:d vs(x ss d,d:"\r\n")#x)@\:i:0 2}
http.parseRP:(!).("S*";"=")0:"&"vs
http.genParamStr:{"&"sv"="sv/:flip{@[x;where -10=type each x;1#]}each(key;value)@\:where[0<>count each x]#x}
http.genEncParamStr:http.enc http.genParamStr@

\d .

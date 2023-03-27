\l p.q

.smtplib:.p.import`smtplib

\d .email

DOMAIN:""
PORT:0N
USER:""
PASSWORD:""

header:{first["@"vs x]," <",x,">"}
send:{[t;f;s;b]	// to from subject body
	smtp:.[.smtplib`:SMTP;(DOMAIN;PORT);{-1"Error connecting to SMTP server: ",x;`err}];if[smtp~`err;:()];
	r:.[smtp`:login;(USER;PASSWORD);{-1"Error authenticating with SMTP server: ",x;`err}];if[r~`err;:()];
	t:"To: ",header t;
	if[not"@"in f;f:"@"sv(f;DOMAIN)];
	f:"From: ",header f;
	s:"Subject: ",s;
	m:"\n"sv(t;f;s,"\n";b);
	smtp[`:sendmail][f;t;m]
	}

\d .

/sample usage to test slaves mode: - q multithreaded.q -s 2 -p 5001
/sample usage to test multi threaded input mode: - q multithreaded.q -p -5001

\l taq.q

/function well suited to multi threading because ith iteration takes a long time
proc1_wrapper:{[s]
	show s;
	do[400;res:proc1[s]];
	res
 };

/
/ \t proc1_wrapper[portfolio[0]];

show"TEST 1"; /this is a comment
/test slave mode for function well suited to multi threading
show"single threaded";
\t res1:raze proc1_wrapper each portfolio
show"multi threaded";
\t res2:raze proc1_wrapper peach portfolio

res1~res2 
\
/function ill suited to multi threading because ith iteration takes a short time
f:{[x]neg x}
show"TEST 2";
show"single threaded";
\t res3:f each til 10000000;
show"multi threaded";
\t res4:f peach til 10000000;

res3~res4







/


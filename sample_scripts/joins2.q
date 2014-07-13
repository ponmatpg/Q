/look at asof,wj and pj functions

\l taq.q
\c 10 150
/
/aj function - find the prevalent quote as of each trade
show"aj";

\ts res0:aj[`time;select from trade where date=dts@0,sym=portfolio@0;
	select from quote where date=dts[0],sym=portfolio[0]];
/show"vanilla";
/\ts res1:aj[`date`sym`time;select from trade;select from quote];

// Trick 1. Apply #g on the hard lookup cols
\ts res2:delete dt from aj[`sym`dt;update dt:date+time from trade;
	update `g#sym,dt:date+time from quote];

/\ts res2:aj[`date`sym`ex`time;trade;quote];

\w


//Trick 2. Create an index
f:{[]
	/List dates, list syms
	x:value exec distinct date,distinct sym from quote;
	/Produce all possible date/sym combinations
        /Then assign an int to each combination as a dict
	y:z!til count z:x[0] cross x[1];
	/create a col with the index corresponding to a row's date-sym combination
	update l:y[flip(date;sym)] from `quote;
	update l:y[flip(date;sym)] from `trade;
	/yyy;
	update `g#l from `quote;
	};

show"COMPOSITE COLUMN";	
\ts f[]	
\w
show"query";
\ts res2:aj[`l`time;trade;quote];

delete l from `trade;
delete l from `quote;

// How to use aj but for the first quote after the trade instead of last quote before the trade
/grab the next quote after the trade, not the last quote before the trade
/we achive this by shifting the quotes to the left by 1 space prior to the join
quote1:update next ask,next bid,next asize,next bsize,ntime:next time 
	by date,sym from quote

/res3:aj[`date`sym`time;trade;quote1];

// The equivalent using uj
/show"alternative soluion to the aj using uj function";
func1:{[]
	u:uj[trade;quote];
	u:`date`time xasc u;
	/yyy;
	u:update fills bid,fills bsize,fills ask,fills asize by date,sym from u;
	/u;
	res:delete from u where null price;
	res
	};
show"uj solution";	
\ts res4:func1[];	
show res1~res4;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// PLus join
/pj
show"pj";
source:([]a:1 2 3;b:`x`y`z;c:10 20 30)
lookup:([a:1 3;b:`x`z]c:1 2;d:10 20)
res9:pj[source;lookup];

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// WINDOW JOIN
/wj
show"wj";
/the wj function will return the prevalent quote as of the start of the window as well as all quotes within the window
/So that only those quotes for a given symbol are counted, make sure that the quotes are `sym`time xasc

t:([]sym:`ibm`msft`ibm`msft`msft;
	time:10:01:01 10:01:05 10:01:08 10:01:09 10:01:10; // TYpe: second
	price:100 101 105 106 107);	

// To keep the trade time as time will be overwritten by the look up table values	
update ttime:time from `t;	
	
q:([]sym:`msft`msft`ibm`ibm`msft`ibm`msft`ibm`ibm;
	time:10:01:01 + til 9;
	ask:101 102 103 104 105 106 107 108 109;
	bid:101 102 103 104 105 106 107 108 109);

// INterval is 2 seconds before, 2 seconds after
// Must specify actual times
w:+\:[(-2 2);t[`time]];

//The table must be sorted on the lookup columns or the aj will return nonsense
`sym`time xasc `q
// Note that the wj will grab:
//   the stuff in the window
//   the stuff prevailing value as of the start of the window
res:wj[w;`sym`time;t;(q;({x};`time);({x};`ask))]; // Note that the agreg functions must be monadic

// Note that the wj1 will grab:
//   the stuff in the window excluding upper bound of the window
//   NOT the stuff prevailing value as of the start of the window
res0:wj1[w;`sym`time;t;(q;({x};`time);({x};`ask))];

w1:(-60000 60000)+\:trade.time;
/\t res1:wj[w1;`sym`time;trade;(`sym`time xasc quote;({x};`time);({x};`ask))];
\t res1:wj[w1;`sym`time;trade;(`sym`time xasc quote;(max;`bid);(min;`bid))];

res2:`date`time`sym`price`size`ex`MAX`MIN xcol res1





/
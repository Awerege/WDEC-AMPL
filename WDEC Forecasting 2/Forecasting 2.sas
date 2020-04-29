proc import datafile =
"/folders/myfolders/Forecasting 2/set1.xlsx" out = WORK.set1 DBMS=XLSX;
run;
proc import datafile =
"/folders/myfolders/Forecasting 2/set2.xlsx" out = WORK.set2 DBMS=XLSX;
run;
proc import datafile =
"/folders/myfolders/Forecasting 2/set3.xlsx" out = WORK.set3 DBMS=XLSX;
run;
proc means data = set1 mean min max std;
title "Set 1";
var u;
run;

proc means data = set2 mean min max std;
title "Set 2";
var u;
run;

proc means data = set3 mean min max std;
title "Set 3";
var passengers;
run;

proc sgplot data = set1;
	title "Set 1";
	series x=i y=u;
	run;
	
proc sgplot data = set2;
	title "Set 2";
	series x=i y=u;
	run;
	
proc sgplot data = set3;
	title "Set 3";
	series x=month y=passengers;
	run;
	
/* Set 1 */	
title "Set 1";
proc arima data=set1;
identify var=u(1) scan;
estimate p=2 q=3;
run;
forecast lead=12 id=i out=results1;
quit;

/* Set 2 */
title "Set 2";
proc arima data=set2;
identify var=u scan;
estimate p=3 q=2;
run;
forecast lead=12 id=i out=results2;
quit;


/* Set 3 */
title "Set 3";
proc arima data=set3;
identify var=passengers(1, 12) scan;
estimate p=2 q=3;
run;
forecast lead=12 id=month out=results3;
quit;

data Results1;
	set Results1;
	MSE = residual*residual;
run;

proc means data = results1 mean;
	title "Set 1";
	var MSE;
run;

data Results2;
	set Results2;
	MSE = residual*residual;
run;

proc means data = results2 mean;
	title "Set 2";
	var MSE;
run;

data Results3;
	set Results3;
	MSE = residual*residual;
run;

proc means data = results3 mean;
	title "Set 3";
	var MSE;
run;

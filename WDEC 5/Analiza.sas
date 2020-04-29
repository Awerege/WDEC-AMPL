/* create library */
libname LIB5 "/folders/myfolders/Analiza";

/* import txt file - option 1 */
proc import datafile="/folders/myfolders/Analiza/t_dane_2.txt" 
		out=LIB5.t_dane_lib5;
	delimiter=";";
	getnames=NO;
run;

/* import txt file - option 2 */
data LIB5.t_dane_lib5_2;
	infile "/folders/myfolders/Analiza/t_dane_2.txt" dlm=";";
	input VAR1 VAR2 $ VAR3 VAR4 VAR5;
run;

/* histogram VAR3 */
proc univariate data=LIB5.t_dane_lib5;
	var VAR3;
	histogram;
run;

/* VAR5 ~ VAR1 */
proc sgplot data=LIB5.t_dane_lib5;
	/*plot*/
	scatter x=VAR1 y=VAR5;
run;

/* proc means for VAR5 */
proc means data=LIB5.t_dane_lib5 N NMISS MAX MIN MEAN;
	var VAR5;
run;

/* proc means for classified data (using class) */
proc means data=LIB5.t_dane_lib5 N NMISS MAX MIN MEAN;
	var VAR5;
	class VAR2;
run;

/* proc means for classified data (using by) */
proc sort data=LIB5.t_dane_lib5 out=LIB5.t_dane_lib5_mean;
	by VAR2;
run;

proc means data=LIB5.t_dane_lib5_mean N NMISS MAX MIN MEAN;
	by VAR2;
	var VAR5;
run;

/* proc reg for even ids */
proc reg data=LIB5.t_dane_lib5;
	model VAR5=VAR1;
	where (VAR2="s4_parz");
	run;

	/* a = 40.97727, b = 14.86533 */
	/* Task 8. */
data LIB5.reg;
	set LIB5.t_dane_lib5;
	ye=40.97727+ 14.86533 * VAR1;
	where (VAR2="s4_niep");
run;

/* Task 9. */
proc sgplot data=LIB5.reg (obs=10);
	/*plot*/
	scatter x=VAR1 y=ye;
run;

proc sgplot data=LIB5.reg (obs=10);
	scatter x=VAR1 y=VAR5;
run;

proc sgplot data=LIB5.reg (obs=100);
	/*plot*/
	scatter x=VAR1 y=ye;
run;

proc sgplot data=LIB5.reg (obs=100);
	scatter x=VAR1 y=VAR5;
run;

proc sgplot data=LIB5.reg;
	/*plot*/
	scatter x=VAR1 y=ye;
run;

proc sgplot data=LIB5.reg;
	scatter x=VAR1 y=VAR5;
run;
LIBNAME lab9 "/folders/myfolders/Hipotezy";
data new;
set '/folders/myfolders/Hipotezy/ads.sas7bdat';
run;
proc print data =Work.new (obs=10);
run;
data new1;
set '/folders/myfolders/Hipotezy/ads1.sas7bdat';
run;
proc print data =Work.new1 (obs=10);
run;

PROC Sort data=Work.new;
BY Ad;
run;
PROC MEANS data=Work.new N MAX MIN NMISS MEAN;
by Ad;
run;
PROC Sort data=Work.new1;
BY Ad;
run;
PROC MEANS data=Work.new1 N MAX MIN NMISS MEAN;
by Ad;
run;
PROC Sort data=Work.new1;
BY Area;
run;
PROC MEANS data=Work.new1 N MAX MIN NMISS MEAN;
by Area;
run;

title 'Statystyki sprzeda�y dla poszczeg�lnych typ�w reklamy';
proc sgplot data = Work.new;
vbox Sales/category=Ad;
xaxis display=(nolabel);
run;

proc glm data= Work.new;
class Ad;
model Sales=Ad/solution;

proc glm data= Work.new1;
class Ad Area;
model Sales=Ad Area;

/*LIBNAME Lab11 "/folders/myfolders/Laba11";*/


PROC Sort data=lab9.Ads;
BY Sales;
run;

PROC MEANS data=lab9.Ads N MEAN;
run;


data lab9.SST;
        set lab9.Ads;
        odchyl=Sales-66.8194444;
        output;
run;

data lab9.SST2;
        set lab9.SST;
        kwad=odchyl**2;
        output;
run;

proc means data=lab9.SST2 sum;
        var kwad;
run;

/* SST = 26169.31 */

PROC Sort data=lab9.Ads1;
BY Sales;
run;

PROC MEANS data=lab9.Ads1 N MAX MIN NMISS MEAN;
run;

proc sort data=lab9.Ads1;
        by Ad;
run;

proc means data=lab9.Ads1 mean;
        class Ad;
        output out=lab9.SSM mean=sr;
run;

data lab9.SSM (drop=_type_);
        set lab9.SSM;
        if _n_ < 2 then
                delete;
run;

data lab9.SSM2;
        set lab9.SSM;
        odchyl=sr-66.8194444;
        output;
run;

data lab9.SSM3;
        set lab9.SSM2;
        kwad = odchyl**2 * _FREQ_;
        output;
run;

proc means data=lab9.SSM3 sum;
        var kwad;
run;

/* SSM = 5866.08 */

data lab9.SSE;
        set lab9.Ads1;
        if ad = 'display' then
                odchyl=sales-56.5555556;
        else if ad = 'paper' then
                odchyl=sales-73.2222222;
        else if ad = 'people' then
                odchyl=sales-66.6111111;
        else if ad = 'radio' then
                odchyl=sales-70.8888889;
        output;
run;

data lab9.SSE2;
        set lab9.SSE;
        kwad = odchyl**2;
        output;
run;

proc means data=lab9.SSE2 sum;
        var kwad;
run;

/* SSE = 20303.22 */

/*Advanced Business Analytics - Power od Predictive Modeling 226161-0131*/

/*RETENTION MODELS*/

/*EXAMPLE 3*/
/*Data for the geometric distribution*/
Title "Geometric distribution";
data geo;
t=0; p=0;  St=1;   output;
t=1; p=.2; St=1-p; output;
do t=2 to 25;
   p=p*.8;
   St=St-p;
   output;
end;
run;


/*Plotting the probability function*/
proc sgplot data=geo;
step X=t Y=p;
xaxis label="Cancelation Time (t)";
yaxis label="Probability P(T=t)";
run;


/*Plotting the survival function*/
proc sgplot data=geo;
step X=t Y=St;
xaxis label="Cancelation Time (t)";
yaxis label="Survival Function S(t)";
run;


/*EXAMPLE 4*/
/*Data for the impact of changing retention rates on CLV*/
Title "Retention rate change impact";
data clv;
do r=.7 to .98 by .01;
   Et=1/(1-r);
   Eclv=25*1.01/(1.01-r);
   output;
end;
format clv DOLLAR8.2
       r PERCENT5.0 Et 5.2;
label Et="E(T)"
      Eclv="E(CLV)";
run;


/*Expected T and CLV*/
proc print data=clv noobs label;
var r Et Eclv;
where MOD(100*r,5)=0 or r=.98;
run;


/*Plotting the relation between retention rate and CLV*/
proc sgplot data=clv;
series X=r Y=Eclv;
xaxis label="Retention Rate (r)";
run;


/*EXAMPLE 5*/
/*Creating dataset*/
data service1yr;
input bigT cancel count @@;
label bigT="Czas odejscia (T)"
      cancel="Etykieta 1=odszedl, 0=ocenzurowany";
datalines;
2 1 4      3 1 16      4 1 20      5 1 37      6 1 28     7 1 61      8 1 24     9 1 19
10 1 13    11 1 10     12 1 13     1 0 3       3 0 2      4 0 1       5 0 7      6 0 33
7 0 49     8 0 63      9 0 30      10 0 16     11 0 34    12 0 188
run;


/*Estimating descriptive statistics*/
proc means data=service1yr sum maxdec=0;
var cancel bigT;
weight count;
output out=answer sum=;
run;


/*Estimating retention rate*/
proc sql;
select cancels LABEL="Number Cancels",
       flips LABEL="Opportunities to Cancel",
       Rhat LABEL="Retention Rate (r)" FORMAT=6.4,
       1/(1-Rhat) as ET LABEL="E(T)" FORMAT=5.1,
       1+LOG(.5)/LOG(Rhat) as median LABEL="Median(T)" FORMAT=3.0
from (select sum(cancel) as cancels,
      sum(bigT) as flips,
      1-sum(cancel)/sum(bigT) as Rhat
      from answer);
quit;


/*EXAMPLE 7*/
/*Defining SAS data library*/
libname reten '/folders/myfolders/exam/some_exercises/2.Retention_models/Data';


/*Estimation with life table method*/
proc lifetest data=reten.service5yr method=lt intervals=0 to 60 by 1 outsurv=out1 plots=(s,h,p);
time bigT*cancel(0);
freq count;
run;


/*Estimation with Kaplan-Meier method*/
proc lifetest data=reten.service5yr outsurv=out2;
time bigT*cancel(0);
freq count;
run;

/*Comparing estimates from SRM and GRM*/
data res;
set out2;
by bigT;
if bigT>0 and FIRST.bigT;
rhat=1-44367/1073935;
clv=survival*23.20/(1.01**(bigT-1));
survSRM=(rhat)**(bigT-1);
clvSRM=23.20*(rhat/1.01)**(bigT-1);
run;

proc print data=res noobs;
var bigT survival survSRM clv clvSRM;
sum clv clvSRM;
format clv clvSRM DOLLAR8.2;
run;


/*EXAMPLE 8*/
/*Estimating Kaplan-Meier model with stratification*/
proc lifetest data=reten.service5yr outsurv=out3;
strata startlen;
time bigT*cancel(0);
freq count;
run;


/*Comparing estimates in strata*/
data res2;
set out3;
by startlen bigT;
if bigT>0 AND first.bigT;
clv = survival*23.20/(1.01**(bigT-1));
run;

proc print data=res2 noobs;
by startlen;
var bigT survival clv;
sum clv;
format clv dollar8.2;
run;

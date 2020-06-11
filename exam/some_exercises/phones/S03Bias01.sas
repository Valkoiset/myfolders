/* MISSING DATA AS SOURCE OF BIAS - INCOME EXAMPLE */
/* slide #79 in ABA_PPM_AK_2020.pdf */
/* original code here: http://web.sgh.waw.pl/~akorczy/files/abappm/code/S03Bias01.sas */

libname d "/folders/myfolders/exam/exercises/phones";

/* proc print data=d.phones; */
/* run; */

*# Setup seed for random number generating;
%let seed=2018;

*# Setup format for missing values on income;
proc format;
value incfmt
0-high=[DOLLAR20.2]
-98="Don't know"
-99="Refused"
;
value incorigfmt
1	="Less than $10,000"
2	="$10,000 to under $20,000"
3	="$20,000 to under $30,000"
4	="$30,000 to under $40,000"
5	="$40,000 to under $50,000"
6	="$50,000 to under $75,000"
7	="$75,000 to under $100,000"
8	="$100,000 to under $150,000"
9	="$150,000 or more"
98	="Don’t know"
99	="Refused"
;
run;

*# Draw values from income ranges to get continuous measurments;
data b01;
 format incN incfmt. inc incorigfmt.;
 set d.phones;
	r=ranuni(&seed.);
	if inc=1 then IncN=r*10000;
	else if inc=2 then IncN=10000+r*10000;
	else if inc=3 then IncN=20000+r*10000;
	else if inc=4 then IncN=30000+r*10000;
	else if inc=5 then IncN=40000+r*10000;
	else if inc=6 then IncN=50000+r*25000;
	else if inc=7 then IncN=75000+r*25000;
	else if inc=8 then IncN=100000+r*50000;
	else if inc=9 then IncN=150000+r*50000;
	else if inc=98 then IncN=-98;
	else if inc=99 then IncN=-99;
run;

*# Subset of non-missing income and sort by income value;
proc sort data=b01(where=(IncN ^in (-98 -99))) out=b02;
 by incN;
run;

*# Create index;
data b03;
 set b02;
	id+1;
run;

*# Plot distribution;
ods listing gpath="&gpath" style=MyStyleDefault;
ods graphics on / reset=all imagefmt=pdf border=off imagename="S03IncomeContDistribution01" height=1000px width=1200px;
title1 j=l font=arial height=16pt "Income distribution";
proc sgplot data=b03;
 histogram IncN;
run;
title1;

*# Estimating mean income;
proc means data=b03 n mean stderr lclm uclm std min q1 median q3 max maxdec=1;
 var IncN;
 output out=stats0 mean=mean lclm=lclm uclm=uclm;
run;
proc surveyselect data=b03 out=b04 seed=&seed n=1000 method=srs noprint; 
 *where id>300;
	*where id<1500;
	*where id>200 and id<1600;
run;
proc means data=b04 n mean stderr lclm uclm std min q1 median q3 max maxdec=1;
 var IncN;
	output out=stats1 mean=mean lclm=lclm uclm=uclm;
run;

data stats01;
 set stats0 (in=a) stats1 (in=b);
	select;
  when (a) c="1:Population";
		when (b) c="2:Sample";
	end;
run;

ods listing gpath="&gpath" style=MyStyleDefault;
ods graphics on / reset=all imagefmt=pdf border=off imagename="S03MeanIncome01" height=250px width=1200px;
title1 j=l font=arial height=16pt "Estimate of the mean income";
proc sgplot data=stats01;
	scatter y=c x=mean / xerrorlower=lclm xerrorupper=uclm;
	yaxis label=" ";
	xaxis label="Mean of the income";
run;

*# Distribution of original income values;
ods noproctitle;
options nodate nonumber noproctitle;
ods pdf file="&gpath\S03IncomeDistribution01.pdf" style=journal2;
proc freq data=b01;
 tables inc / out=f01;
run;
ods pdf close;
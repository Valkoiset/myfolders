/* imputation methods:
   MCMC (Marcov Chain Monte Carlo)
   FCS (Fully Conditional Specification) - good for monotone pattern, matrix sampling */

filename bank '/folders/myfolders/rain.csv';

proc import datafile=bank
  dbms=csv
  out=work.rain;
  GETNAMES=YES;
run;

data rain_orig;
	set work.rain;
	drop var1;
	retain id 0;
	id=id+1; /* key for comparing results*/
run;

/*Generating empty cases*/
data rain_miss;
	set rain_orig;
	call streaminit(12345);
	Missing1=rand("Bernoulli",0.2); /*missing variable is 1  40% of the time*/
	Missing2=rand("Bernoulli",0.3); /*missing variable is 1  40% of the time*/
	if Missing1 then do; 
		Humidity9am=.;
		Humidity3pm=.;
	END;
	if Missing2 then do;  
		Pressure9am=.;
		Pressure3pm=.;
	END;
run;	



/* -------------------------------------------------- */
/* Exploratory analysis */
	proc mi nimpute=0 simple data=rain_miss;
	run;

/* proc contents data=work.bank; run; */

/* proc mi nimpute=0 data=work.bank; */
/* run; */

proc means data=work.bank;
	var duration balance;
run;

/* *MCMC; */
proc mi data=RealEstateMiss out=im02 nimpute=100 seed=2020;
	var X2_HouseAge X3_DistanceFromSub X4_DistanceFromStore X5_Latitude X6_Longitude y1;
	mcmc chain=multiple displayinit initial=em(itprint);
run;























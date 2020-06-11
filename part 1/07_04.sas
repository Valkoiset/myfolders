LIBNAME Mylib '/folders/myfolders/';

/* proc contents data=MyLib.RealEstateMiss; */
/* run; */
/*  */
/* proc mi data=MyLib.RealEstateMiss(drop=y2 m2) nimpute=0; */
/* run; */
/*  */
/* proc mi data=MyLib.RealEstateMiss out=im01 nimpute=25 seed=2020; */
/*  var X2_HouseAge X3_DistanceFromSub  */
/* X4_DistanceFromStore y1; */
/* monotone reg(y1 = X2_HouseAge X3_DistanceFromSub X4_DistanceFromStore); */
/* run; */

/* *MCMC; */
/* proc mi data=RealEstateMiss out=im02 nimpute=100 seed=2020; */
/*  var X2_HouseAge X3_DistanceFromSub X4_DistanceFromStore X5_Latitude X6_Longitude y1; */
/*  mcmc chain=multiple displayinit initial=em(itprint); */
/* run; */
/*  */
/* *FCS; */
/* proc mi data=RealEstateMiss out=im03 nimpute=100 seed=2020; */
/*  var X2_HouseAge X3_DistanceFromSub X4_DistanceFromStore X5_Latitude X6_Longitude y1; */
/* fcs reg(y1 = X2_HouseAge X3_DistanceFromSub X4_DistanceFromStore X5_Latitude X6_Longitude); */
/* run; */

*Linear regression model;
*Complete-cases;
/* proc reg data=RealEstateMiss; */
/*    model y1 = X2_HouseAge X3_DistanceFromSub X4_DistanceFromStore; */
/* run; */

*Multiple-imputation;
proc reg data=im01 outest=outreg covout noprint;
   model y1 = X2_HouseAge X3_DistanceFromSub X4_DistanceFromStore;
   by _Imputation_;
run;

proc mianalyze data=outreg;
   modeleffects Intercept X2_HouseAge X3_DistanceFromSub X4_DistanceFromStore;
run;

data b01;
	set MyLib.beeps2009;
	*#Replace "-9" for missing;
	array m{*} b5 n2a d2;
	array n{*} b5_ n2a_ d2_;
	 do i=1 to dim(m);
   if m{i}=-9 then n{i}=.;
			else n{i}=m{i};
		end;
	age=(a14y-b5);
	if d2_>0 then lnSales=log(d2_);
	if n2a_>0 then lnCost=log(n2a_);
	mAge=missing(age);
	mlnSales=missing(lnSales);
	mlnCost=missing(lnCost);
	mis=nmiss(LnSales,lnCost)>0;
	where Country in 
	('Czech Republic','Estonia','Hungary','Latvia','Lithuania','Poland','Slovak Republic') and b5^=-9 and j3^=-9;
	label b5="Year of Fundation" N2a="Total cost of labour in 2007" D2="Total annual sales in last fiscal year" j3="Tax inspection in last 12 months";
run;

data b02;
 set b01;
	keep mis mlnSales mlnCost lnSales lnCost;
	where nmiss(lnSales,lnCost)<2;
run;

proc sort data=b02;
 by mlnSales mlnCost;
run;

*#EM estimates of the mean vector and covariance matrix 
for multivariate normal population;
proc mi data=Mylib.realestatemiss nimpute=25;
	var X2_HouseAge X3_DistanceFromSub X4_DistanceFromStore y1;
 	em initial=ac out=out /*Ey*/ outem=em/*Cov*/ outiter=iter itprint converge=0.0001;
run;

/* proc mi data=MyLib.beeps2009 out=im01 nimpute=25 seed=2020; */
/*  var X2_HouseAge X3_DistanceFromSub  */
/* X4_DistanceFromStore y1; */
/* monotone reg(y1 = X2_HouseAge X3_DistanceFromSub X4_DistanceFromStore); */
/* run; */



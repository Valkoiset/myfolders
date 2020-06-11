libname mydata "/folders/myfolders/exam/churn";

data churn;
	set mydata.churn_dataset;
run;

/* proc print data=churn; */
/* run; */

/*Estimation with Kaplan-Meier method*/ 
proc lifetest data=churn outsurv=out1; 
	time account_length*churn(0); 
run; 

/*Estimating Kaplan-Meier model with stratification*/ 
proc lifetest data=churn outsurv=out2; 
	strata international_plan; 
	time account_length*churn(0); 
/* 	freq count; */
run; 

/*CLV estimation*/ 
data res2; 
	set out2; 
	by account_length; 
	if account_length>0 AND first.account_length; 
		clv = survival*30/(1.01**(account_length-1));  
run; 
 
proc print data=res2 noobs; 
	var account_length survival clv; 
	sum clv; 
	format clv dollar8.2; 
run; 
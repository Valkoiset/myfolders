/* /folders/myfolders/exam/model performance */
/* originial code here: http://web.sgh.waw.pl/~akorczy/files/abappm/code/S01GermanCredit.sas*/

libname mydata "/folders/myfolders/exam/model performance";

/* proc print data=mydata.german; */
/* run; */

data german01;
 set german;
	id+1;
run;
proc sort data=german01 out=german02;
	by default;
run;
%macro Score;
%do i=1 %to 10;
	proc surveyselect data=german02 out=german03 method=srs n=800 seed=%eval(2018+&i.);
		strata default / alloc=proportional;
	run;
	proc sql;
		create table test01 as select * from german02 where id not in 
		(select id from german03);
	quit;

	proc logistic data=german03 outmodel=mod01;
		class housing (param=ref ref='own');
		model default(event='1')= housing age / aggregate scale=none rsquare ctable;
		output out=out predprobs=(i);
		score outroc=outc01 fitstat; *Roc curve and fit statistics;
		ods output ScoreFitStat=s01;
	run;
	*Fit the model on the test data and output fit statistics;
	proc logistic inmodel=mod01;
	 score data=test01 out=Score01 fitstat; 
		ods output ScoreFitStat=s&i.;
	run;
%end;
data s;
	set s1-s10;
run;
%Mend score;
%Score;









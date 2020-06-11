/*Advanced Business Analytics - Power od Predictive Modeling 226161-0131*/

/*MIGRATION MODEL*/

/*EXAMPLE 4*/
/*Buy, no-buy model results using matrix approach*/
Title "Buy, no-buy matrix approach";
proc iml;
v = {19, -1};
n = {1000, 0};
P = {0.2 0.8,
     0.1 0.9};
P2 = P*P;
P3 = P2*P;
clv = inv(I(2) - P/1.1) * v;
ce = n` * clv;
print v n P P2, P3 clv ce;



/*EXAMPLE 5*/
/*Defining SAS data library*/
libname mig 'C:/Dane';


/*Computing each customer's recency as of today and whether the customer donated during the next yesr*/
Title "Calculation of recency and targbuy ";
data rollup;
set mig.trans;
by id;
length targbuy targdol recency freq 4;
retain targbuy targdol recency freq;
if first.id then do;
    targbuy = 0;
    targdol = 0;
    freq = 0;
    recency = 9999;
end;
diff = ("31AUG2005"d - giftdate)/365.25;
if diff < 0 then do;
    targbuy = 1;
    targdol = sum(amt, targdol);
end;
else do; 
if diff < recency then recency = diff;
freq = freq + 1;
end;
if last.id then output;
keep id targbuy targdol recency freq;
run;


/*The crosstab of recency and targbuy - probabilities estimate the transition matrix P*/
Title "Table of recency by targbuy";
proc format;
value recbin
0 - <1 = "r<1 yr"
1 - <2 = "1<=r<2"
2 - <3 = "2<=r<3"
3 - hight = "r>=3";
run;
proc freq data = rollup;
table recency * targbuy / nocol nopercent;
format recency recbin.;
run;


/*Descriptive statistics for tagdol variable - mean value is necessary for value vecor*/
proc means data = rollup maxdec = 2;
var targdol;
where targbuy = 1;
run;


/*Re-running above program for finding the inital vector n - change in date from 31AUG2005 to 31AUG2006*/
data rollup_new;
set mig.trans;
by id;
length targbuy targdol recency freq 4;
retain targbuy targdol recency freq;
if first.id then do;
    targbuy = 0;
    targdol = 0;
    freq = 0;
    recency = 9999;
end;
diff = ("31AUG2006"d - giftdate)/365.25;
if diff < 0 then do;
    targbuy = 1;
    targdol = sum(amt, targdol);
end;
else do; 
if diff < recency then recency = diff;
freq = freq + 1;
end;
if last.id then output;
keep id targbuy targdol recency freq;
run;
Title "Table of recency by targbuy";
proc format;
value recbin
0 - <1 = "r<1 yr"
1 - <2 = "1<=r<2"
2 - <3 = "2<=r<3"
3 - hight = "r>=3";
run;
proc freq data = rollup_new;
table recency * targbuy / nocol nopercent;
format recency recbin.;
run;


/*Predicting customer equity in two years*/
proc iml;
n = {3886, 1992, 1917, 13371};
v = {69.06, 0, 0 ,0};
P = { .5689  .4311 0 0,
      .2456  0 .7544 0,
      .0973  0 0 .9027,
      .0335  0 0 .9665};
pred = (n` * P * v) + (n` * P * P * v);
print pred;

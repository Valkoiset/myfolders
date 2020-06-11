/*Advanced Business Analytics - Power od Predictive Modeling 226161-0131*/

/*SEGEMENTATION MODELS*/

/*EXAMPLE 1*/
/*Reading the data into SAS*/
data np;
input time sections count @@;
datalines;
0 0 370    1 0 9      1 1 127    1 2 119    1 3 55     1 4 34
1 5 55     1 6 34     1 7 21     2 0 3      2 1 72     2 2 94
2 3 68     2 4 48     2 5 74     2 6 48     2 7 29     3 0 1
3 1 43     3 2 107    3 3 48     3 4 40     3 5 63     3 6 52
3 7 38     4 1 21     4 2 58     4 3 39     4 4 32     4 5 47
4 6 30     4 7 25     5 1 15     5 2 40     5 3 23     5 4 25
5 5 51     5 6 38     5 7 32     6 1 21     6 2 67     6 3 54
6 4 39     6 5 90     6 6 59     6 7 71     7 1 15     7 2 47
7 3 31     7 4 51     7 5 103    7 6 67     7 7 96
run;



/*Creating a kernel density plot of the crosstab*/
/*Kernel density plot is like a two-dimensional histogram, showing joint distribution of time and sections 
by representing areas with higher probabilities with darker shades of red and areas with lower probabilities
in blue.*/
Title "Kernel Density for time and sections";
data rootnp;
set np;
rootcount=sqrt(count);
run;
proc kde data=rootnp;
bivar time sections / plots=contour bwm=0.8;
freq rootcount;
run;



/*Creating a jittered scatter plot*/
/*Jittering adds a small amount of uniform random noise to the values with the RANUNI function. Without jittering we would see
one point for each combination of time and sections. Darker shades indicates larger counts.*/
Title "Scatter plot with uniform random noise";
data npjitter;
set np;
  do i=1 to count;
	time_noise=time+ranuni(1234)/2-1;
	sections_noise=sections+ranuni(1234)/2-1;
	output;
  end;
label time_noise="time with noise"
	  sections_noise="sections with noise";
keep time_noise sections_noise;
run;
proc sgplot data=npjitter;
scatter x=time_noise
		y=sections_noise / markerattrs=graphdata2 (symbol=circlefilled) transparency=.9;
run;



/*Creating a bubble plot*/
Title "Bubble plot of the newspaper data";
proc sgplot data=np;
bubble x=time y=sections size=count / datalabel=count;
run;



/*EXAMPLE 2*/
/*K-means example*/
proc fastclus data=np maxc=5 converge=0 drift;
var time sections;
freq count;
run;



/*EXAMPLE 3*/
/*Defining macro named multseed with number of starting seeds as argument. It finds multiple cluster solutions with 
different starting seeds*/
Title "Multseed macro for finding multiple cluster solutions with different starting seeds";
%macro multseed(n);
%do i = 1 %to &n;
proc surveyselect data=np out=seeds n=5
seed=&i noprint;
run;

proc fastclus data=np maxc=5 converge=0
drift seeds=seeds outstat=out least=2
noprint mean=meanout;
var time sections;
freq count;
run;

data out;
set out (where=(_type_="WITHIN_STD"));
seed=&i;
run;

data ans;
set out
%if &i>1 %then %do; 
ans
%end;
;
keep seed over_all time sections;
run;
%end;
%mend;



/*Executing macro multseed with the argument value n=100*/
%multseed(100);



/*Comparative analysis of results from 100 clustering models with different initial seeds*/
proc univariate data=ans plot;
var OVER_ALL;
id seed;
run;



/*Bulding histogram of the RMSE values from 100 different K-means solutions using different random seeds*/
Title "Distribution of RMSE";
proc sgplot data=ans;
histogram over_all / scale=count binwidth=.01;
xaxis display=(nolabel);
run;



/*Bulding scatter plot of estimated cluster centers from 100 different K-means solutions using different random seeds*/
Title "Estimated cluster centers of 100 different K-means solutions";
proc sgplot data=ans;
scatter x=time y=sections;
run;



/*Best K-means solution to newspaper example (out of 100 seeds)*/ 
Title "Best solution out of 100 seeds";
proc surveyselect data=np out=seeds n=5 seed=53;
run;
proc fastclus data=np maxc=5 converge=0 drift seed=seeds
outstat=out least=2 mean=meanout out=asgn;
var time sections;
freq count;
run;



/*Creating plot showing the best means and cluster assignments for the newspaper example*/
Title "Plot with the best means and cluster assignments";
data clusout;
set asgn meanout (keep=time sections);
length clus $6.;
if cluster=. then clus="Center";
else clus=put(cluster, $1.);
label clus="Cluster";
run;
data myanno;
drawspace='datavalue'; function='line';
x1=-.1; y1=3.5; x2=4.5; y2=3.5; output;
x1=4.5; y1=4.5; x2=7.1; y2=4.5; output;
run;
proc sgplot data=clusout sganno=myanno;
scatter x=time y=sections / group=clus;
refline 4.5 / axis=x;
lineparm x=2.5 y=0 slope=-1;
run;



/*For the interested (not obligatory)*/
/*Macro for running multiple cluster solutions and generating a multi-panel display of the cluster means*/
Title "The doclus macro";
%macro doclus(dat, varlist, first, last);
%do numclus=&first %to &last;
proc fastclus data=&dat maxiter=100
converge=0 drift maxc=&numclus
out=clusout&numclus;
run;
proc freq data=clusout&numclus;
tables cluster;
run;
data _long;
set clusout&numclus;
length varname $8;
%let i=1;
%let varname=%scan(&varlist, &i);
%do %while(%length(&varname)>0);
varname="&varname";
x=&varname;
output;
keep cluster varname x;
%let i=%eval(&i+1);
%let varname=%scan(&varlist, &i);
%end;
run;
proc sgpanel data=_long;
panelby cluster / layout=columnlattice;
dot varname / response=x stat=mean;
refline 0 / axis=x;
rowaxis display=(nolabel);
run;
%end; 
%mend;



/*EXAMPLE 4*/
/*Defining data library*/
libname segm '/folders/myfolders/exam/some_exercises/1.Segmentation_models/Data';



/*Importing data from .csv file*/
proc import datafile='/folders/myfolders/exam/some_exercises/1.Segmentation_models/Data/theater.csv'
out=segm.theater dbms=csv replace; 
getnames=yes; 
run;



/*Standarization of data and building models with one, two and three clusters*/
Title "Segmentation - Theater Example";
%let clusvar=attitude planning parents goodval getto;
proc standard data=segm.theater out=Ztheater mean=0 std=1;
var &clusvar;
run;
%doclus(Ztheater, &clusvar, 1, 3);

/*SYNTAX:
!!! Remember to run the macro program definition before using it
*/



/*Creating a box plot for each model*/
Title "Box plot of the clusters for the Theater example";
proc sgpanel data=_long;
panelby cluster;
hbox x / category=varname;
refline 0 / axis=x;
rowaxis display=(nolabel);
run;



/*Creating scatter plot for PCA (principal components analysis)*/
Title "Scatter plot of three-cluster solution using the first two principal components";
proc princomp data=clusout3 out=pcout n=2;
var &clusvar;
run;
proc sgplot data=pcout;
scatter x=prin1 y=prin2 / group=cluster;
run;

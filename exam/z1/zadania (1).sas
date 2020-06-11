***POWT�RZENIE PRZED EGZAMINEM Z ZAB (LUTY 2019);
*ENCODING - WLATIN2;

*Przypisz bibliotek�;
libname zab "D:\OneDrive - Szko�a G��wna Handlowa w Warszawie\Szko�a G��wna Handlowa\III Semestr\Zaawansowana analityka biznesowa - si�a modeli biznesowych";

*Zadanie 1;
proc standard data = zab.z01 mean = 0 std = 1 out = z1 (where = (val gt 3 or val lt -3));
run;
*Odp: S� 3 obserwacje odstaj�ce.;

*Zadanie 2;
proc mi data = zab.drapersmithm (drop = id) seed = 2019;
	mcmc;
run;
*Odp a: wzorzec brak�w danych jest monotoniczny [results: missing data patterns, por. slajd 83];
*Odp b: wykonano 200 iteracji wst�pnych [results: number of burn-in iterations];
*Odp c: �rednia zmiennej x2 po impuitacji wynosi 50 [results:parameter estimates:mean dla variable:x2];
*Odp d: nie ma podstaw do odrzucenia hipotezy 0 [warto�� 49 mie�ci si� mi�dzy results:parameter estimates:95% confidence limits dla variable:x2];
*Odp e: patrz Vb (between-imputation variance) np. tu:
	  	https://pfp.ukw.edu.pl/page/pl/archive/article-full/374/prokopek_wybrane_statystyczne_metody/;
*Odp f: dla zmiennej x2 zr�nicowanie oszacowa� po�rednich jest najmniejsze [results:variance information:variance:within (chyba, raczej nie between) dla variable:x2];

*Zadanie 3;
proc mi data = zab.drapersmithm (drop = id) seed = 2019;
	mcmc;
	em outem = estimates itprint;
run;

proc reg data = estimates(type = cov);
	model x5 = x1 x2 x3 x4;
run;

*Odp a: [kiedy algorytm osi�ga zbie�no�c to nie ma kolejnych iteracji, dlatego patrzymy na ostatni� warto�� results: EM (MLE) iteration history
		 np. iteracja = 175, -2log(L) = 173.957, wi�c log(L) = - 86.9785.;
*Odp b: �rednia: 6.7, wariancja: 21.8 [results:EM (MLE) parameter estimates:mean dla variable:x1 oraz results:EM (MLE) parameter estimates:macierz kowariancji:cov(x1,x1) = var(x1)];
*Odp c: jednostkowy wzrost zmiennej x1 spowoduje najwi�kszy wzrost zmiennej obja�nianej x5
		[results: parameter estimates:max(parameter estimate) dla variable = x1].;
*Odp d: 4.47 [results: parameter estimates:parameter estimate dla variable = x1].;
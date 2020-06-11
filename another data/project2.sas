/* Wygenerowany kod (IMPORT) */
/* Plik źródłowy: beeps_v_mena_es.xlsx */
/* Ścieżka źródłowa:/folders/myfolders/another data */
/* Kod wygenerowany dnia: 19.04.2020, 13:01 */

%web_drop_table(WORK.IMPORT);


FILENAME REFFILE '/folders/myfolders/another data/beeps_v_mena_es.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.IMPORT;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.IMPORT; RUN;


%web_open_table(WORK.IMPORT);
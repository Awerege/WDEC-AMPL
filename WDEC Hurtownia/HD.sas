/*zmienne globalne*/
%let LIBRARY_EXCEL =LAB6;
%let LIBRARY_EXCEL_DATA_WAREHOURSE =LAB6.EXCEL_DATA_WAREHOUSE; *Hurtowania danych;
%let FILE_NAME_OR_WILDCARD = *.xlsx;
%let MY_PATH = /folders/myfolders/data_warehouse;

/*
 * utowrzenie magazynu, oraz usuniecie zawartosci,
 * aby na poczatku nie bylo pustych rekordow przy starcie programu
 */

data &LIBRARY_EXCEL_DATA_WAREHOURSE;
	delete;
run;

/*
 * wywołanie procedury execute, ktora rozpoczyna dzialanie programu
 */

data testData;
	call execute('%wczytajInformacjeOPlikach');
	proc SGPLOT DATA = lab6.excel_data_warehouse;
	vbar produkt_id / group=ilosc;
	RUN;
	proc SGPLOT DATA = lab6.excel_data_warehouse;
	vbar sklep_id / group=ilosc;
	RUN;
	proc SGPLOT DATA = lab6.excel_data_warehouse;
	vbar sklep_id / group=data;
	RUN;
	proc print data=lab6.excel_data_warehouse;
	var sklep_id Ilosc;
	RUN;
run;

%macro wczytajInformacjeOPlikach;
	
	filename excelF "&MY_PATH/newData/&FILE_NAME_OR_WILDCARD"; *uchwyt do pliku;

	data test;
		length filename $ 100; *zmienna pomocnicza o określonej długosci, przechowuje sciezke pliku;
	  	infile excelF eov=eov filename=filename; *otwieranie pliku, flaga eov(1 gdy pierwszy rekord pliku);

		if _n_ = 1 or eov then do; *GetFileName only at first row;
			txt_file_name = scan(filename, -1, "/"); *ostatnie słowo;
			call symput('fname', txt_file_name); /*wywołanie procedury, aktualizacja wartosci makrozmiennej*/
			eov=0; *reset flagi;
			
			call execute('%wczytajDane('|| txt_file_name ||')');
		end;

		input @; *czyszczenie uchwytu;
	run;

	filename excelF clear; *czyszczenie/zwolnienie deskryptora;
	
%mend wczytajInformacjeOPlikach; 


/*
 wczytywanie pliku excelowego ze sciezki i dodanie 
 go do zbioru danych %dopiszDane, przechowywane w patrz zmienna globalna: LIBRARY_EXCEL_DATA_WAREHOURSE
*/

%macro wczytajDane(nazwaPliku);

	PROC IMPORT OUT= &LIBRARY_EXCEL 
				DATAFILE= "&MY_PATH/newData/&nazwaPliku" 
        		DBMS=xlsx REPLACE;
    			GETNAMES=YES;
	RUN;
	
	/* makra ktore sprawdzaja poprawnosc danych */
	%czyszczeniePustychWierszy;
	%czyNumerSklepuSieZgadza("&nazwaPliku");
	%czyDataSieZgadza("&nazwaPliku");
	%czySaPustePola;
	%czyIloscJestPoprawna;
	%czyProduktIdJestPoprawne;


	
	/* Jezeli poprawne dane to sa przenoszone do archiwum i usuwane
	   Jezeli niepoprawne dane to sa tylko usuwane */
	data &LIBRARY_EXCEL;
		set &LIBRARY_EXCEL;
		if symget('czyZwalidowane')=0 then /*makrozmienna ustawiona w makrach sprawdzajacych poprawnosc plikow*/
			do;
				call execute('%usun('||"&nazwaPliku"||')');
				putlog "[LOG] plik = &nazwaPliku nie jest poprawny - usuwanie";
				delete;
				stop;
			end;
		else
			do;
				call execute('%przenies('||"&nazwaPliku"||')');
				call execute('%usun('||"&nazwaPliku"||')');
				putlog "[LOG] plik = &nazwaPliku jest poprawny - przeniesienie do archiwum";
			end;
	run;	
	/*dane sa dopisywane do lacznego spisu*/
	%uploadData;
%mend wczytajDane;

/*
 * Kopiuje plik z katalogu /newData/ do katalogu /archive/
 */

%macro przenies(nazwaPliku);
	filename src "&MY_PATH/newData/&nazwaPliku";
	filename dst "&MY_PATH/archive/&nazwaPliku";
 
	data _null_;
		length msg $ 384;
		rc=fcopy('src', 'dst');
		if rc=0 then
			put ' Plik zostal powielony w newData';
		else 
			do;	
				msg=sysmsg(); * przechwytuje komunikaty, bledy dot. problemow z systemem plikow, nadpis, uprawnienia etc.;
      			put rc= msg=;
   			end;
	run;
	filename src clear;
	filename dst clear;
%mend przenies;

/*
 * Eksterminacja pliku o podanej nazwie w katalogu /newData/
 */

%macro usun(nazwaPliku);
	data _NULL_;
		putlog "usuniecie pliku &nazwaPliku";
		fname = "tempfile";
		path="&MY_PATH/newData/&nazwaPliku";
		rct=FILENAME(fname, path);
		rc=FDELETE(fname);
	run;
%mend usun;

/*
 * Dopisuje dane we wczesniejszych iteracjach makra wczytajDane
*/

%macro uploadData;
	data &LIBRARY_EXCEL_DATA_WAREHOURSE;
		set &LIBRARY_EXCEL_DATA_WAREHOURSE &LIBRARY_EXCEL ; *aktualizuje dwa magazyny;
		Drop numerSklepu; /*usunięcie zmiennej z hurtowni danych, dodanej podaczas sprawdzania makra*/
		Drop errorMsg;
	run;
%mend uploadData;

/*
 * Sprawdza czy produkt_id jest w zakresie wartosci... [1..10]
 */

%macro czyProduktIdJestPoprawne;
	data &LIBRARY_EXCEL ;
		set &LIBRARY_EXCEL ;
		if symget('czyZwalidowane')=1 then 
			do;
				if produkt_id <= 0 OR produkt_id >= 11 then
					do;
						call symput('czyZwalidowane',0);
						stop;
					end;
				else
					do;
						call symput('czyZwalidowane',1);
					end;
			end;
	run;
%mend czyProduktIdJestPoprawne;

/*
 * Sprawdza, czy sa niepelene rekordy
*/

%macro czySaPustePola;
	data &LIBRARY_EXCEL ;
		set &LIBRARY_EXCEL ;
		if symget('czyZwalidowane')=1 then 
			do;
				if missing (Data) OR missing(Godzina) OR  missing (Sklep_id)  OR 
					missing (Ilosc)  OR missing (produkt_id)then
					do; 
						call symput('czyZwalidowane',0);
						putlog "[LOG][ERR] - Wykryte puste pole/a";
						stop;
					end;
				else
					do;
						call symput('czyZwalidowane',1);
					end;
			end;
	run;
%mend czySaPustePola;

/*
 * Odrzuca pliki, gdzie pole Ilosc ma ilosc spoza zakresu 0 < ilosc > 1000
 */

%macro czyIloscJestPoprawna;
	data &LIBRARY_EXCEL ;
		set &LIBRARY_EXCEL ;
		if symget('czyZwalidowane')=1 then 
			do;
				if Ilosc <= 0 OR Ilosc > 1000 then
					do;
						call symput('czyZwalidowane',0);
						putlog "[LOG][ERR] - Nieprawidlowa ilosc <= 0 lub ilosc > 1000";
						stop;
					end;
				else
					do;
						call symput('czyZwalidowane',1);
					end;
			end;
	run;
%mend czyIloscJestPoprawna;

/*
 * Sprawdza czy data w pliku jest taka sama jak w bazie
 */

%macro czyDataSieZgadza(nazwaPliku);
	data &LIBRARY_EXCEL ;
		set &LIBRARY_EXCEL ;
		if symget('czyZwalidowane')=1 then 
			do;
				if Data^= substr(&nazwaPliku,1,8) then
					do;
						call symput('czyZwalidowane',0);
						errorMsg = cats("[LOG][ERR] - data niezgodna z ", &nazwaPliku); /*konkatenacja*/
						putlog errorMsg;
						stop;
					end;
				else
					do;
						call symput('czyZwalidowane',1);
					end;
			end;
	run;
%mend czyDataSieZgadza;

/*
 * Sprawdza czy ostatni znak nazwy pliku odpowiada Sklep_id
 */

%macro czyNumerSklepuSieZgadza(nazwaPliku);
	data &LIBRARY_EXCEL ;
		set &LIBRARY_EXCEL ;
		numerSklepu = input(substr(&nazwaPliku,10,1),5.);
			if Sklep_id ^= numerSklepu then
				do;
					call symput('czyZwalidowane',0);
					errorMsg = cats("[LOG][ERR] - ID sklepu (", Sklep_id, ") != (", 
					numerSklepu, ")  | Nie zgodne z ", &nazwaPliku);
					putlog errorMsg;
					stop;
				end;
			else
				do;
					call symput('czyZwalidowane',1);
				end;
	run;
%mend czyNumerSklepuSieZgadza;

/*
 * Usuwa rekordy ktore dla wszystkich pol sa puste.
*/

%macro czyszczeniePustychWierszy;
	data &LIBRARY_EXCEL ;
		set &LIBRARY_EXCEL ;
		if missing (Data) AND missing(Godzina)  AND missing (produkt_id) AND 
		missing (Ilosc) AND missing (Sklep_id) then
			delete;
	run;
%mend czyszczeniePustychWierszy;


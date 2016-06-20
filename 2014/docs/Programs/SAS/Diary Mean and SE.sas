  /***************************************************************************/
  /* PROGRAM NAME:  CEX DIARY SURVEY SAMPLE PROGRAM (SAS)                    */
  /* FUNCTION: CREATE A DIARY SURVEY EXPENDITURE TABLE BY INCOME CLASS USING */
  /*           MICRODATA FROM THE BUREAU OF LABOR STATISTIC'S CONSUMER       */
  /*           EXPENDITURE SURVEY.                                           */
  /*                                                                         */
  /* WRITTEN BY:  ERIC KEIL                                                  */
  /* MODIFICATIONS:                                                          */
  /* DATE-      MODIFIED BY-      REASON-                                    */
  /* -----      ------------      -------                                    */
  /* 03/21/02   ERIC KEIL         IMPROVE EFFICIENCY                         */ 
  /* 10/22/03   ERIC KEIL         UPDATE FOR 2002 DATA                       */
  /* 11/20/03   ERIC KEIL         INCLUDE ROUTINE TO AGGREGATE EASIER        */       
  /*                                                                         */
  /*                                                                         */
  /*  FOR SAS VERSION 8 OR HIGHER                                            */
  /*                                                                         */
  /*  DATA AND INPUT FILES USED IN THIS SAMPLE PROGRAM WERE UNZIPPED         */
  /*  OR COPIED TO THE LOCATIONS BELOW:                                      */
  /*                                                                         */
  /*  DIARY DATA -- C:\2014_CEX\DIARY14                                      */
  /*  DSTUB2012.TXT -- C:\2014_CEX\Programs                                  */
  /*                                                                         */
  /***************************************************************************/

  /*Enter Data Year*/
    %LET YEAR = 2014;
  /*Enter the location where you have saved the unzipped microdata file*/
    %LET DRIVE = C:\2014_CEX;

  /****************************************************************************/
  /* STEP1: READ IN THE DSTUB PARAMETER FILE AND CREATE FORMATS               */
  /* ------------------------------------------------------------------------ */
  /* A. CONVERT THE DSTUB PARAMETER FILE INTO A LABEL FILE FOR OUTPUT         */
  /* B. CONVERT THE DSTUB PARAMETER FILE INTO AN EXPENDITURE AGGREGATION FILE */
  /* C. CREATE FORMATS FOR USE IN OTHER PROCEDURES                            */
  /****************************************************************************/


%LET YR1 = %SUBSTR(&YEAR,3,2);
LIBNAME D&YR1 "&DRIVE\SAS\DIARY&YR1";


DATA STUBFILE (KEEP= COUNT TYPE LEVEL TITLE UCC SURVEY GROUP LINE);
  INFILE "&DRIVE\Programs\DSTUB&YEAR..TXT"
  PAD MISSOVER;
  INPUT @1 TYPE $1. @ 4 LEVEL $1. @7 TITLE $CHAR60. @70 UCC $6.
        @83 SURVEY $1. @89 GROUP $7.;
  IF (TYPE = '1');
  IF GROUP IN ('CUCHARS' 'FOOD' 'EXPEND' 'INCOME');
  IF SURVEY = 'T' THEN DELETE;
    RETAIN COUNT 9999;
    COUNT + 1;
    LINE = PUT(COUNT, $5.)||LEVEL ;
	/* READS IN THE STUB PARAMETER FILE AND CREATES LINE NUMBERS FOR UCCS */
	/* A UNIQUE LINE NUMBER IS ASSIGNED TO EACH EXPENDITURE LINE ITEM     */
RUN;


DATA AGGFMT1 (KEEP= UCC LINE LINE1-LINE10);
  SET STUBFILE;
  LENGTH LINE1-LINE10 $6.;
    ARRAY LINES(9) LINE1-LINE9;
      IF (UCC > 'A') THEN
        LINES(SUBSTR(LINE,6,1)) = LINE;
	  RETAIN LINE1-LINE9;
      IF (UCC < 'A')  THEN 
        LINE10 = LINE;
  IF (LINE10);
RUN;


PROC SORT DATA= AGGFMT1 (RENAME=(LINE= COMPARE));
  BY UCC;
    /* MAPS LINE NUMBERS TO UCCS */
RUN;


PROC TRANSPOSE DATA= AGGFMT1 OUT= AGGFMT2 (RENAME=(COL1= LINE));
  BY UCC COMPARE;
  VAR LINE1-LINE10;
RUN;


DATA AGGFMT (KEEP= UCC LINE);
  SET AGGFMT2;
    IF LINE;
    IF SUBSTR(COMPARE,6,1) > SUBSTR(LINE,6,1) OR COMPARE=LINE;
	/* AGGREGATION FILE. EXTRANEOUS MAPPINGS ARE DELETED            */
	/* PROC SQL WILL ARRANGE LINE#/UCC PAIRS FOR USE IN PROC FORMAT */
RUN;


PROC SQL NOPRINT;
  SELECT UCC, LINE, COUNT(*)
  INTO  :UCCS SEPARATED BY " ",
        :LINES SEPARATED BY " ",          
        :CNT
  FROM AGGFMT;
  QUIT;
RUN;


%MACRO MAPPING;
  %DO  I = 1  %TO  &CNT;
    "%SCAN(&UCCS,&I,%STR( ))" = "%SCAN(&LINES,&I,%STR( ))"
  %END;
%MEND MAPPING;


DATA LBLFMT (RENAME=(LINE= START TITLE= LABEL));
  SET STUBFILE (KEEP= LINE TITLE);
  RETAIN FMTNAME 'LBLFMT' TYPE 'C';
  /* LABEL FILE. LINE NUMBERS ARE ASSIGNED A TEXT LABEL */
  /* DATASET CONSTRUCTED TO BE READ INTO A PROC FORMAT  */
RUN;


PROC FORMAT;

  VALUE $AGGFMT (MULTILABEL)
    %MAPPING
    OTHER= 'OTHER';
	/* CREATE AGGREGATION FORMAT */


  VALUE $INC (MULTILABEL)
    '01' = '01'
    '01' = '10'
    '02' = '02'
    '02' = '10'
    '03' = '03'
    '03' = '10'
    '04' = '04'
    '04' = '10'
    '05' = '05'
    '05' = '10'
    '06' = '06'
    '06' = '10'
    '07' = '07'
    '07' = '10'
    '08' = '08'
    '08' = '10'
    '09' = '09'
    '09' = '10';
	/* CREATE INCOME CLASS FORMAT */
RUN;


PROC FORMAT LIBRARY= WORK  CNTLIN= LBLFMT;
  /* CREATE LABEL FILE FORMATS */
RUN;


  /****************************************************************************/
  /* STEP2: READ IN ALL NEEDED DATA                                           */
  /* ------------------------------------------------------------------------ */
  /* A. READ IN THE DIARY FMLD FILES                                          */
  /* B. READ IN THE DIARY EXPD AND DTBI FILES                                 */
  /* C. MERGE FMLY AND EXPENDITURE FILES TO DERIVE WEIGHTED EXPENDITURES      */
  /****************************************************************************/

DATA FMLY (KEEP = NEWID INCLASS REPWT1-REPWT45);
  SET D&YR1..FMLD&YR1.1
      D&YR1..FMLD&YR1.2
      D&YR1..FMLD&YR1.3
      D&YR1..FMLD&YR1.4;
	  BY NEWID;
	  /* READ IN FMLD FILE DATA */

    ARRAY REPS_A(45) WTREP01-WTREP44 FINLWT21;
    ARRAY REPS_B(45) REPWT1-REPWT45;

      DO i = 1 TO 45;
	  IF REPS_A(i) > 0 THEN
         REPS_B(i) = (REPS_A(i) / 4); 
		 ELSE REPS_B(i) = 0;	
	  END;
      /* ADJUST WEIGHTS TO COMPENSATE FOR HAVING FOUR QUARTERS OF DATA */
RUN;


DATA EXPEND (KEEP = NEWID UCC COST);
  SET D&YR1..DTBD&YR1.1 (RENAME=(AMOUNT=COST))
      D&YR1..DTBD&YR1.2 (RENAME=(AMOUNT=COST))
      D&YR1..DTBD&YR1.3 (RENAME=(AMOUNT=COST))
      D&YR1..DTBD&YR1.4 (RENAME=(AMOUNT=COST))
      D&YR1..EXPD&YR1.1
      D&YR1..EXPD&YR1.2
      D&YR1..EXPD&YR1.3
      D&YR1..EXPD&YR1.4; 
  BY NEWID;
  /* READ IN INCOME AND EXPENDITURE DATA */
RUN;



DATA PUBFILE (KEEP = NEWID INCLASS UCC RCOST1-RCOST45);
  MERGE FMLY   (IN = INFAM)
        EXPEND (IN = INEXP);
  BY NEWID;
  IF INEXP AND INFAM;

  IF COST = .  THEN 
     COST = 0;
	 
     ARRAY REPS_A(45) REPWT1-REPWT45;
     ARRAY REPS_B(45) RCOST1-RCOST45;

     DO i = 1 TO 45;
	   IF REPS_A(i)> 0 
         THEN REPS_B(i) = (REPS_A(i) * COST);
	     ELSE REPS_B(i) = 0; 	
	 END; 
	 /* MERGE FMLY FILE WEIGHTS AND CHARACTERISTICS WITH EXPN/DTAB COSTS */
	 /* MULTIPLY COSTS BY WEIGHTS TO DERIVE WEIGHTED COSTS               */
RUN;


  /***************************************************************************/
  /* STEP3: CALCULATE POPULATIONS                                            */
  /* ----------------------------------------------------------------------- */
  /* 1 SUM ALL 45 WEIGHT VARIABLES TO DERIVE REPLICATE POPULATIONS           */
  /* 2 FORMAT FOR CORRECT COLUMN CLASSIFICATIONS                             */
  /***************************************************************************/


PROC SUMMARY NWAY DATA=FMLY;
  CLASS INCLASS / MLF;
  VAR REPWT1-REPWT45;
  FORMAT INCLASS $INC.;
  OUTPUT OUT = POP (DROP = _TYPE_ _FREQ_) SUM = RPOP1-RPOP45;
  /* SUMS WEIGHTS TO CREATE POPULATIONS PER REPLICATE */
  /* FORMATS TO CORRECT COLUMN CLASSIFICATIONS        */
RUN;

 

  /***************************************************************************/
  /* STEP4: CALCULATE WEIGHTED AGGREGATE EXPENDITURES                        */
  /* ----------------------------------------------------------------------- */
  /* 1 SUM THE 45 REPLICATE WEIGHTED EXPENDITURES TO DERIVE AGGREGATES       */
  /* 2 FORMAT FOR CORRECT COLUMN CLASSIFICATIONS AND AGGREGATION SCHEME      */
  /***************************************************************************/


PROC SUMMARY NWAY DATA=PUBFILE SUMSIZE=MAX COMPLETETYPES;
  CLASS UCC INCLASS / MLF;
  VAR RCOST1-RCOST45;
  FORMAT UCC $AGGFMT. INCLASS $INC.;
   OUTPUT OUT=AGG (DROP= _TYPE_ _FREQ_  RENAME=(UCC=LINE))
   SUM = RCOST1-RCOST45;
  /* SUMS WEIGHTED COSTS PER REPLICATE TO GET AGGREGATES */
  /* FORMATS INCOME TO CREATE COMPLETE REPORTING COLUMN  */
  /* FORMATS EXPENDITURES TO CORRECT AGGREGATION SCHEME  */
RUN;



  /***************************************************************************/
  /* STEP5: CALCULTATE MEAN EXPENDITURES                                     */
  /* ----------------------------------------------------------------------- */
  /* 1 READ IN POPULATIONS AND LOAD INTO MEMORY USING A 2 DIMENSIONAL ARRAY  */
  /*   POPULATIONS ARE ASSOCIATED BY INCLASS(i), AND REPLICATE(j)            */
  /* 2 READ IN AGGREGATE EXPENDITURES FROM AGG DATASET                       */
  /*   CALCULATE MEANS BY DIVIDING AGGREGATES BY CORRECT SOURCE POPULATIONS  */
  /* 4 CALCULATE STANDARD ERRORS USING REPLICATE FORMULA                     */
  /***************************************************************************/


DATA TAB1 (KEEP = LINE MEAN SE);

  /* READS IN POP DATASET. _TEMPORARY_ LOADS POPULATIONS INTO SYSTEM MEMORY  */
  ARRAY POP{01:10,45} _TEMPORARY_;
  IF _N_ = 1 THEN DO i = 1 TO 10;
    SET POP;
	ARRAY REPS(45) RPOP1-RPOP45;
	  DO j = 1 TO 45;
	    POP{INCLASS,j} = REPS(j);
	  END;
	END;

  /* READS IN AGG DATASET AND CALCULATES MEANS BY DIVIDING BY POPULATIONS  */
  SET AGG (KEEP = LINE INCLASS RCOST1-RCOST45);
	ARRAY AGGS(45) RCOST1-RCOST45;
	ARRAY AVGS(45) MEAN1-MEAN44 MEAN;
	  DO k = 1 TO 45;
	    IF AGGS(k) = . THEN AGGS(k) = 0;
	    AVGS(k) = AGGS(k) / POP{INCLASS,k};
	  END;

  /* CALCULATES STANDARD ERRORS USING REPLICATE FORMULA  */
  ARRAY RMNS(44) MEAN1-MEAN44;
  ARRAY DIFF(44) DIFF1-DIFF44;
    DO n = 1 TO 44;
      DIFF(n) = (RMNS(n) - MEAN)**2;
    END;  
  SE = SQRT((1/44)*SUM(OF DIFF(*)));
RUN;



  /***************************************************************************/
  /* STEP6: TABULATE EXPENDITURES                                            */
  /* ----------------------------------------------------------------------- */
  /* 1 ARRANGE DATA INTO TABULAR FORM                                        */
  /* 2 SET OUT DIARY POPULATIONS FOR POPULATION LINE ITEM                    */
  /* 3 INSERT POPULATION LINE INTO TABLE                                     */
  /* 4 INSERT ZERO EXPENDITURE LINE ITEMS INTO TABLE FOR COMPLETENESS        */
  /***************************************************************************/


PROC TRANSPOSE DATA=TAB1 OUT=TAB2
  NAME = ESTIMATE PREFIX = INCLASS;
  BY LINE;
  VAR MEAN SE;
  /*ARRANGE DATA INTO TABULAR FORM */
RUN;


PROC TRANSPOSE DATA=POP (KEEP = RPOP45) OUT=CUS
  NAME = LINE PREFIX = INCLASS;
  VAR RPOP45;
  /* SET ASIDE POPULATIONS FROM DIARY */
RUN;


DATA TAB3;
  SET CUS TAB2;
  IF LINE = 'RPOP45' THEN DO;
    LINE = '100001';
	ESTIMATE = 'N';
	END;
  /* INSERT POPULATION LINE ITEM INTO TABLE AND ASSIGN LINE NUMBER */
RUN;


DATA TAB;
  MERGE TAB3 STUBFILE;
  BY LINE;
    IF LINE NE '100001' THEN DO;
	  IF SURVEY = 'S' THEN DELETE;
	END;
	ARRAY CNTRL(10) INCLASS1-INCLASS10;
	  DO i = 1 TO 10;
	    IF CNTRL(i) = . THEN CNTRL(i) = 0;
		IF SUM(OF CNTRL(*)) = 0 THEN ESTIMATE = 'MEAN';
	  END;

	IF GROUP IN ('CUCHARS' 'INCOME') THEN DO;
	  IF LAG(LINE) = LINE THEN DELETE;
	END;
  /* MERGE STUBFILE BACK INTO TABLE TO INSERT EXPENDITURE LINES */
  /* THAT HAD ZERO EXPENDITURES FOR THE YEAR                    */
RUN;


PROC TABULATE DATA=TAB;
  CLASS LINE / GROUPINTERNAL ORDER=DATA;
  CLASS ESTIMATE;
  VAR INCLASS1-INCLASS10;
  FORMAT LINE $LBLFMT.;

    TABLE (LINE * ESTIMATE), (INCLASS10 INCLASS1 INCLASS2 INCLASS3 INCLASS4 
                              INCLASS5  INCLASS6 INCLASS7 INCLASS8 INCLASS9) 
    *SUM='' / RTS=25;
    LABEL ESTIMATE=ESTIMATE LINE=LINE
          INCLASS1='LESS THAN $5,000'   INCLASS2='$5,000 TO $9,999' 
          INCLASS3='$10,000 TO $14,999' INCLASS4='$15,000 TO $19,999'
          INCLASS5='$20,000 TO $29,999' INCLASS6='$30,000 TO $39,999'
          INCLASS7='$40,000 TO $49,999' INCLASS8='$50,000 TO $69,999'
          INCLASS9='$70,000 AND OVER'   INCLASS10='ALL CONSUMER UNITS';
	OPTIONS NODATE NOCENTER NONUMBER LS=167 PS=MAX;
	WHERE LINE NE 'OTHER';
    TITLE "DIARY EXPENDITURES FOR &YEAR BY INCOME BEFORE TAXES";
RUN;



/**********************************************************************/
/* PROGRAM NAME:  CE MACROS.SAS                                       */
/* LOCATION: P:\SASmacros				          	  				  */
/*                                                                    */
/* FUNCTION: CALCULATE MEAN AND SE USING BRR (FOR NUMERIC VARIABLES)  */
/*           PERFORM OLS AND LOGISTIC REGRESSIONS USING BRR           */
/*           FOR COLLECTION YEAR ESTIMATES                            */
/*                                                                    */
/*    CALCULATE MEANS AND VARIANCES FOR UNWEIGHTED DATA               */
/*    PERFORM OLS AND LOGISTIC REGRESSIONS FOR UNWEIGHTED DATA        */
/*                                                                    */
/* WRITTEN BY:  SALLY REYES                                           */
/*                                                                    */
/*    SAS version 9.1 and earlier                                     */
/*							                    					  */
/* MODIFICATIONS:                                                     */
/* DATE-      MODIFIED BY-                                            */
/* -----      ------------                                            */
/* 04/17/06   SALLY REYES                                             */
/*                                                                    */
/* 10/01/10   SALLY REYES      Add note about weighted statistics     */
/*                             by region of the country               */
/*                                                                    */
/**********************************************************************/

/**********************************************************************/
/* IMPORTANT NOTE:                                                    */
/*  Weighted variances and related statistics (SE, CV, etc.)          */
/*  should not be calculated using the variable REGION                */
/*  or variables derived from it-for example,                         */
/*  NORTHEAST in the statement "NORTHEAST=(REGION='1')"-              */
/*  in the BYVARS, IND_VARS or DEP_VARS arguments                     */
/*  because the PSU-based methodology used to generate                */
/*  the replicate weight variables conflicts                          */
/*  with the calculation of these estimates.                          */
/*  However, in the %MEAN_VARIANCE macro, weighted means              */
/*  computed using REGION in the BYVARS statement                     */
/*  are correct for the ANALVARS defined there.                       */
/**********************************************************************/

/**********************************************************************/
/*          The following macros do not annualize expenditures        */
/**********************************************************************/
/*						HOW TO USE THIS MACROS						  */
/**********************************************************************/

/*
OPTIONS PAGENO=1 NOCENTER NODATE;								
* INCLUDE MACRO ;
%INCLUDE "P:\SASmacros\CE MACROS.SAS";

* READ YOUR DATA SET ;
* NAME AND VALUES FOR REPLICATE WEIGHTS AND FINLWT21 SHOULD NOT BE CHANGED ;
LIBNAME IN "C:\SAS\";							
DATA CEDATA;																
SET IN.CEDATA;																
RUN;																	

* CALL THE MACROS ;

      %MEAN_VARIANCE(DSN = CEDATA, 
  				  FORMAT = , 
			 USE_WEIGHTS = YES,
				  BYVARS = BLS_URBN, 
				ANALVARS = PENSIONX INTEARNX, 
			IMPUTED_VARS = PENSION1-PENSION5 INTEARN1-INTEARN5,
                      CL = 90, 
					  DF = RUBIN87,
				  TITLE1 = Testing the macro program,
				  TITLE2 = for CEDATA,
				 XOUTPUT = );

	  %PROC_REG(DSN = CEDATA, 
  			 FORMAT = BLS_URBN $URBN., 
		USE_WEIGHTS = NO,
		     BYVARS = BLS_URBN,
		   DEP_VARS = ZTOTAL, 
		   IND_VARS = AGE_REF, 
	   IMPUTED_VARS = PENSION1-PENSION5 INTEARN1-INTEARN5,
			     DF = RUBIN87,
		     TITLE1 = Testing the Regression program,
			 TITLE2 = for the CEDATA,
		    XOUTPUT = );

      %PROC_LOGISTIC(DSN = CEDATA, 
  				  FORMAT = , 
			 USE_WEIGHTS = YES,
		          BYVARS = ,
				DEP_VARS = GENDER SEX, 
				IND_VARS = RURAL, 
			IMPUTED_VARS = PENSION1-PENSION5 INTEARN1-INTEARN5, 
			          DF = RUBIN87,
			  SORT_ORDER = INTERNAL, 
			   CLASSVARS = ,
				  TITLE1 = Testing the Logistic program,
                  TITLE2 = for the CEDATA,
				 XOUTPUT = );
*/

OPTIONS PAGENO=1 NOCENTER NODATE formdlim = '-' NONOTES;

/**********************************************************************/
/* READ DATASET      			                                      */
/**********************************************************************/
%MACRO READ_DATA;
OPTIONS PAGENO=1 NOCENTER NODATE;
%IF %UPCASE(&USE_WEIGHTS) = YES %THEN %DO;
	DATA MYDATA;
	SET &DSN.;
	FORMAT &FORMAT.;

/* 861old, 961old, 051old are datasets from old sample designs */
/* 20 replicate weights from 1984 QTR1 to 1986 QTR2 */
/* 44 replicate weights from 1986 QTR2 to PRESENT */

	%IF &REPLICATES. = 20 %THEN %DO;
	ARRAY A(&TIMES.) FINLWT01-FINLWT&REPLICATES. FINLWT21;
	%END;
	%ELSE %IF &REPLICATES. = 44 %THEN %DO;
	ARRAY A(&TIMES.) WTREP01-WTREP&REPLICATES. FINLWT21;
	%END;

	/*CONVERT MISSING WEIGHTS TO ZERO*/
	ARRAY B(&TIMES.) WTREP1-WTREP&TIMES.;
	 DO I=1 TO &TIMES.;
	  IF A(I)=.B THEN A(I)=0;
	  ELSE IF A(I)=. THEN A(I)=0;
	  B(I)=A(I);
	  DROP I; 
	 END;
	RUN;
%END;
%ELSE %IF %UPCASE(&USE_WEIGHTS) = NO %THEN %DO;
	DATA MYDATA;
	SET &DSN.;
	FORMAT &FORMAT.;
	RUN;
%END;
%MEND;

/**********************************************************************/
/* GET SAMPLE SIZE    			                                      */
/**********************************************************************/
%MACRO PROC_FREQ;
* SPECIFY SORTING ORDER IF BY VARIABLES PRESENT;

%GLOBAL BYV;

%IF (%SUPERQ(BYVARS) NE ) %THEN %DO;
PROC SORT DATA=MYDATA;
BY &BYVARS.;
RUN;
%END;

DATA COUNT_SS(KEEP=SAMPLE_SIZE &BYVARS. Count);
SET MYDATA;
SAMPLE_SIZE = 'RECORDS';
Count=1;
RUN;
/* GET THE SAMPLE SIZE */

%IF (%SUPERQ(BYVARS) NE ) %THEN %DO;
%LET BYVRS = %SCAN(&BYVARS., 1, ' ');
%COUNT_VARS(&BYVARS.,DELIM=%STR( ));
	%LET BYV = &N_VARS.;
		%IF &BYV. GE 2 %THEN %DO;
			%DO BV=2 %TO &BYV.;
 			   %LET BYVR = %SCAN(&BYVARS., &BV, ' ');
			%LET BYVRS = &BYVRS.*&BYVR.;
			%END;
		%END;

PROC FREQ DATA=COUNT_SS NOPRINT;
TABLES &BYVRS./OUT=CTGPS(KEEP = &BYVARS. Count) LIST;
RUN;

PROC SORT DATA=CTGPS;
BY &BYVARS.;
RUN;

/* GET GROUPS NUMBERS */
data CTGPS;
set CTGPS;
 Group=_n_;  
run;

DATA MYDATA;
MERGE MYDATA CTGPS(DROP=COUNT);
BY &BYVARS.;
RUN;

PROC PRINT DATA=CTGPS ;
TITLE1 "Consumer Expenditure Survey";
TITLE2 "Sample size for collection year estimates";
TITLE3 "Dataset &DSN. By &BYVARS.";
VAR &BYVARS. Count;
ID GROUP;
RUN;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE CTGPS;
QUIT;
%END;
%ELSE %DO;
PROC FREQ DATA=COUNT_SS;
TITLE1 "Consumer Expenditure Survey";
TITLE2 "Sample size for collection year estimates";
TITLE3 "Dataset &DSN.";
TABLES SAMPLE_SIZE;
RUN;
%END;

PROC MEANS DATA=COUNT_SS NOPRINT;
BY &BYVARS.; 
VAR COUNT;
OUTPUT OUT=SS N=SS;
RUN;

DATA SS(DROP=_TYPE_ _FREQ_);
SET SS;
COUNT=1;
RUN;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE COUNT_SS;
QUIT;
%MEND;

/**********************************************************************/
/* COUNT THE NUMBER OF VARIABLES    			                      */
/**********************************************************************/
%MACRO COUNT_VARS(STR,DELIM=%STR( ));
%GLOBAL N_VARS;
%LOCAL N STR DELIM;
%LET N=1;
%DO %WHILE(%LENGTH(%SCAN(&STR,&N,&DELIM)) GT 0);
  %LET N=%EVAL(&N + 1);
%END;
%LET N_VARS=%EVAL(&N - 1);
%MEND;

/**********************************************************************/
/* PRINT OUTPUT DATASET WITH MEANS AND VARIANCES                      */
/* CREATE DATASETS WITH FINAL RESULTS                                 */
/* CREATE DATASET FOR BY GROUP COMPARISONS                            */
/**********************************************************************/
%MACRO PRINT;
/* PRINT OUTPUT DATASET */
%IF (%SUPERQ(XOUTPUT) = YES) OR "&ANALVARS." NE "&IMPUTED_VARS." %THEN %DO;

%IF %UPCASE(&USE_WEIGHTS) = YES %THEN 
	%LET TITLE6 = Mean and SE using the BRR method of variance estimation;
    %ELSE %IF %UPCASE(&USE_WEIGHTS) = NO %THEN 
    %LET TITLE6 = Unweighted Mean and SE;

PROC PRINT DATA=A SPLIT='*' UNIFORM;
    TITLE1 &TITLE1.;
	TITLE2 &TITLE2.;
    TITLE3 &TITLE3.;
	TITLE4 &TITLE4.;
	TITLE5 &TITLE5.;
    TITLE6 &TITLE6.;
	TITLE7 &TITLE7.;
ID &BYVARS. VARIABLE;
VAR MEAN SE VARIANCE RSE;
LABEL 
    VARIABLE = " Variable"
	MEAN     = " Mean"
    SE       = " Standard*    Error*     (SE)"
    VARIANCE = " Variance"
	RSE      = " Relative* Standard*    Error* ((SE/Mean)x100)"
    ;
RUN;

PROC PRINT DATA=A SPLIT='*' UNIFORM;
    TITLE1 &TITLE1.;
	TITLE2 &TITLE2.;
    TITLE3 &TITLE3.;
	TITLE4 &TITLE4.;
	TITLE5 &TITLE5.;
	TITLE6 "&CI.";
	TITLE7 &TITLE7.;
ID &BYVARS. VARIABLE;
VAR MEAN N DFC CI_LOW CI_HIGH;
LABEL 
    VARIABLE = " Variable"
	MEAN     = " Mean"
	DFC      = "Degrees of * Freedom"
    ;
RUN;
%END;

%IF "&ANALVARS." NE "&IMPUTED_VARS." %THEN %DO;
DATA ANALVARS
	(KEEP=VARIABLE MEAN VARIANCE SE RSE &BYVARS. ALPHA N DFC CI_LOW CI_HIGH);
RETAIN VARIABLE &BYVARS. MEAN SE VARIANCE RSE N DFC ALPHA CI_LOW CI_HIGH; 
SET A;
RUN;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE A;
QUIT;

/* CREATE TRANSPOSE DATASET TO MAKE COMPARISONS BY BY_GROUPS */
%IF &BYVARS. NE  %THEN %DO;
proc sort data=TMEANS;
by _name_ &BYVARS.;
run;

data TMEANS(drop=&BYVARS.);
set TMEANS;
run;

PROC TRANSPOSE DATA=TMEANS PREFIX=GP OUT=TYAV;
BY _name_;
RUN;
%END;
%END;
%MEND;

/**********************************************************************/
/* CALCULATE WEIGHTED MEANS AND VARIANCES     			              */
/**********************************************************************/
%MACRO WT_MEAN_VARIANCE(ANALVARS=);
/* CHECK TYPE OF VARIABLE OF INTEREST */

PROC CONTENTS DATA = MYDATA (KEEP = &ANALVARS.) NOPRINT
  OUT = VARTYPE;
RUN;

%LET CHARS = ;

PROC SQL NOPRINT;
 SELECT NAME INTO: CHARS SEPARATED BY ' '
 FROM VARTYPE WHERE TYPE = 2;
QUIT;
/* IF VARIABLE IS NOT NUMERIC PRINT ERROR MESSAGE AND END PROGRAM */
/* ELSE CONTINUE WITH PROGRAM */

%IF &CHARS NE %THEN %DO;
%PUT ERROR: Variable &CHARS. in list does not match type prescribed for this list.;
%END;
%ELSE %DO;

/* RUN PROC MEANS TO GET SAMPLE SIZE */
PROC MEANS DATA=MYDATA NOPRINT;
BY &BYVARS.; 
VAR &ANALVARS.;
OUTPUT OUT=ALL_N N=&ANALVARS.;
RUN;
DATA ALL_N(DROP=_TYPE_ _FREQ_);
SET ALL_N;
RUN;

* SPECIFY SORTING ORDER IF BY VARIABLES PRESENT;
%IF (%SUPERQ(BYVARS) NE ) %THEN %DO;
PROC SORT DATA=ALL_N;
BY &BYVARS.;
RUN;
%END;

/* TRANSPOSE ALL THE VARIABLES */
PROC TRANSPOSE DATA=ALL_N PREFIX=N OUT=TN;
BY &BYVARS.; 
RUN;
PROC SORT DATA=TN;
BY  _NAME_ ;
RUN;

/* RUN PROC MEANS (NUMBER OF REPLICATES + 1) TIMES */

%DO I = 1 %TO &TIMES.;
PROC MEANS DATA=MYDATA NOPRINT;
BY &BYVARS.; 
VAR &ANALVARS.;
WEIGHT WTREP&I.;
OUTPUT OUT=M&I. MEAN=&ANALVARS.;
RUN;

PROC APPEND BASE=ALL_MEANS DATA=M&I.;
RUN;
%END;

DATA ALL_MEANS(DROP=_TYPE_ _FREQ_);
SET ALL_MEANS;
RUN;
* SPECIFY SORTING ORDER IF BY VARIABLES PRESENT;

%IF (%SUPERQ(BYVARS) NE ) %THEN %DO;
PROC SORT DATA=ALL_MEANS;
BY &BYVARS.;
RUN;
%END;
/* TRANSPOSE ALL THE VARIABLES */

PROC TRANSPOSE DATA=ALL_MEANS PREFIX=YBAR OUT=TMEANS;
BY &BYVARS.;
RUN;

DATA TMEANS;
SET TMEANS;
  ARRAY YBARS(&REPLICATES.) YBAR1-YBAR&REPLICATES.;
    DO I = 1 TO &REPLICATES.;
      IF YBARS(I)=. THEN YBARS(I)=0;
      DROP I; 
    END; 
RUN;
/* CALCULATE SE FOR THE MEAN */

DATA A;
  SET TMEANS;
  Variable = _NAME_;
  REPLICATES = &REPLICATES.;
  ARRAY YBARS(&REPLICATES.) YBAR1-YBAR&REPLICATES.;
  ARRAY SQDIFF(&REPLICATES.) SQDIFF1-SQDIFF&REPLICATES.;
    DO I = 1 TO &REPLICATES.;
      SQDIFF(I) = (YBARS(I) - YBAR&TIMES.)**2;
      DROP I; 
    END; 
  MEAN = YBAR&TIMES.;
  VARIANCE = SUM(OF SQDIFF(*))/REPLICATES;
  SE = SQRT(VARIANCE); /* HORIZONTAL SUM */
  IF MEAN NE 0 THEN RSE= (SE/MEAN)*100;
  ELSE RSE = .;
  DFC = &REPLICATES.;
  ALPHA = &ALPHA.;
  T = ABS(TINV(ALPHA,DFC));
  CI_HIGH = MEAN+(SE*T);
  CI_LOW = MEAN-(SE*T);
RUN;

PROC SORT DATA=A;
BY _NAME_;
RUN;

DATA A(RENAME=(N1=N));
MERGE TN A;
BY _NAME_;
RUN;
%PRINT;
%END;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE VARTYPE M1-M&TIMES. ALL_MEANS ALL_N TMEANS TN;
QUIT;
%MEND;

/**********************************************************************/
/* CALCULATE UNWEIGHTED MEANS AND VARIANCES   			              */
/**********************************************************************/
%MACRO UNWT_MEAN_VARIANCE(ANALVARS=);
/* CHECK TYPE OF VARIABLE OF INTEREST */
PROC CONTENTS DATA = MYDATA (KEEP = &ANALVARS.) NOPRINT
  OUT = VARTYPE;
RUN;

%LET CHARS = ;

PROC SQL NOPRINT;
 SELECT NAME INTO: CHARS SEPARATED BY ' '
 FROM VARTYPE WHERE TYPE = 2;
QUIT;
/* IF VARIABLE IS NOT NUMERIC PRINT ERROR MESSAGE AND END PROGRAM */
/* ELSE CONTINUE WITH PROGRAM */

%IF &CHARS NE %THEN %DO;
%PUT ERROR: Variable &CHARS. in list does not match type prescribed for this list.;
%END;
%ELSE %DO;

/* RUN PROC MEANS TO GET SAMPLE SIZE */
PROC MEANS DATA=MYDATA NOPRINT;
BY &BYVARS.; 
VAR &ANALVARS.;
OUTPUT OUT=ALL_N N=&ANALVARS.;
RUN;
DATA ALL_N(DROP=_TYPE_ _FREQ_);
SET ALL_N;
RUN;

/* RUN PROC MEANS TO GET UNWEIGHTED MEANS */
PROC MEANS DATA=MYDATA NOPRINT;
BY &BYVARS.; 
VAR &ANALVARS.;
OUTPUT OUT=ALL_MEANS MEAN=&ANALVARS.;
RUN;
DATA ALL_MEANS(DROP=_TYPE_ _FREQ_);
SET ALL_MEANS;
RUN;

/* RUN PROC MEANS TO GET UNWEIGHTED SE*/
PROC MEANS DATA=MYDATA NOPRINT;
BY &BYVARS.; 
VAR &ANALVARS.;
OUTPUT OUT=ALL_SE STDERR=&ANALVARS.;
RUN;
DATA ALL_SE(DROP=_TYPE_ _FREQ_);
SET ALL_SE;
RUN;

* SPECIFY SORTING ORDER IF BY VARIABLES PRESENT;
%IF (%SUPERQ(BYVARS) NE ) %THEN %DO;
PROC SORT DATA=ALL_N;
BY &BYVARS.;
RUN;
PROC SORT DATA=ALL_MEANS;
BY &BYVARS.;
RUN;
PROC SORT DATA=ALL_SE;
BY &BYVARS.;
RUN;
%END;

/* TRANSPOSE ALL THE VARIABLES */
PROC TRANSPOSE DATA=ALL_N PREFIX=N OUT=TN;
BY &BYVARS.; 
RUN;
PROC SORT DATA=TN;
BY  _NAME_ ;
RUN;

PROC TRANSPOSE DATA=ALL_MEANS PREFIX=MEAN OUT=TMEANS;
BY &BYVARS.; 
RUN;
PROC SORT DATA=TMEANS;
BY  _NAME_ ;
RUN;

PROC TRANSPOSE DATA=ALL_SE PREFIX=SE OUT=TSE;
BY &BYVARS.; 
RUN;
PROC SORT DATA=TSE;
BY  _NAME_ ;
RUN;

/* CREATE DATASET WITH N, MEANS, AND VARIANCES */
DATA A(RENAME=(N1=N MEAN1=MEAN SE1=SE _NAME_=VARIABLE));
MERGE TN TMEANS TSE;
BY _NAME_;
RUN;

DATA A(KEEP=VARIABLE N MEAN SE RSE VARIANCE ALPHA CI_HIGH CI_LOW &BYVARS. DFC);
SET A;
VARIANCE=SE*SE;
IF MEAN NE 0 THEN RSE=(SE/MEAN)*100;
ELSE RSE = .;
ALPHA = &ALPHA.;
DFC = N - 1;
T = ABS(TINV(ALPHA,DFC));
CI_HIGH = MEAN+(SE*T);
CI_LOW = MEAN-(SE*T);
RUN;

%PRINT;
%END;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE VARTYPE ALL_MEANS ALL_SE ALL_N TMEANS TSE TN;
QUIT;
%MEND;

/**********************************************************************/
/* CREATE DATASET WITH MEANS AND VARIANCES                            */
/* OF EACH GROUP OF 5 IMPUTED VARIABLES                               */
/**********************************************************************/
%MACRO IMPUTED_VARIABLES(USE_WEIGHTS);
DATA IMPUTED_VARS
	(KEEP=VARIABLE MEAN VARIANCE SE RSE &BYVARS. ALPHA N DFC CI_LOW CI_HIGH);
RETAIN VARIABLE &BYVARS. MEAN SE VARIANCE RSE N DFC ALPHA CI_LOW CI_HIGH; 
SET A;
RUN;

* SPECIFY SORTING ORDER IF BY VARIABLES PRESENT ;
%IF (%SUPERQ(BYVARS) NE ) %THEN %DO;
PROC SORT DATA=IMPUTED_VARS;
BY &BYVARS.;
RUN;
%END;

%LET VRS = ;
proc sql noprint;
 SELECT distinct variable INTO: VRS SEPARATED BY ' ' 
 FROM IMPUTED_VARS;
QUIT;
%LET VRS = %UPCASE(&VRS);

/*COUNT THE NUMBER OF IMPUTED VARIABLES*/
	%COUNT_VARS(&VRS.,DELIM=%STR( ));
	%LET AV = &N_VARS.;
%DO C=1 %TO &AV. %BY &MI.;
%LET CVAR = &C.;
%LET IMPVAR = ;
	%DO CMI = 1 %TO &MI.;
    	%LET IMPVAR&CMI. = %SCAN(&VRS., &CVAR, ' ');
    	%LET CVAR=%EVAL(&CVAR + 1);
		%LET IMPVAR = &IMPVAR. "&&IMPVAR&CMI.";
	%END;

	%LET IMPVAR1 = &IMPVAR1.-&&IMPVAR&MI.;

/* KEEP DATA ONLY FOR THE &MI. IMPUTED VARIABLES */
DATA IMPUTED_VARS1;
SET IMPUTED_VARS;
IF VARIABLE IN(&IMPVAR.);
RUN;

PROC TRANSPOSE DATA=IMPUTED_VARS1 OUT=TM PREFIX=MEAN;
VAR MEAN ;
BY &BYVARS.;
RUN;

PROC TRANSPOSE DATA=IMPUTED_VARS1 OUT=TV PREFIX=VAR;
VAR VARIANCE;
BY &BYVARS.;
RUN;

PROC TRANSPOSE DATA=IMPUTED_VARS1 OUT=TDF PREFIX=DFC;
VAR DFC;
BY &BYVARS.;
RUN;

PROC TRANSPOSE DATA=IMPUTED_VARS1 OUT=TN PREFIX=N;
VAR N;
BY &BYVARS.;
RUN;

DATA TALL(DROP=_NAME_ );
ATTRIB VARIABLE LENGTH=$25.;
MERGE TM TV TDF TN;
BY &BYVARS.;
Variable="&IMPVAR1.";
RUN;

PROC APPEND BASE=TOT_VAR DATA=TALL FORCE;
RUN;

%IF (%SUPERQ(BYVARS)NE ) %THEN %DO;
	%IF %UPCASE(&USE_WEIGHTS) = YES %THEN %DO;

%LET YBAR = YBAR1-YBAR&TIMES.;

DATA AX(KEEP=&BYVARS. VARIABLE &YBAR.);
SET A;
IF VARIABLE IN(&IMPVAR.) THEN OUTPUT AX;
RUN;

PROC SORT DATA=AX;
BY VARIABLE;
RUN;

	PROC TRANSPOSE DATA=AX PREFIX=GP OUT=TYALLMI;
	BY VARIABLE;
	VAR &YBAR.;
	RUN;

DATA TYALLMI;
ATTRIB VARIABLE1 LENGTH=$25.;
SET TYALLMI;
IF VARIABLE IN(&IMPVAR.) THEN VARIABLE1 = "&IMPVAR1.";
RUN; 

PROC APPEND BASE=TYALLMIS DATA=TYALLMI FORCE;
RUN;

DATA TY4WM;
SET TYALLMIS;
RUN;
%END;
%END;
%END;

PROC DATASETS NOLIST LIBRARY=WORK;
DELETE TM TV TDF TN A AX TALL IMPUTED_VARS IMPUTED_VARS1 TYALLMI TYALLMIS;
QUIT;
%MEND;

/**********************************************************************/
/* CALCULATE THE TOTAL VARIANCE FOR ALL GROUPS OF &MI. IMPUTED VARIABLES */
/**********************************************************************/
%MACRO TOT_VAR;
DATA TOT_VARS(DROP=MEAN1-MEAN&MI. VAR1-VAR&MI. SUMSQRD);
SET TOT_VAR;

MI = &MI.;
ADJ = (1+(1/MI));

* MEAN OF THE MEANS ;
MEAN_MEANS=MEAN(OF MEAN1-MEAN&MI.);
SUMSQRD=0;
%DO I=1 %TO &MI.;
    SUMSQRD=SUM(SUMSQRD,((MEAN&I.-MEAN_MEANS)**2));
%END;
* VARIANCE OF THE MEANS ;
VAR_MEANS=SUMSQRD/(MI - 1);

* MEAN OF THE VARIANCE ; 
MEAN_VARS=MEAN(OF VAR1-VAR&MI.);

/* Total variance formula */
/* T = Mean of the variances + [(1+(1/MI))*Variance of the means] */
TVAR = MEAN_VARS + (ADJ*VAR_MEANS);
RUN;

PROC DATASETS NOLIST LIBRARY=WORK;
DELETE TOT_VAR;
QUIT;
%MEND;

%MACRO TOT_VARS;
	PROC SORT DATA=TOT_VARS;
	BY &BYVARS. VARIABLE;
	RUN;

/* RM = RELATIVE INCREASE OF VARIANCE DUE TO NONRESPONSE */
DATA TOT_VARS(DROP=DFC1-DFC&MI. N1-N&MI.);
SET TOT_VARS;
* DEGREES OF FREEDOM ; 
  DFC = DFC1;
  N = N1;
  ALPHA = &ALPHA.;  
  MI = &MI.;
  ADJ = 1+(1/MI);
  SE = SQRT(TVAR); 
  IF MEAN_MEANS NE 0 THEN RSE= (SE/MEAN_MEANS)*100;
  ELSE RSE = .;
/* DF from RUBINS book 1987, page 77 */
  RM = (ADJ*VAR_MEANS)/MEAN_VARS;
  DFM = (MI - 1)*(1+(1/RM))**2;
/* What definition to use? Rubin87(DFM) or Rubin99(DDF)*/
%IF &DF. = RUBIN87 %THEN DDF = DFM;
%ELSE %IF &DF. = RUBIN99 %THEN %DO;
/* DF from SUDAAN Language manual, page 89 Rubin definition 1999*/
/* DFC = DEGREES OF FREEDOM OF COMPLETE DATASET */
/* VDF [(DFC+1 / DFC+3)]*[(1- [(MI+1)*VAR_MEANS]/MI*TVAR)]*DFC */
/* DDF = 1/ [(1/DFC) + (1/VDF)]*/
  %IF &USE_WEIGHTS. = YES %THEN DFC = &REPLICATES.;;
  VDF = ((DFC+1)/(DFC+3))*(1-(((MI + 1)*VAR_MEANS)/(MI*TVAR)))*DFC;
  DDF = 1/((1/DFM)+(1/VDF)); 
%END;;

	T = ABS(TINV(ALPHA,DDF));
	/* ROUND DF */
	DF = ROUND(DDF,1);
    CI_HIGH = MEAN_MEANS+(SE*T);
    CI_LOW = MEAN_MEANS-(SE*T);
RUN;

%IF %UPCASE(&USE_WEIGHTS) = YES %THEN 
	%LET TITLE6 = Total variance using the BRR method of variance estimation;
    %ELSE %IF %UPCASE(&USE_WEIGHTS) = NO %THEN 
    %LET TITLE6 = Total variance for unweighted data;

	PROC PRINT DATA=TOT_VARS SPLIT='*' UNIFORM;
	TITLE1 &TITLE1.;
	TITLE2 &TITLE2.;
	TITLE3 &TITLE3.;
	TITLE4 &TITLE4.;
	TITLE5 &TITLE5.;
	TITLE6 &TITLE6.;
	TITLE7 &TITLE7.;
	ID &BYVARS. VARIABLE;
	VAR MEAN_MEANS SE TVAR RSE;
	LABEL 
	    MEAN_MEANS   = "    Mean"
        SE           = "Standard*   Error*    (SE)"
	    RSE          = "Relative*Standard*   Error*((SE/Mean)x100)"
		TVAR 		 = "   Total*Variance"
		;
	RUN;

%IF %UPCASE(&DF) = RUBIN99 %THEN 
	%LET TITLE7 = Degrees of Freedom: Barnard & Rubin (1999) definition;
    %ELSE %IF %UPCASE(&DF) = RUBIN87 %THEN 
    %LET TITLE7 = Degrees of Freedom: Rubin (1987) definition;

	PROC PRINT DATA=TOT_VARS SPLIT='*' UNIFORM;
	TITLE1 &TITLE1.;
	TITLE2 &TITLE2.;
	TITLE3 &TITLE3.;
	TITLE4 &TITLE4.;
	TITLE5 &TITLE5.;
	TITLE6 "&CI.";
	TITLE7 &TITLE7.;
	TITLE8 &TITLE8.;
	ID &BYVARS. VARIABLE;
	VAR MEAN_MEANS N DF CI_LOW CI_HIGH;
	LABEL 
		DF           = "Degrees of * Freedom"
	    MEAN_MEANS   = "    Mean"
		;
	RUN;

DATA IMPUTEDVARS;
RETAIN Variable &BYVARS. MEAN_MEANS SE TVAR RM RSE DFC ALPHA CI_LOW CI_HIGH; 
SET TOT_VARS;
RUN;

%IF (%SUPERQ(BYVARS)NE ) %THEN %DO;
	%IF %UPCASE(&USE_WEIGHTS) = NO %THEN %DO;
		DATA TY4UNWM(KEEP=VARIABLE &BYVARS. MEAN_MEANS TVAR DFC DFM DDF ALPHA);;
		SET IMPUTEDVARS;
		RUN;
	%END;
%END;
%MEND;

/*********************************************************************/
/* MACRO MEAN_VARIANCE                                               */
/*********************************************************************/
/****************************************************************/
/* DSN:  		 DATASET NAME									*/
/* FORMAT:       FORMATS IF ANY							        */
/* USE_WEIGHTS:  YES OR NO (DEFAULT = NO)				        */
/* BYVARS:  	 BY VARIABLES IF ANY							*/
/* ANALVARS: 	 ANALYSIS VARIABLE NAMES						*/
/* IMPUTED_VARS: IMPUTED VARIABLE NAMES							*/
/* CL:  		 CONFIDENCE LEVEL (DEFAULT IS 95)			    */
/* DF:  		 DEGREES OF FREEDOM DEFINITION                  */
/*								(DEFAULT IS RUBIN99)		    */
/*                              (OPTION IS RUBIN 87)            */
/* TITLE1:  	 TITLE 1 FOR OUTPUT							    */
/* TITLE2:  	 TITLE 2 FOR OUTPUT							    */
/* TITLE3:  	 TITLE 3 FOR OUTPUT							    */
/* XOUTPUT       PRINT EXTRA OUTPUT                             */
/* REP_WT:  	 NUMBER OF REPLICATE WEIGHTS                    */
/*								(DEFAULT IS 44)		            */
/*                              (OPTION IS 20)                  */
/* IMPUTATIONS:  NUMBER OF IMPUTATIONS (DEFAULT = 5)			*/
/****************************************************************/
/**********************************************************************/
/* CALCULATE MEAN, VARIANCE AND TOTAL VARIANCE                        */
/* FOR WEIGHTED OR UNWEIGHTED DATA									  */
/**********************************************************************/
%MACRO MEAN_VARIANCE(DSN = , 
  				  FORMAT = , 
			 USE_WEIGHTS = ,
			      BYVARS = , 
				ANALVARS = , 
			IMPUTED_VARS = ,
                      CL = ,
                      DF = , 
				  TITLE1 = ,
				  TITLE2 = ,
				  TITLE3 = ,
 				 XOUTPUT = ,
				  REP_WT = ,
			 IMPUTATIONS =  );

/* DEFINE GLOBAL MACRO VARIABLES */
%GLOBAL ALPHA;
%GLOBAL UW;
%GLOBAL DFDEF;
%GLOBAL FRMT;
%GLOBAL BY_VAR;
%GLOBAL AVARS;
%GLOBAL MIVARS;
%GLOBAL MI;
%GLOBAL REPLICATES;
%GLOBAL TIMES;

%LET DSN = %UPCASE(&DSN);
%LET USE_WEIGHTS = %UPCASE(&USE_WEIGHTS);
%LET BYVARS = %UPCASE(&BYVARS);
%LET ANALVARS = %UPCASE(&ANALVARS);
%LET IMPUTED_VARS = %UPCASE(&IMPUTED_VARS);
%LET XOUTPUT = %UPCASE(&XOUTPUT);
%LET TITLE4 = Consumer Expenditure Survey: Dataset &DSN.;
%LET TITLE5 = Collection year estimates;
%LET TITLE6 = ;
%LET TITLE7 = ;
%LET TITLE8 = ;
%LET TITLE9 = ;

%IF (%SUPERQ(USE_WEIGHTS) = ) %THEN %LET USE_WEIGHTS = NO;
%IF (%SUPERQ(XOUTPUT) = ) %THEN %LET XOUTPUT = NO;

%IF %UPCASE(&USE_WEIGHTS) = YES %THEN %DO;
%PUT WARNING: Weighted Variances, SE, RSE, and related statistics should not be calculated for region of the country. See IMPORTANT NOTE in the documentation.;
%END;

%IF (%SUPERQ(IMPUTATIONS) = ) %THEN %LET IMPUTATIONS = 5;
%IF (%SUPERQ(REP_WT) = ) %THEN %LET REP_WT = 44;

%LET DF = %UPCASE(&DF);
%IF (%SUPERQ(DF) = ) %THEN %LET DF = RUBIN99;

%LET UW = &USE_WEIGHTS.;
%LET DFDEF = &DF.;
%LET FRMT = &FORMAT.;
%LET BY_VAR = %UPCASE(&BYVARS);
%IF (%SUPERQ(ANALVARS) = ) %THEN %LET AVARS = ;
%ELSE %LET AVARS = ANALVARS;
%IF (%SUPERQ(IMPUTED_VARS) = ) %THEN %LET MIVARS = ;
%ELSE %LET MIVARS = IMPUTED_VARS;
%LET MI = &IMPUTATIONS.;
%LET REPLICATES = &REP_WT.;
%LET TIMES = %EVAL(&REPLICATES. + 1); 

%PUT ;
%PUT Reading the dataset.;
	%READ_DATA;
	%PROC_FREQ;

%IF (%SUPERQ(CL) = ) %THEN %DO;
	%LET ALPHA = .025;
	%LET CI = 95% Confidence Intervals;
	%END;
%ELSE %DO;
	%LET ALPHA = (1-.&CL.)/2;
	%LET CI = &CL.% Confidence Intervals;
%END;

%IF (%SUPERQ(IMPUTED_VARS) = ) %THEN %DO;
	%IF %UPCASE(&USE_WEIGHTS) = YES %THEN %DO;
%PUT ;
%PUT Calculate weighted mean and variance for analysis variables;
%PUT &ANALVARS.;
		%WT_MEAN_VARIANCE(ANALVARS=&ANALVARS.);
	%END;
	%ELSE %IF %UPCASE(&USE_WEIGHTS) = NO %THEN %DO;
%PUT ;
%PUT Calculate unweighted mean and variance for analysis variables;
%PUT &ANALVARS.;
		%UNWT_MEAN_VARIANCE(ANALVARS=&ANALVARS.);
		%END;
%END;
%ELSE %DO;
%IF (%SUPERQ(ANALVARS) NE ) %THEN %DO;
/* CALCULATE MEANS AND VARIANCES FOR ANALYSIS VARIABLES */
	%IF %UPCASE(&USE_WEIGHTS) = YES %THEN %DO;
%PUT ;
%PUT Calculate weighted mean and variance for analysis variables;
%PUT &ANALVARS.;
		%WT_MEAN_VARIANCE(ANALVARS=&ANALVARS.);
	%END;
	%ELSE %IF %UPCASE(&USE_WEIGHTS) = NO %THEN %DO;
%PUT ;
%PUT Calculate unweighted mean and variance for analysis variables;
%PUT &ANALVARS.;
		%UNWT_MEAN_VARIANCE(ANALVARS=&ANALVARS.);
		%END;
%END;

/* CALCULATE MEANS AND VARIANCES FOR IMPUTED VARIABLES */
	%IF %UPCASE(&USE_WEIGHTS) = YES %THEN %DO;
%PUT ;
%PUT Calculate weighted mean and variance for multiply imputed variables;
%PUT &IMPUTED_VARS.;
		%WT_MEAN_VARIANCE(ANALVARS=&IMPUTED_VARS.);
		%END;
	%ELSE %IF %UPCASE(&USE_WEIGHTS) = NO %THEN %DO;
%PUT ;
%PUT Calculate unweighted mean and variance for multiply imputed variables;
%PUT &IMPUTED_VARS.;
		%UNWT_MEAN_VARIANCE(ANALVARS=&IMPUTED_VARS.);
		%END;

/*COUNT THE NUMBER OF IMPUTED VARIABLES*/
	%IMPUTED_VARIABLES(&USE_WEIGHTS.);

/* CALCULATE TOTAL VARIANCE FOR IMPUTED VARIABLES */
%PUT ;
%PUT Calculate total variance for multiply imputed data.;
%PUT ;
	%TOT_VAR;
	%TOT_VARS;
%END;

PROC DATASETS NOLIST LIBRARY=WORK;
DELETE TOT_VARS SS;
QUIT;

TITLE;
%MEND;

/* MACRO TO MAKE COMPARISONS BETWEEN BY GROUP LEVELS */
%MACRO COMPARE(GP1, GP2);
%LET GPNAME = GP&GP1._vs_GP&GP2.;
%LET GPDIFF = GP&GP1. -  GP&GP2.;

%IF &UW. = YES %THEN %DO;
/* COUNT NUMBER OF REPLICATE WEIGHTS */
%IF &DSNGPS. = ANALVARS %THEN %DO;
%LET REP_WT = ;
PROC SQL NOPRINT;
 SELECT DFC INTO: REP_WT
 FROM ANALVARS;
QUIT;
%END;
%ELSE %IF &DSNGPS. = IMPUTED_VARS %THEN %DO;
%LET REP_WT = ;
PROC SQL NOPRINT;
 SELECT DFC INTO: REP_WT
 FROM IMPUTEDVARS;
QUIT;
%END;
%LET REP_WT = %LEFT(&REP_WT);
%GLOBAL REPLICATES;
%LET REPLICATES = &REP_WT.;
%GLOBAL TIMES;
%LET TIMES = %EVAL(&REPLICATES + 1); 
%END;

/* BY GROUP COMPARISONS OF NONIMPUTED VARIABLES */
%IF &DSNGPS. = ANALVARS %THEN %DO;
%IF &UW. = YES %THEN %DO;

/* GET THE DIFFERENCE OF THE MEANS */
DATA TY1(KEEP=_NAME_ &GPNAME.);
SET TYAV;
&GPNAME. = &GPDIFF.;
RUN;

PROC SORT DATA = TY1;
BY _NAME_;
RUN;

/* TRANSPOSE THE VARIABLE GP&GP1._vs_GP&GP2. */
PROC TRANSPOSE DATA=TY1 PREFIX=diff OUT=TYS;
by _name_;
var &GPNAME.;
RUN;

DATA TYS;
ATTRIB _NAME_ LENGTH=$40;
ATTRIB Compare_Means LENGTH=$20;
SET TYS;
Compare_Means="&GPNAME.";
RUN;

PROC APPEND BASE=TY2 DATA=TYS FORCE;
RUN;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE TYS TY1;
QUIT;
%END;

%ELSE %IF &UW. = NO %THEN %DO; 
%IF &BYV. = 1 %THEN %DO; 
DATA MYTTEST;
SET MYDATA;
ALPHA2=2*&ALPHA.;
IF GROUP = &GP1. THEN &BYVARS._ = &GP1.;
ELSE IF GROUP = &GP2. THEN &BYVARS._ = &GP2.;
RUN;
%END;
%ELSE %DO;
DATA MYTTEST;
set MYDATA;
ALPHA2=2*&ALPHA.;
IF GROUP = &GP1. THEN Groups = &GP1.;
ELSE IF GROUP = &GP2. THEN Groups = &GP2.;
RUN;
%END;

%LET TTESTVARS = ;

PROC SQL NOPRINT;
 SELECT _NAME_ INTO: TTESTVARS SEPARATED BY ' '
 FROM TYAV;
QUIT;

%LET ALPHA2 = ;

PROC SQL NOPRINT;
 SELECT DISTINCT ALPHA2 INTO: ALPHA2
 FROM MYTTEST;
QUIT;

%IF &BYV. = 1 %THEN %DO; 
/* RUN PROC TTEST TO GET STATS FOR DIFFERENCE OF THE MEANS */
PROC TTEST DATA= MYTTEST ALPHA=&ALPHA2.;
	TITLE1 &TITLE1.;
	TITLE2 &TITLE2.;
	TITLE3 &TITLE3.;
	TITLE4 "Consumer Expenditure Survey";
	TITLE5 "Compare MEANS between GROUPS of variable &BYVARS.";
    TITLE6 "For unweighted data";
    TITLE7 "ALPHA =&ALPHA2.";
  CLASS &BYVARS._;
  VAR &TTESTVARS.;
RUN;
%END;
%ELSE %DO;
/* RUN PROC TTEST TO GET STATS FOR DIFFERENCE OF THE MEANS */
PROC TTEST DATA= MYTTEST ALPHA=&ALPHA2.;
	TITLE1 &TITLE1.;
	TITLE2 &TITLE2.;
	TITLE3 &TITLE3.;
	TITLE4 "Consumer Expenditure Survey";
	TITLE5 "Compare MEANS between GROUPS of variable &BYVARS.";
    TITLE6 "For unweighted data";
    TITLE7 "ALPHA =&ALPHA2.";
  CLASS GROUPS;
  VAR &TTESTVARS.;
RUN;
%END;
%END;
%END;

/* BY GROUP COMPARISONS OF IMPUTED VARIABLES */
%IF &DSNGPS. = IMPUTED_VARS %THEN %DO;
%IF &UW. = YES %THEN %DO;

/* GET THE DIFFERENCE OF THE MEANS */
DATA TY1(KEEP=VARIABLE VARIABLE1 _NAME_ &GPNAME.);
SET TY4WM;
&GPNAME. = &GPDIFF.;
RUN;

PROC SORT DATA=TY1;
BY VARIABLE1 VARIABLE;
RUN;

PROC TRANSPOSE DATA=TY1 prefix=diff OUT=TYS;
BY VARIABLE1 VARIABLE;
var &GPNAME.;
RUN;

data TYS;
set TYS;
  ARRAY diff(&REPLICATES.) diff1-diff&REPLICATES.;
  ARRAY SQDIFF(&REPLICATES.) SQDIFF1-SQDIFF&REPLICATES.;
    DO I = 1 TO &REPLICATES.;
      SQDIFF(I) = (diff(I) - diff&TIMES.)**2;
      DROP I; 
    END; 
  MEAN = diff&TIMES.;
  REPLICATES = &REPLICATES.;
  VARIANCE = SUM(OF SQDIFF(*))/REPLICATES;
  SE = SQRT(VARIANCE); 
  DFC = &REPLICATES.;
run;

DATA TYS
	(KEEP=variable1 VARIABLE _name_ MEAN VARIANCE SE DFC);
RETAIN variable1 VARIABLE _name_ MEAN SE VARIANCE DFC; 
SET TYS;
RUN;

PROC TRANSPOSE DATA=TYS OUT=TM PREFIX=MEAN;
VAR MEAN;
by variable1;
RUN;

PROC TRANSPOSE DATA=TYS OUT=TV PREFIX=VAR;
VAR VARIANCE;
by variable1;
RUN;

DATA TALL(DROP=_NAME_  VARIABLE1);
ATTRIB Compare_Means LENGTH=$25.;
MERGE TM TV;
Compare_Means="&GPNAME.";
Variable=VARIABLE1;
RUN;

PROC APPEND BASE=TY2 DATA=TALL FORCE;
RUN;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE TY1 TYS TM TV TALL;
QUIT;
%END;

%ELSE %IF &UW. = NO %THEN %DO;
/* GET T_STATS FOR THE DIFFERENCE OF THE MEANS */
DATA TY1;
SET TY4UNWM;
RUN;

PROC SORT DATA=TY1;
BY VARIABLE &BYVARS.;
RUN;

PROC TRANSPOSE DATA=TY1 PREFIX=VAR OUT=ZSCY;
BY VARIABLE;
VAR TVAR;
RUN;

PROC TRANSPOSE DATA=TY1 PREFIX=MEAN OUT=ZSCZ;
BY VARIABLE;
VAR MEAN_MEANS;
RUN;

%IF &DFDEF. = RUBIN87 %THEN  %DO;
PROC TRANSPOSE DATA=TY1 PREFIX=DF OUT=ZSCDF;
BY VARIABLE;
VAR  DFM;
RUN;
%END;
%ELSE %IF &DFDEF. = RUBIN99 %THEN  %DO;
PROC TRANSPOSE DATA=TY1 PREFIX=DF OUT=ZSCDF;
BY VARIABLE;
VAR  DDF;
RUN;
%END;
/* CALCULATE THE T_STAT VALUES */
DATA ZSALL(keep=VARIABLE COMPARE_MEANS DIFF_MEANS VAR_MEANS DF_DIFF_MEANS);
MERGE ZSCY ZSCZ ZSCDF;
BY VARIABLE;
ATTRIB Compare_Means LENGTH=$20;
Compare_Means="GP&GP1._vs_GP&GP2.";
Diff_Means = MEAN&GP1. - MEAN&GP2.;
Var_Means = VAR&GP1. + VAR&GP2.;
DF_Diff_Means = DF&GP1. + DF&GP2.;
RUN;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE TY1 ZSCY ZSCZ ZSCDF;
QUIT;

PROC APPEND BASE=TY2 DATA=ZSALL FORCE;
RUN;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE ZSALL;
QUIT;
%END;
%END;
%MEND;

%MACRO TEST(BYVARS);
%LET TITLE4 = Consumer Expenditure Survey;
%LET TITLE5 = Compare MEANS between GROUPS of variable &BYVARS.;

/* BY GROUP COMPARISONS OF NONIMPUTED VARIABLES */
%IF &DSNGPS. = ANALVARS %THEN %DO;
%IF &UW. = YES %THEN %DO;
%LET TITLE6 = Using the BRR method of variance estimation;
/* CALCULATE SE, T VALUE, F VALUE, AND P VALUE FOR THE F_TEST */
DATA COMPARE_&DSNGPS.;
  SET TY2;
  Variable = _NAME_;
  REPLICATES = &REPLICATES.;
  ARRAY diffs(&REPLICATES.) diff1-diff&REPLICATES.;
  ARRAY SQDIFF(&REPLICATES.) SQDIFF1-SQDIFF&REPLICATES.;
    DO I = 1 TO &REPLICATES.;
      SQDIFF(I) = (diffs(I) - diff&TIMES.)**2;
      DROP I; 
    END; 
  Diff_Means = diff&TIMES.;
  SE_Diff_Means = SQRT( SUM(OF SQDIFF(*))/REPLICATES ); /* HORIZONTAL SUM */
  IF SE_Diff_Means NE 0 THEN TValue = Diff_Means/SE_Diff_Means;
  ELSE TValue = .;
  F_Test=TVALUE*TVALUE;
  P_Value=1-PROBF(F_TEST,1,REPLICATES);
  DF_Diff_Means = &REPLICATES.;
RUN;

PROC SORT DATA=COMPARE_&DSNGPS.;
BY _NAME_;
RUN;

DATA COMPARE_&DSNGPS.(KEEP=VARIABLE COMPARE_MEANS DIFF_MEANS SE_DIFF_MEANS DF_DIFF_MEANS TVALUE P_VALUE);
SET COMPARE_&DSNGPS.;
RUN;

PROC SORT DATA=COMPARE_&DSNGPS.;
BY VARIABLE COMPARE_MEANS;
RUN;

/* PRINT FINAL OUTPUT DATASET */
PROC PRINT DATA=COMPARE_&DSNGPS.;
	TITLE1 &TITLE1.;
	TITLE2 &TITLE2.;
	TITLE3 &TITLE3.;
	TITLE4 &TITLE4.;
	TITLE5 &TITLE5.;
	TITLE6 &TITLE6.;
ID VARIABLE ;
VAR COMPARE_MEANS DIFF_MEANS SE_DIFF_MEANS DF_DIFF_MEANS TVALUE P_VALUE;
RUN;

/* DELETE APPEND DATASETS */
PROC DATASETS LIBRARY=WORK NOLIST;
DELETE TY2;
QUIT;
%END;
%END;

/* BY GROUP COMPARISONS OF IMPUTED VARIABLES */
%IF &DSNGPS. = IMPUTED_VARS %THEN %DO;
%IF &UW. = YES %THEN %DO;
%LET TITLE6 = Using the BRR method of variance estimation;

/* COUNT NUMBER OF IMPUTATIONS */
%LET MI = ;
PROC SQL NOPRINT;
 SELECT MI INTO: MI
 FROM IMPUTEDVARS;
QUIT;
%LET MI = %LEFT(&MI);

DATA COMPARE_&DSNGPS.(DROP=MEAN1-MEAN&MI. VAR1-VAR&MI. SUMSQRD);
SET TY2;
MI = &MI.;
ADJ = 1 + (1/MI);

* DEGREES OF FREEDOM ; 
DFC = &REPLICATES.;
* MEAN OF THE DIFFERENCE OF THE MEANS ;
Mean_Means=MEAN(OF MEAN1-MEAN&MI.);
* MEAN OF THE VARIANCE ; 
Mean_Vars=MEAN(OF VAR1-VAR&MI.);
SUMSQRD=0;
%DO I=1 %TO &MI.;
    SUMSQRD=SUM(SUMSQRD,((MEAN&I.-MEAN_MEANS)**2));
%END;
* VARIANCE OF THE MEANS ;
Var_Means=SUMSQRD/(MI - 1);
/* Total variance formula */
/* T = Mean of the variances + [(1+(1/MI))*Variance of the means] */
TVAR = MEAN_VARS + (ADJ*VAR_MEANS);
SE_Diff_Means = SQRT(TVAR);

ALPHA = &ALPHA.;  

IF SE_Diff_Means NE 0 THEN TValue = Mean_Means/SE_Diff_Means;
ELSE TValue = .;

F_Test = TVALUE*TVALUE;

/* MEAN_MEANS IS THE DIFFERENCE OF THE MEANS OF THE IMPUTED VARIABLES */
Diff_Means = MEAN_MEANS;

/* DF from RUBINS book 1987, page 77*/
RM = (ADJ*VAR_MEANS)/MEAN_VARS;
DFM = (MI - 1)*(1+(1/RM))**2;

/* What definition to use? Rubin87(DFM) or Rubin99(DDF)*/
%IF &DFDEF. = RUBIN87 %THEN DDF = DFM;
%ELSE %IF &DFDEF. = RUBIN99 %THEN %DO;
/* DF from SUDAAN Language manual, page 89 Rubin definition 1999*/
/* DFC = DEGREES OF FREEDOM OF COMPLETE DATASET */
/* VDF [(DFC+1 / DFC+3)]*[(1- [(MI+1)*VAR_MEANS]/MI*TVAR)]*DFC */
/* DDF = 1/ [(1/DFC) + (1/VDF)]*/
  VDF = ((DFC+1)/(DFC+3))*(1-(((MI+1)*VAR_MEANS)/(MI*TVAR)))*DFC;
  DDF = 1/((1/DFM)+(1/VDF)); 
  %END;;

    P_Value=1-PROBF(F_TEST,1,DDF);
	/* ROUND DF */
	DF_Diff_Means = ROUND(DDF,1);
RUN;
%END;

%ELSE %DO;
%LET TITLE6 = For unweighted data;
DATA COMPARE_&DSNGPS.;
SET TY2;
SE_Diff_Means = SQRT(VAR_MEANS);
  ALPHA = &ALPHA.;  

/* MEAN_MEANS IS THE DIFFERENCE OF THE MEANS OF THE IMPUTED VARIABLES */
  IF SE_Diff_Means NE 0 THEN TValue = Diff_Means/SE_Diff_Means;
  ELSE TValue = .;

  F_Test = TVALUE*TVALUE;

	DDF = DF_Diff_Means;
    P_Value=1-PROBF(F_TEST,1,DDF);
	/* ROUND DF */
	DF_Diff_Means = ROUND(DDF,1);
RUN;
%END;

PROC SORT DATA=COMPARE_&DSNGPS.;
BY VARIABLE COMPARE_MEANS;
RUN;

%IF &DFDEF. = RUBIN99 %THEN 
	%LET TITLE7 = Degrees of Freedom: Barnard & Rubin (1999) definition;
    %ELSE %IF &DFDEF. = RUBIN87 %THEN 
    %LET TITLE7 = Degrees of Freedom: Rubin (1987) definition;

/* PRINT FINAL OUTPUT DATASET */
PROC PRINT DATA=COMPARE_&DSNGPS.;
	TITLE1 &TITLE1.;
	TITLE2 &TITLE2.;
	TITLE3 &TITLE3.;
	TITLE4 &TITLE4.;
	TITLE5 "Compare MEANS of Imputed data between GROUPS of variable &BYVARS.";
	TITLE6 &TITLE6.;
	TITLE7 &TITLE7.;
ID VARIABLE ;
VAR COMPARE_MEANS DIFF_MEANS SE_DIFF_MEANS DF_DIFF_MEANS TVALUE P_VALUE;
RUN;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE ZSCS;
QUIT;
%END;

/* DELETE APPEND DATASETS */
PROC DATASETS LIBRARY=WORK NOLIST;
DELETE TY2;
QUIT;
%MEND;

/*********************************************************************/
/* MACRO COMPARE_GROUPS                                              */
/*********************************************************************/
/****************************************************************/
/* GPS:          GROUPS TO BE COMPARE					        */
/* TITLE1:  	 TITLE 1 FOR OUTPUT							    */
/* TITLE2:  	 TITLE 2 FOR OUTPUT							    */
/* TITLE3:  	 TITLE 3 FOR OUTPUT							    */
/****************************************************************/
/****************************************************************/
/* COMPARE MEANS OF GROUPS OF BY VARIABLE                       */
/* FOR WEIGHTED OR UNWEIGHTED DATA							    */
/****************************************************************/

%MACRO COMPARE_GROUPS(GPS = ,
			       TITLE1 = ,
			       TITLE2 = ,
			       TITLE3 = );

OPTIONS PAGENO=1 NOCENTER;
 
%LET GPS = %UPCASE(&GPS);

%LET FROM = &AVARS. &MIVARS.;
%LET BYVARS = &BY_VAR.;

%COUNT_VARS(&FROM.,DELIM=%STR( ));
	%LET F_GPS = &N_VARS.;
		%DO FG=1 %TO &F_GPS.;
		    %LET DSNGPS = %SCAN(&FROM., &FG, ' ');

%PUT ;
%IF &DSNGPS. = ANALVARS %THEN 
%PUT Compare groups of ANALVARS; 
%ELSE %PUT Compare groups of IMPUTED_VARS.;;

%COUNT_VARS(&GPS.,DELIM=%STR( ));
	%LET C_GPS = &N_VARS.;
		%DO CG=1 %TO &C_GPS. %BY 2;
			%LET GP1 = %SCAN(&GPS., &CG, ' ');
			%LET CG2 = %EVAL(&CG + 1);
			%LET GP2 = %SCAN(&GPS., &CG2, ' ');
		%PUT ;
		%PUT Compare &GP1. and &GP2..;
			%COMPARE(&GP1., &GP2.);
		%END;
	%TEST(&BYVARS.);
%END;

TITLE;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE MYTTEST;
QUIT;
%MEND;


/**********************************************************************/
/* THE MACRO WT_PROC_REG PERFORM OLS REGRESSIONS                      */
/* PERFORM WEIGHTED REGRESSIONS USING BRR                             */
/**********************************************************************/
%MACRO WT_PROC_REG;
%GLOBAL DVAR;
%LET DVAR=%SCAN(&DVARS, &N_DV, ' ');
%PUT dependent variable &DVAR..;

* SPECIFY SORTING ORDER IF BY VARIABLES PRESENT;
%IF (%SUPERQ(BYVARS) NE ) %THEN %DO;
PROC SORT DATA=MYDATA;
BY &BYVARS.;
RUN;
%END;

/* RUN REGRESSION ON FINLWT21 TO GET SOME GENERAL STATISTICS */
ODS LISTING CLOSE;
ODS OUTPUT ANOVA=AT (KEEP = &BYVARS. DF SOURCE)
			FITSTATISTICS=FS (KEEP=&BYVARS. LABEL1 CVALUE1 LABEL2 CVALUE2)
			; 
PROC REG  DATA=MYDATA;
BY &BYVARS.;
 WEIGHT FINLWT21;
 MODEL &DVAR. = &IVARS.;
 TITLE ;
RUN;
ODS LISTING;

%LOCAL DSID RC VARNUM;
%GLOBAL RS DM SS;

/* GET THE R_SQUARE AND THE DEPENDENT MEAN */
/* FORM THE FIT STATISTICS DATASET */
/* VALUE IS A CHARACTER VARIABLE */
DATA FS(KEEP=&BYVARS. VALUE LABEL);
ATTRIB VALUE LENGTH=$16.4;
SET FS;
IF LABEL1="Coeff Var" THEN DELETE;
IF LABEL1="Dependent Mean" THEN 
	DO;
		VALUE=CVALUE1;
		LABEL="DM";
	END;
IF LABEL2="R-Square" THEN 
	DO;
		VALUE=CVALUE2;
		LABEL="RS";
	END;
RUN;

%LET DSID=%SYSFUNC(OPEN(FS,IS));

%DO OBS=1 %TO 2;
%LET VARNUM=%SYSFUNC(VARNUM(&DSID,LABEL));
%LET RC=%SYSFUNC(FETCHOBS(&DSID,&OBS));
%LET LBL=%SYSFUNC(GETVARC(&DSID,&VARNUM));

%LET VARNUM=%SYSFUNC(VARNUM(&DSID,VALUE));
%LET RC=%SYSFUNC(FETCHOBS(&DSID,&OBS));

%IF &LBL=RS %THEN %LET RS=%SYSFUNC(GETVARC(&DSID, &VARNUM));
%IF &LBL=DM %THEN %LET DM=%SYSFUNC(GETVARC(&DSID, &VARNUM));
%END;

%LET RC=%SYSFUNC(CLOSE(&DSID));

/* GET THE SAMPLE SIZE FROM THE ANOVA TABLE DATASET */
/* VALUE IS A NUMERIC VARIABLE */
DATA AT(KEEP=&BYVARS. VALUE LABEL);
SET AT;
IF SOURCE="Error" OR SOURCE="Model" THEN DELETE;
IF SOURCE="Corrected Total" THEN 
	DO;
		LABEL="SS";
		VALUE=DF + 1;
	END;
RUN;

%LET DSID=%SYSFUNC(OPEN(AT,IS));
%LET OBS=1;
%LET VARNUM=%SYSFUNC(VARNUM(&DSID,LABEL));
%LET RC=%SYSFUNC(FETCHOBS(&DSID,&OBS));
%LET LBL=%SYSFUNC(GETVARC(&DSID,&VARNUM));

%LET VARNUM=%SYSFUNC(VARNUM(&DSID,VALUE));
%LET RC=%SYSFUNC(FETCHOBS(&DSID,&OBS));
%IF &LBL=SS %THEN %LET SS=%SYSFUNC(GETVARN(&DSID, &VARNUM));

%LET RC=%SYSFUNC(CLOSE(&DSID));

* GET SOME STATISTICS IF BY VARIABLES PRESENT;
%IF (%SUPERQ(BYVARS) NE ) %THEN %DO;
PROC TRANSPOSE DATA=fs OUT=fs;
id label;
BY &BYVARS.;
  VAR value ;
RUN;

data at(rename=(value=SS));
set at(keep=&BYVARS. value);
run;

data stats;
merge at fs(drop=_NAME_);
BY &BYVARS.;
run;
%END;

ODS LISTING CLOSE;
/* RUN THE REGRESSION (NUMBER OF REPLICATES + 1) TIMES */
%DO I = 1 %TO &TIMES.;
/* KEEP THE INTERCEPT AND ALL THE VARIABLES IN YOUR MODEL STATEMENT */
PROC REG  DATA=MYDATA NOPRINT OUTEST=REG&I(KEEP=&BYVARS. INTERCEPT &IVARS.);
BY &BYVARS.;
WEIGHT WTREP&I;
 MODEL &DVAR. = &IVARS.;
RUN;

PROC APPEND BASE=PARAMS1 DATA=REG&I FORCE;
RUN;
%END;
ODS LISTING;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE REG1-REG&TIMES. AT FS ;
QUIT;

DATA PARAMS;
SET PARAMS1;
RUN;

* SPECIFY SORTING ORDER IF BY VARIABLES PRESENT;
%IF (%SUPERQ(BYVARS) NE ) %THEN %DO;
PROC SORT DATA=PARAMS;
BY &BYVARS.;
RUN;
%END;

DATA PARAMS_&DVAR.;
SET PARAMS;
RUN;

/* TRANSPOSE THE INTERCEPT, AND ALL THE VARIABLES IN YOUR MODEL STATEMENT */
PROC TRANSPOSE DATA=PARAMS PREFIX=COEFF OUT=TPARAMS;
BY &BYVARS.;
  VAR INTERCEPT &IVARS.;
RUN;

/* CALCULATE SE, T VALUE, AND P VALUE FOR THE T_TEST */
DATA A(KEEP=&BYVARS. PARAMETER COEFF SE TVALUE PVALUE DFC);
  SET TPARAMS;
  PARAMETER = _NAME_;
  ARRAY PARMS(&REPLICATES.) COEFF1-COEFF&REPLICATES.;
  ARRAY SQDIFF(&REPLICATES.) SQDIFF1-SQDIFF&REPLICATES.;
    DO I = 1 TO &REPLICATES.;
      SQDIFF(I) = (PARMS(I) - COEFF&TIMES.)**2;
    END; 
  COEFF = COEFF&TIMES.;
  REPLICATES = &REPLICATES.;
  DFC=&REPLICATES.;
  SE = SQRT( SUM(OF SQDIFF(*))/REPLICATES ); /* HORIZONTAL SUM */
  IF SE GT 0 THEN TVALUE = COEFF/SE;
  ELSE TVALUE = 0;
  PVALUE=(1-PROBT(ABS(TVALUE),REPLICATES))*2; /* DF=REPLICATES*/
RUN;

%IF (%SUPERQ(XOUTPUT) = YES) OR (%SUPERQ(IMPUTED_VARS) = ) %THEN %DO;
%IF (%SUPERQ(BYVARS) NE ) %THEN %DO;
%IF (%SUPERQ(XOUTPUT) = YES) %THEN 
	%LET TITLE9 = "            Independent variables: %EVAL(&IVS. - 1)";
	%ELSE %LET TITLE9 = "            Independent variables: &IV.";;
PROC PRINT DATA=STATS SPLIT='*' UNIFORM;
  TITLE1 &TITLE1.;
  TITLE2 &TITLE2.;
  TITLE3 &TITLE3.;
  TITLE4 "The REG Procedure using replicate weights" ;
  TITLE5 "Balanced Repeated Replication (BRR) method" ;
  TITLE6 "Regression on Dataset &DSN. for Dependent Variable: &DVAR.";
  TITLE7 ;
  TITLE8 "   Denominator degrees of freedom: &REPLICATES.";
  TITLE9 &TITLE9.;
ID &BYVARS.;
LABEL 
	SS = "   Sample*     size"
	RS = " R-Square"
	DM = "Dependent*     mean"
    ;
run;

PROC PRINT DATA=A SPLIT='*' UNIFORM;
BY &BYVARS.;
  TITLE1 &TITLE1.;
  TITLE2 &TITLE2.;
  TITLE3 &TITLE3.;
  TITLE4 "The REG Procedure using replicate weights" ;
  TITLE5 "Balanced Repeated Replication (BRR) method" ;
  TITLE6 "Regression on Dataset &DSN. for Dependent Variable: &DVAR.";
  TITLE7 ;
  TITLE8 "                           Parameter Estimates";

VAR COEFF SE TVALUE PVALUE;
ID PARAMETER;
LABEL 
	Parameter = "Variable   "
	Coeff     = "Parameter *Estimate "
	SE        = "Standard  * Error  "
	tvalue    = "t Value"
	pvalue    = "Pr > |t|"
    ;
RUN;
%END;
%ELSE %DO;
%IF (%SUPERQ(XOUTPUT) = YES) %THEN 
	%LET TITLE8 = "            Independent variables: %EVAL(&IVS. - 1)";
	%ELSE %LET TITLE8 = "            Independent variables: &IV.";;
PROC PRINT DATA=A SPLIT='*' UNIFORM;
  TITLE1 &TITLE1.;
  TITLE2 &TITLE2.;
  TITLE3 &TITLE3.;
  TITLE4 "The REG Procedure using replicate weights, BRR method";
  TITLE5 "Regression on Dataset &DSN. for Dependent Variable: &DVAR.";
  TITLE6 "                         R-Square: &RS.        Dependent mean: &DM.";
  TITLE7 "   Denominator degrees of freedom: &REPLICATES.               Sample size: &SS." ;
  TITLE8 &TITLE8.;
  TITLE9 "                           Parameter Estimates";

VAR COEFF SE TVALUE PVALUE;
ID PARAMETER;
LABEL 
	Parameter = "Variable   "
	Coeff     = "Parameter *Estimate "
	SE        = "Standard  * Error  "
	tvalue    = "t Value"
	pvalue    = "Pr > |t|"
    ;
RUN;
%END;
%END;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE TPARAMS PARAMS1 PARAMS STATS;
QUIT;
%MEND;

/***************************************************************************/
/* THE MACRO UNWT_PROC_REG PERFORM OLS REGRESSIONS FOR UNWEIGHTED DATA     */
/***************************************************************************/
%MACRO UNWT_PROC_REG;
%GLOBAL DVAR;
%LET DVAR=%SCAN(&DVARS, &N_DV, ' ');
%PUT dependent variable &DVAR..;
%PUT ;

* SPECIFY SORTING ORDER IF BY VARIABLES PRESENT;
%IF (%SUPERQ(BYVARS) NE ) %THEN %DO;
PROC SORT DATA=MYDATA;
BY &BYVARS.;
RUN;
%END;

%IF (%SUPERQ(XOUTPUT) = YES) AND (%SUPERQ(IMPUTED_VARS) NE ) %THEN %DO;
PROC REG  DATA=MYDATA;
BY &BYVARS.;
TITLE1 &TITLE1.;
TITLE2 &TITLE2.;
TITLE3 &TITLE3.;
TITLE4 "Consumer Expenditure Survey";
TITLE5 "Regression on Dataset &DSN. for Dependent Variable: &DVAR.";
TITLE6 "Unweighted data";
 MODEL &DVAR. = &IVARS.;
QUIT;
%END;

%IF (%SUPERQ(IMPUTED_VARS) = ) %THEN %DO;
PROC REG  DATA=MYDATA;
BY &BYVARS.;
TITLE1 &TITLE1.;
TITLE2 &TITLE2.;
TITLE3 &TITLE3.;
TITLE4 "Consumer Expenditure Survey";
TITLE5 "Regression on Dataset &DSN. for Dependent Variable: &DVAR.";
TITLE6 "Unweighted data";
 MODEL &DVAR. = &IVARS.;
 		&TEST01.;
 		&TEST02.;
 		&TEST03.;
 		&TEST04.;
 		&TEST05.;
 		&TEST06.;
 		&TEST07.;
 		&TEST08.;
 		&TEST09.;
QUIT;
%END;

%ELSE %DO;
/* KEEP THE INTERCEPT AND ALL THE VARIABLES IN YOUR MODEL STATEMENT */
ODS LISTING CLOSE;
ODS OUTPUT PARAMETERESTIMATES=PE(KEEP=&BYVARS. VARIABLE ESTIMATE STDERR )
	       ANOVA = SS(KEEP = &BYVARS. SOURCE DF)
			;
PROC REG DATA=MYDATA;
 BY &BYVARS.;
 MODEL &DVAR. = &IVARS.;
QUIT;
ODS LISTING;

DATA SS(KEEP=&BYVARS. SS COUNT);
SET SS;
COUNT=1;
SS=DF+1;
IF SOURCE = 'Corrected Total' THEN OUTPUT SS;
RUN;

DATA A(KEEP=&BYVARS. PARAMETER COEFF SE COUNT);
SET PE;
COEFF=ESTIMATE;
PARAMETER=VARIABLE;
SE=STDERR;
COUNT=1;
RUN;

PROC SORT DATA=A;
BY COUNT &BYVARS.;
RUN;

PROC SORT DATA=SS;
BY COUNT &BYVARS.;
RUN;

DATA A;
MERGE A SS;
BY COUNT &BYVARS.; 
RUN;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE PE SS;
QUIT;
%END;
%MEND;

/**********************************************************************/
/* THE MACRO LOGISTIC_OPTIONS GET OPTIONS FOR THE LOGISTIC MACROS     */
/**********************************************************************/
%MACRO LOGISTIC_OPTIONS;
OPTIONS NOSERROR;

%GLOBAL DVAR;
%LET DVAR=%SCAN(&DVARS, &N_DV, ' ');

* SPECIFY SORTING ORDER IF BY VARIABLES PRESENT;
%IF (%SUPERQ(BYVARS) NE ) %THEN %DO;
PROC SORT DATA=MYDATA;
BY &BYVARS.;
RUN;
%END;

* GET THE LEVELS OF THE DEPENDENT VARIABLE;
PROC FREQ DATA=MYDATA NOPRINT;
TABLES &DVAR. /OUT=LEVELS ;
RUN;

%LOCAL DSID RC;
%GLOBAL LEVELS;
%LET DSID=%SYSFUNC(OPEN(LEVELS));
%LET LEVELS =%SYSFUNC(ATTRN(&DSID,NOBS));
%LET RC=%SYSFUNC(CLOSE(&DSID));

%PUT response variable &DVAR. has &LEVELS. levels.;
%PUT ;

* SPECIFY THE SORTING ORDER FOR THE LEVELS OF THE RESPONSE VARIABLE ;
%GLOBAL OPTIONS;
%IF (%SUPERQ(SORT_ORDER) = ) %THEN %DO;
		%IF &LEVELS. = 2 %THEN %LET OPTIONS = DESCENDING;
		%ELSE %IF &LEVELS. GT 2 %THEN %LET OPTIONS = ORDER=INTERNAL;
		%PUT The macro will assign the default sorting order to the;
    	%PUT Response variable &DVAR.: SORT_ORDER is &OPTIONS.. ;
		%PUT ;
	%END;
%ELSE %DO;
		%LET OPTIONS = ORDER=&SORT_ORDER; 
		%PUT SORT_ORDER for the Response variable &DVAR. is &OPTIONS.. ;
		%PUT ;
      %END;

* FOR TWO LEVEL DEPENDENT VARIABLE (0,1);
* PROC LOGISTIC is modeling the probability that DEPENDENT VARIABLE='1';

* FOR MORE THAN TWO LEVELS DEPENDENT VARIABLE;
* THE OPTIONS FOR ORDER ARE INTERNAL, FORMATTED, DATA, FREQ ;

* DATA = ORDER OF APPEARANCE IN THE INPUT DATA SET;
* FREQ = DESCENDING FREQUENCY COUNT, LEVELS WITH THE 
	MOST OBSERVATIONS COME FIRST IN THE ORDER;
* INTERNAL = UNFORMATTED VALUE;
* FORMATTED = EXTERNAL FORMATTED VALUE, EXCEPT FOR 
	NUMERIC VARIABLES WITH NO EXPLICIT FORMAT, WHICH
	ARE SORTED BY THE UNFORMATTED (INTERNAL) VALUE;

* READ THE INDEPENDENT CLASSIFICATION VARIABLES AND SORTING OPTIONS;
* IF ANY, FOR THE CLASS STATEMENT IN THE LOGISTIC PROCEDURE;
%GLOBAL CLASS;
%IF (%SUPERQ(CLASSVARS) = ) %THEN %LET CLASS= ;
	%ELSE %LET CLASS=&CLASSVARS; 
%MEND;

/**********************************************************************/
/* THE MACRO WT_PROC_LOGISTIC PERFORM LOGISTIC REGRESSIONS            */
/* default for SAS technique=Fisher                                   */
/**********************************************************************/
%MACRO WT_PROC_LOGISTIC;
/* RUN MACRO LOGISTIC_OPTIONS */
%LOGISTIC_OPTIONS;

/* RUN REGRESSION ON FINLWT21 TO GET SOME GENERAL STATISTICS */
%IF (%SUPERQ(XOUTPUT) = YES) OR (%SUPERQ(IMPUTED_VARS) = ) %THEN %DO;
%IF (%SUPERQ(XOUTPUT) = YES) %THEN 
	%LET TITLE9 = "         Independent variables: %EVAL(&IVS. - 1)";
	%ELSE %LET TITLE9 = "         Independent variables: &IV.";;
ODS SELECT MODELINFO RESPONSEPROFILE CONVERGENCESTATUS;
PROC LOGISTIC DATA=MYDATA &OPTIONS.;
BY &BYVARS.;
 WEIGHT FINLWT21;
 CLASS &CLASS.;
 MODEL &DVAR. = &IVARS./technique=Fisher;
  TITLE1 &TITLE1.;
  TITLE2 &TITLE2.;
  TITLE3 &TITLE3.;
  TITLE4 "The LOGISTIC Procedure using replicate weights" ;
  TITLE5 "Balanced Repeated Replication (BRR) method" ;
  TITLE6 "Dataset &DSN. = WORK.MYDATA";
  TITLE7 ;
  TITLE8 "Denominator degrees of freedom: &REPLICATES.";
  TITLE9 &TITLE9.;
RUN;
%END;

ODS LISTING CLOSE;
/* RUN THE REGRESSION (NUMBER OF REPLICATEWS + 1) TIMES */
%DO I = 1 %TO &TIMES.;
/* KEEP THE INTERCEPT AND ALL THE VARIABLES IN YOUR MODEL STATEMENT */
PROC LOGISTIC DATA=MYDATA NOPRINT &OPTIONS. OUTEST=REG&I;
BY &BYVARS.;
 WEIGHT WTREP&I;
 CLASS &CLASS.;
 MODEL &DVAR. = &IVARS./technique=Fisher;
RUN;

PROC APPEND BASE=PARAMS1 DATA=REG&I FORCE;
RUN;
%END;
ODS LISTING;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE REG1-REG&TIMES. LEVELS;
QUIT;

DATA PARAMS(DROP=_LNLIKE_);
SET PARAMS1;
RUN;

* SPECIFY SORTING ORDER IF BY VARIABLES PRESENT;
%IF (%SUPERQ(BYVARS) NE ) %THEN %DO;
PROC SORT DATA=PARAMS;
BY &BYVARS.;
RUN;
%END;

DATA PARAMS_&DVAR.;
SET PARAMS;
RUN;

/* TRANSPOSE THE INTERCEPT, AND ALL THE VARIABLES IN YOUR MODEL STATEMENT */
PROC TRANSPOSE DATA=PARAMS PREFIX=COEFF OUT=TPARAMS;
BY &BYVARS.;
RUN;

/* CALCULATE SE, T VALUE, AND P VALUE FOR THE T_TEST */
DATA A(KEEP=&BYVARS. PARAMETER COEFF DFC SE TVALUE PVALUE CHISQ CHIVALUE);
  SET TPARAMS;
  PARAMETER = _NAME_;
  ARRAY PARMS(&REPLICATES.) COEFF1-COEFF&REPLICATES.;
  ARRAY SQDIFF(&REPLICATES.) SQDIFF1-SQDIFF&REPLICATES.;
    DO I = 1 TO &REPLICATES.;
      SQDIFF(I) = (PARMS(I) - COEFF&TIMES.)**2;
    END; 
  COEFF = COEFF&TIMES.;
  DFC = &REPLICATES.;
  REPLICATES = &REPLICATES.;
  SE = SQRT( SUM(OF SQDIFF(*))/REPLICATES ); /* HORIZONTAL SUM */
  IF SE GT 0 THEN TVALUE = COEFF/SE;
  ELSE TVALUE = 0;
  PVALUE=(1-PROBT(ABS(TVALUE),REPLICATES))*2; /* DF=REPLICATES */
  CHISQ=TVALUE*TVALUE;
  CHIVALUE=1-PROBCHI(CHISQ,1); /* DF = 1 */
RUN;

%IF (%SUPERQ(XOUTPUT) = YES) OR (%SUPERQ(IMPUTED_VARS) = ) %THEN %DO;
%IF (%SUPERQ(XOUTPUT) = YES) %THEN 
	%LET TITLE8 = "         Independent variables: %EVAL(&IVS. - 1)";
	%ELSE %LET TITLE8 = "         Independent variables: &IV.";;
PROC PRINT DATA=A SPLIT='*' UNIFORM;
  TITLE1 &TITLE1.;
  TITLE2 &TITLE2.;
  TITLE3 &TITLE3.;
  TITLE4 "The LOGISTIC Procedure using replicate weights" ;
  TITLE5 "Balanced Repeated Replication (BRR) method" ;
  TITLE6 "             Response Variable: &DVAR.";
  TITLE7 "Denominator degrees of freedom: &REPLICATES.";
  TITLE8 &TITLE8.;
  TITLE9 "                    Analysis of Maximum Likelihood Estimates";

VAR COEFF SE TVALUE PVALUE CHISQ CHIVALUE;
ID &BYVARS. PARAMETER;
LABEL 
	Parameter = "Parameter  "
	Coeff     = "Estimate   "
	SE        = "Standard * Error  "
	tvalue    = "t Value"
	pvalue    = "Pr > |t|"
	chisq	  = "Chi-Square"
	chivalue  = "Pr > ChiSq"
    ;
RUN;
%END;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE TPARAMS PARAMS1 PARAMS;
QUIT;
%MEND;

/**********************************************************************/
/* THE MACRO UNWT_PROC_LOGISTIC PERFORM LOGISTIC REGRESSIONS          */
/* default for SAS technique=Fisher                                   */
/**********************************************************************/
%MACRO UNWT_PROC_LOGISTIC;
%put I am using SAS release: &sysver;
/* RUN MACRO LOGISTIC_OPTIONS */
%LOGISTIC_OPTIONS;

/* RUN LOGISTIC REGRESSION */
%IF (%SUPERQ(XOUTPUT) = YES) AND (%SUPERQ(IMPUTED_VARS) NE ) %THEN %DO;
PROC LOGISTIC DATA=MYDATA &OPTIONS.;
BY &BYVARS.;
  TITLE1 &TITLE1.;
  TITLE2 &TITLE2.;
  TITLE3 &TITLE3.;
  TITLE4 "Consumer Expenditure Survey";
  TITLE5 "Dataset &DSN.";
  TITLE6 "Unweighted data";
 CLASS &CLASS.;
 MODEL &DVAR. = &IVARS./technique=Fisher;
RUN;
%END;

%IF (%SUPERQ(IMPUTED_VARS) = ) %THEN %DO;
PROC LOGISTIC DATA=MYDATA &OPTIONS.;
BY &BYVARS.;
  TITLE1 &TITLE1.;
  TITLE2 &TITLE2.;
  TITLE3 &TITLE3.;
  TITLE4 "Consumer Expenditure Survey";
  TITLE5 "Dataset &DSN.";
  TITLE6 "Unweighted data";
 CLASS &CLASS.;
 MODEL &DVAR. = &IVARS./technique=Fisher;
 		&TEST01.;
 		&TEST02.;
 		&TEST03.;
 		&TEST04.;
 		&TEST05.;
 		&TEST06.;
 		&TEST07.;
 		&TEST08.;
 		&TEST09.;
RUN;
%END;
%ELSE %DO;
/* KEEP THE INTERCEPT AND ALL THE VARIABLES IN YOUR MODEL STATEMENT */
ODS LISTING CLOSE;
ODS OUTPUT PARAMETERESTIMATES=PE(KEEP=&BYVARS. VARIABLE ESTIMATE STDERR)
			MODELINFO = MODELINFO(KEEP=&BYVARS. VALUE DESCRIPTION)
			ResponseProfile = RPS(keep= &BYVARS. count)
			;

PROC LOGISTIC DATA=MYDATA &OPTIONS.;
BY &BYVARS.;
 CLASS &CLASS.;
 MODEL &DVAR. = &IVARS./technique=Fisher;
QUIT;
ODS LISTING;

DATA A(KEEP=&BYVARS. PARAMETER COEFF SE COUNT);
SET PE;
COEFF=ESTIMATE;
PARAMETER=VARIABLE;
SE=STDERR;
COUNT=1;
RUN;

/*check for SAS version*/
%IF &sysver. LT 9 %then %do;
/* FOR SAS VERSION 8.2 */
DATA rp;
SET MODELINFO;
COUNT =1;
IF DESCRIPTION = 'Number of Observations' THEN OUTPUT rp;
RUN;
%end;
%else %do;
/* FOR SAS VERSION 9.1 */
proc summary data=rps nway;
class &BYVARS.;
var count;
output out=rp(keep=&BYVARS. value) sum=value; 
run;

data rp;
set rp;
COUNT=1;
run;
%end;

PROC SORT DATA=RP;
BY COUNT &BYVARS.;
RUN;

DATA A;
MERGE A rp;
BY COUNT &BYVARS.; 
SS = VALUE;
RUN;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE PE MODELINFO RP RPS;
QUIT;
%END;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE LEVELS;
QUIT;
%MEND;

/*********************************************************************/
/* MACRO REGRESSIONS                                                 */
/*********************************************************************/
%MACRO REGRESSIONS;

%LET DSN = %UPCASE(&DSN);

%LET USE_WEIGHTS = %UPCASE(&USE_WEIGHTS);
%IF (%SUPERQ(USE_WEIGHTS) = ) %THEN %LET USE_WEIGHTS = NO;

%IF %UPCASE(&USE_WEIGHTS) = YES %THEN %DO;
%PUT WARNING: Weighted Variances, SE, RSE, and related statistics should not be calculated for region of the country. See IMPORTANT NOTE in the documentation.;
%END;

%LET BYVARS = %UPCASE(&BYVARS);
%LET DEP_VARS = %UPCASE(&DEP_VARS);
%LET IND_VARS = %UPCASE(&IND_VARS);
%LET IMPUTED_VARS = %UPCASE(&IMPUTED_VARS);

%LET DF = %UPCASE(&DF);
%IF (%SUPERQ(DF) = ) %THEN %LET DF = RUBIN99;

%LET XOUTPUT = %UPCASE(&XOUTPUT);
%IF (%SUPERQ(XOUTPUT) = ) %THEN %LET XOUTPUT = NO;

/* DEFINE GLOBAL MACRO VARIABLES */
%GLOBAL UW;
%LET UW = %UPCASE(&USE_WEIGHTS);

%GLOBAL BY_VAR;
%LET BY_VAR = %UPCASE(&BYVARS);

%GLOBAL DFDEF;
%LET DFDEF = &DF.;

%IF (%SUPERQ(IMPUTATIONS) = ) %THEN %LET IMPUTATIONS = 5;
%GLOBAL MI;
%LET MI = &IMPUTATIONS.;

%IF (%SUPERQ(REP_WT) = ) %THEN %LET REP_WT = 44;
%GLOBAL REPLICATES;
%LET REPLICATES = &REP_WT.;

%GLOBAL TIMES;
%LET TIMES = %EVAL(&REPLICATES + 1); 

%IF %UPCASE(&USE_WEIGHTS) = NO %THEN %DO;
	%IF (%SUPERQ(IMPUTED_VARS) = ) %THEN %DO;
		%DO TESTS = 1 %TO 9;
			%IF (%SUPERQ(TEST&TESTS.) NE ) %THEN 
			%LET TEST0&TESTS. = &&TEST&TESTS.;
			%ELSE %LET TEST0&TESTS. = ;;
		%END;
	%END;
%END;

%PUT ;
%PUT Reading the dataset.;
%PUT ;
	%READ_DATA;
%IF (%SUPERQ(IMPUTED_VARS) = ) %THEN %DO;

	* COUNT NUMBER OF DEPENDENT AND INDEPENDENT VARIABLES (DV, IV);
	%COUNT_VARS(&DEP_VARS,DELIM=%STR( ));
	%LET DV = &N_VARS.;
	%COUNT_VARS(&IND_VARS,DELIM=%STR( ));
	%LET IV = &N_VARS.;
	%LET DVARS = &DEP_VARS.;
	%LET IVARS = &IND_VARS.;

	%IF %UPCASE(&USE_WEIGHTS) = YES %THEN %DO;
%PUT ;
%PUT Perform PROC &PROC for weighted non-imputed data,;
		%DO N_DV = 1 %TO &DV ;
		%WT_PROC_&PROC.;
		DATA DEP_VAR_&DVAR.;
		SET A;
		RUN;
		%END;
	%END;
	%ELSE %IF %UPCASE(&USE_WEIGHTS) = NO %THEN %DO;
%PUT ;
%PUT Perform PROC &PROC for unweighted non-imputed data,;
		%DO N_DV = 1 %TO &DV ;
		%UNWT_PROC_&PROC.;
		%END;	
	%END;
%END;
%ELSE %DO;

DATA IMPVARS(KEEP=&IMPUTED_VARS.);
SET MYDATA(OBS=1);
RUN;

PROC TRANSPOSE DATA=IMPVARS OUT=IMPVAR(KEEP=_NAME_);
VAR &IMPUTED_VARS.;
RUN;

%LET VRS = ;
proc sql noprint;
 SELECT distinct _NAME_ INTO: VRS SEPARATED BY ' ' 
 FROM IMPVAR;
QUIT;
%LET VRS = %UPCASE(&VRS);

/*COUNT THE NUMBER OF IMPUTED VARIABLES*/
	%COUNT_VARS(&VRS.,DELIM=%STR( ));
	%LET AV = &N_VARS.;
	%LET IMPUTED_VARS = ;
%DO C=1 %TO &AV. %BY &MI.;
%LET CVAR = &C.;
%LET VRS&C. = ;
	%DO CMI = 1 %TO &MI.;
    	%LET IMPV&CMI. = %SCAN(&VRS., &CVAR, ' ');
    	%LET CVAR=%EVAL(&CVAR + 1);
		%LET VRS&C. = &&VRS&C. &&IMPV&CMI.;
	%END;

	%LET IMPVAR&C. = &IMPV1.-&&IMPV&MI.;
	%LET IMPVAR_&C. = &IMPV1._&&IMPV&MI.;
	%LET IMPUTED_VARS = &IMPUTED_VARS. &&IMPVAR&C.;
%END;

	* COUNT NUMBER OF DEPENDENT AND INDEPENDENT VARIABLES (DV, IV);
	%COUNT_VARS(&DEP_VARS,DELIM=%STR( ));
	%LET DV = &N_VARS.;
	%COUNT_VARS(&IND_VARS,DELIM=%STR( ));
	%LET IV = &N_VARS.;
		* IV: NUMBER OF INDEPENDENT VARIABLES IN THE MODEL;
		* AV: NUMBER OF IMPUTED VARIABLES IN THE MODEL;
	%lET IVS = %EVAL(&IV. + 1 + (&AV./&MI.));
	%LET IV = %EVAL(&IV. + &AV.);
	%LET DVARS = &DEP_VARS.;

%DO N_DV = 1 %TO &DV ;
%DO IMP = 1 %TO &MI.;
	%LET IVARS = &IND_VARS.;
%DO C = 1 %TO &AV. %BY &MI.;
	%LET IMPUTED_VAR=%SCAN(&&VRS&C., &IMP., ' ');
	%LET IMP_VAR&C.=&IMPUTED_VAR.;
	%LET IVARS = &IVARS. &IMPUTED_VAR.;
%END;

* CALL MACROS TO PERFORM REGRESSIONS ;
	%IF %UPCASE(&USE_WEIGHTS) = YES %THEN %DO;
%PUT ;
%PUT Perform PROC &PROC for weighted MI data,;
		%WT_PROC_&PROC.;	
		DATA PARAMS;
		SET PARAMS_&DVAR.;
		IMPUTATION = &IMP.; 
			%DO C=1 %TO &AV. %BY &MI.;
			%LET OLDNAME = %SCAN(&&VRS&C., &IMP., ' ');
			%LET NEWNAME = &&IMPVAR_&C.;
			RENAME &OLDNAME. = &NEWNAME.;
			%END;	
		RUN;

		PROC APPEND BASE=PARAMS_ALL&DVAR. DATA=PARAMS FORCE;
		RUN;
	%END;
	%ELSE %IF %UPCASE(&USE_WEIGHTS) = NO %THEN %DO;
%PUT ;
%PUT Perform PROC &PROC for unweighted MI data,;
		%UNWT_PROC_&PROC.;
	%END;

/*   Degrees of Freedom: SS - IVS                     */
/*   IVS is the number of independent variables       */
/*	 in the model including the intercept             */

DATA VAR&IMP.(KEEP=&BYVARS. VARIABLE VAR&IMP. MEAN&IMP. DFC&IMP.);
ATTRIB VARIABLE LENGTH=$40;
SET A;
VARIABLE=PARAMETER;
VAR&IMP.=SE*SE;
DFC&IMP.= SS - &IVS.;
MEAN&IMP.=COEFF;
%DO C = 1 %TO &AV. %BY &MI.;
IF VARIABLE = "&&&IMP_VAR&C." THEN VARIABLE = "&&&IMPVAR&C.";
%END;
RUN;

PROC SORT DATA=VAR&IMP.;
BY &BYVARS. VARIABLE;
RUN;
%END;

	%IF %UPCASE(&USE_WEIGHTS) = YES %THEN %DO;
	DATA PARAMS4WTMI_&DVAR.;
	SET PARAMS_ALL&DVAR.;
	RUN;

	PROC DATASETS LIBRARY=WORK NOLIST;
	DELETE PARAMS PARAMS_ALL&DVAR. PARAMS_&DVAR.;
	QUIT;

	%IF (%SUPERQ(BY_VAR) NE ) %THEN %DO;
	PROC SORT DATA=PARAMS4WTMI_&DVAR.;
	BY &BYVARS. IMPUTATION;
	RUN;
	%END;
	%END;

%LET VARDATA = ;
%DO VD = 1 %TO &MI.;
%LET VARDATA = &VARDATA. VAR&VD.;
%END;

DATA TOT_VAR;
MERGE &VARDATA.;
BY &BYVARS. VARIABLE;
RUN;

%PUT ;
%PUT Calculate total variance for multiply imputed data.;
%PUT ;

/* CALCULATE THE TOTAL VARIANCE FOR ALL GROUPS OF &MI. IMPUTED VARIABLES */
	%TOT_VAR;

/* RM = RELATIVE INCREASE OF VARIANCE DUE TO NONRESPONSE */
DATA TOT_VARS(DROP=DFC1-DFC&MI.);
SET TOT_VARS;
  DFC = DFC1;
  SE = SQRT(TVAR);
  TVALUE = MEAN_MEANS/SE;
  MI = &MI.;
  ADJ = 1+(1/MI);

%IF &PROC. = LOGISTIC %THEN %DO;
  CHISQ=TVALUE*TVALUE;
  CHIVALUE=1-PROBCHI(CHISQ,1); /* DF = 1 */
%END;
/* DF from RUBINS book 1987, page 77*/
  RM = (ADJ*VAR_MEANS)/MEAN_VARS;
  DFM = (MI-1)*(1+(1/RM))**2;
/* What definition to use? Rubin87(DFM) or Rubin99(DDF)*/
%IF &DF. = RUBIN87 %THEN  DDF = DFM;
%ELSE %IF &DF. = RUBIN99 %THEN %DO;
/* DF from SUDAAN Language manual, page 89 Rubin definition 1999*/
/* VDF [(DFC+1 / DFC+3)]*[(1- [(MI+1)*VAR_MEANS]/MI*TVAR)]*DFC */
/* DDF = 1/ [(1/DF) + (1/VDF)]*/
  %IF &USE_WEIGHTS. = YES %THEN DFC = &REPLICATES.;
  VDF = ((DFC+1)/(DFC+3))*(1-(((MI+1)*VAR_MEANS)/(MI*TVAR)))*DFC;
  DDF = 1/((1/DFM)+(1/VDF)); 
%END;;

    PVALUE = (1-PROBT(ABS(TVALUE),DDF))*2; 
	/* ROUND DF */
	DF = ROUND(DDF,1);
RUN;

/* GET INDEPENDENT VARIABLE NAMES TO SORT FINAL DATASET */
PROC CONTENTS DATA = MYDATA (KEEP = &IND_VARS.) NOPRINT
  OUT = VARNAME;
RUN;
%LET INDVARS = ;
PROC SQL NOPRINT;
 SELECT NAME INTO: INDVARS SEPARATED BY '", "' 
 FROM VARNAME WHERE TYPE = 1;
QUIT;

* COUNT THE NUMBER OF IMPUTED VARIABLES (AV);
	%COUNT_VARS(&IMPUTED_VARS,DELIM=%STR( ));
    %LET AV = %EVAL(&MI.*&N_VARS);

DATA TOT_VARS;
SET TOT_VARS;
ORDER = '1';
IF VARIABLE IN("&INDVARS.") THEN ORDER='2';
%DO C=1 %TO &AV. %BY &MI.;
	%LET IVAR = &&&IMPVAR&C.;
	IF VARIABLE = "&IVAR." THEN ORDER='3';
%END;
RUN;

PROC SORT DATA=TOT_VARS;
BY &BYVARS. ORDER;
RUN;

DATA DEP_VAR_&DVAR. (label=Results from PROC "&PROC.");
SET TOT_VARS(DROP=ORDER );
RUN;

%GLOBAL TITLE6;
%GLOBAL TITLE8;

%IF %UPCASE(&USE_WEIGHTS) = YES %THEN 
	%LET TITLE6 = Total variance using the BRR method of variance estimation;
    %ELSE %IF %UPCASE(&USE_WEIGHTS) = NO %THEN 
	%LET TITLE6 = Total variance for unweighted data;;

%IF %UPCASE(&DF) = RUBIN99 %THEN 
	%LET TITLE8 = Degrees of Freedom: Barnard & Rubin (1999) definition;
    %ELSE %IF %UPCASE(&DF) = RUBIN87 %THEN 
    %LET TITLE8 = Degrees of Freedom: Rubin (1987) definition;;

%IF (%SUPERQ(IMPUTED_VARS) NE ) %THEN %DO;
%IF &PROC. = REG %THEN %DO;
	PROC PRINT DATA=DEP_VAR_&DVAR. SPLIT='*' UNIFORM;
	TITLE1 &TITLE1.;
	TITLE2 &TITLE2.;
	TITLE3 &TITLE3.;
	TITLE4 "Consumer Expenditure Survey: Dataset &DSN.";
	TITLE5 "Collection year estimates for imputed data";
	TITLE6 &TITLE6.;
	TITLE7 "Regression for Dependent Variable: &DVAR.";
    TITLE8 &TITLE8.;
    TITLE9 "                  Parameter Estimates";
	ID &BYVARS. VARIABLE;
	VAR DF MEAN_MEANS SE TVAR TVALUE PVALUE;
	LABEL 
		VARIABLE   = "Variable  "
		MEAN_MEANS = "Parameter *Estimate "
		SE         = " Standard *  Error  "
		TVALUE     = "t Value"
		PVALUE     = "Pr > |t|"
		TVAR 	   = "    Total * Variance"
		;
	RUN;
%END;
%ELSE %IF &PROC. = LOGISTIC %THEN %DO;
%IF %UPCASE(&USE_WEIGHTS) = YES %THEN %DO;
		%LET TITLE7 = Response Variable: &DVAR.;

ODS SELECT MODELINFO RESPONSEPROFILE;
PROC LOGISTIC DATA=MYDATA &OPTIONS.;
BY &BYVARS.;
 WEIGHT FINLWT21;
 CLASS &CLASS.;
 MODEL &DVAR. = &IVARS./technique=Fisher;
  TITLE1 &TITLE1.;
  TITLE2 &TITLE2.;
  TITLE3 &TITLE3.;
  TITLE4 "The LOGISTIC Procedure using replicate weights" ;
  TITLE5 "Balanced Repeated Replication (BRR) method" ;
  TITLE6 "Dataset &DSN. = WORK.MYDATA";
  TITLE7 ;
  TITLE8 "Denominator degrees of freedom: &REPLICATES.";
  TITLE9 ;
RUN;
%END;

%ELSE %IF %UPCASE(&USE_WEIGHTS) = NO %THEN %DO;
		%LET TITLE7 = Dependent Variable: &DVAR.;

ODS SELECT MODELINFO RESPONSEPROFILE;
PROC LOGISTIC DATA=MYDATA &OPTIONS.;
BY &BYVARS.;
  TITLE1 &TITLE1.;
  TITLE2 &TITLE2.;
  TITLE3 &TITLE3.;
  TITLE4 "Consumer Expenditure Survey";
  TITLE5 "Dataset &DSN.";
  TITLE6 "Unweighted data";
 CLASS &CLASS.;
 MODEL &DVAR. = &IVARS./technique=Fisher;
RUN;
%END;

	PROC PRINT DATA=DEP_VAR_&DVAR. SPLIT='*' UNIFORM;
    TITLE1 &TITLE1.;
    TITLE2 &TITLE2.;
    TITLE3 &TITLE3.;
	TITLE4 "Consumer Expenditure Survey, Dataset &DSN.";
	TITLE5 "Collection year estimates for imputed data";
	TITLE6 &TITLE6.;
	TITLE7 &TITLE7.;
    TITLE8 &TITLE8.;
    TITLE9 "                  Analysis of Maximum Likelihood Estimates";
	ID &BYVARS. VARIABLE;
	VAR DF MEAN_MEANS SE TVAR TVALUE PVALUE CHISQ CHIVALUE;
	LABEL 
		VARIABLE     = "Parameter  "
		MEAN_MEANS   = "Estimate"
		SE           = "Standard   *Error  "
		tvalue       = "t Value"
		pvalue       = "Pr > |t|"
 		TVAR 	     = "    Total  * Variance"
	chisq	  = "Chi-Square"
	chivalue  = "Pr > ChiSq"
    ;
	RUN;
%END;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE IMPVARS IMPVAR;
QUIT; 
%END;
%END;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE VAR1-VAR&MI. VARNAME TOT_VARS;
QUIT;
%END;
%MEND;

/*********************************************************************/
/* MACRO PROC_REG                                                    */
/*********************************************************************/
/**********************************************************************/
/* DSN:          DATASET NAME                                         */
/* FORMAT:       FORMATS IF ANY							              */
/* USE_WEIGHTS:  YES OR NO (DEFAULT = NO)				              */
/* BYVARS:  		 BY VARIABLES IF ANY							  */
/* DEP_VARS:     DEPENDENT VARIABLE FOR YOUR MODEL                    */
/* IND_VARS:     INDEPENDENT VARIABLES FOR YOUR MODEL                 */
/* IMPUTED_VARS: IMPUTED VARIABLES FOR YOUR MODEL                     */
/* DF:  		 DEGREES OF FREEDOM DEFINITION                        */
/*								(DEFAULT IS RUBIN99)		          */
/*                              (OPTION IS RUBIN 87)                  */
/* TITLE1:  	 TITLE 1 FOR OUTPUT								  	  */
/* TITLE2:  	 TITLE 2 FOR OUTPUT								  	  */
/* TITLE3:  	 TITLE 3 FOR OUTPUT								  	  */
/* XOUTPUT       PRINT EXTRA OUTPUT                                   */
/* REP_WT:  	 NUMBER OF REPLICATE WEIGHTS                          */
/*								(DEFAULT IS 44)		                  */
/*                              (OPTION IS 20)                        */
/* IMPUTATIONS:  NUMBER OF IMPUTATIONS (DEFAULT = 5)			      */
/* TEST1:        TEST1 FOR UNWEIGHTED NONIMPUTED DATA                 */
/* TEST2:        TEST2 FOR UNWEIGHTED NONIMPUTED DATA                 */
/* TEST3:        TEST3 FOR UNWEIGHTED NONIMPUTED DATA                 */
/* TEST4:        TEST4 FOR UNWEIGHTED NONIMPUTED DATA                 */
/* TEST5:        TEST5 FOR UNWEIGHTED NONIMPUTED DATA                 */
/* TEST6:        TEST6 FOR UNWEIGHTED NONIMPUTED DATA                 */
/* TEST7:        TEST7 FOR UNWEIGHTED NONIMPUTED DATA                 */
/* TEST8:        TEST8 FOR UNWEIGHTED NONIMPUTED DATA                 */
/* TEST9:        TEST9 FOR UNWEIGHTED NONIMPUTED DATA                 */
/**********************************************************************/
%MACRO PROC_REG(DSN = , 
  			 FORMAT = , 
		USE_WEIGHTS = ,
		      BYVARS = ,
		   DEP_VARS = , 
		   IND_VARS = , 
	   IMPUTED_VARS = ,
	             DF = ,
		     TITLE1 = ,
			 TITLE2 = ,
			 TITLE3 = ,
  		    XOUTPUT = ,
	  	     REP_WT = ,
 		IMPUTATIONS = ,
		      TEST1 = ,
		      TEST2 = ,
		      TEST3 = ,
		      TEST4 = ,
		      TEST5 = ,
		      TEST6 = ,
		      TEST7 = ,
		      TEST8 = ,
		      TEST9 = );

/* DEFINE GLOBAL MACRO VARIABLES */
%GLOBAL MI_REG_VARS;  
%LET MI_REG_VARS = %UPCASE(&IMPUTED_VARS);

%GLOBAL REGRESSION;
%LET REGRESSION = YES;	

%GLOBAL LOGISTIC;
%LET LOGISTIC = ;	

%GLOBAL PROC;  
%LET PROC = REG;

%REGRESSIONS;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE A;
QUIT;

TITLE;
%MEND;

/*********************************************************************/
/* MACRO PROC_LOGISTIC                                               */
/*********************************************************************/
/**********************************************************************/
/* DSN:          DATASET NAME                                         */
/* FORMAT:       FORMATS IF ANY							              */
/* USE_WEIGHTS:  YES OR NO (DEFAULT = NO)				              */
/* BYVARS:  	 BY VARIABLES IF ANY							      */
/* DEP_VARS:     DEPENDENT VARIABLE FOR YOUR MODEL                    */
/* IND_VARS:     INDEPENDENT VARIABLES FOR YOUR MODEL                 */
/* IMPUTED_VARS: IMPUTED VARIABLES FOR YOUR MODEL                     */
/* DF:  		 DEGREES OF FREEDOM DEFINITION                        */
/*								(DEFAULT IS RUBIN99)		          */
/*                              (OPTION IS RUBIN 87)                  */
/* SORT_ORDER:   SORTING ORDER OF DEPENDENT VARIABLE                  */
/* CLASSVARS:    													  */
/*    INDEPENDENT CLASSIFICATION VARIABLES AND SORTING OPTIONS IF ANY */
/* TITLE1:  	 TITLE 1 FOR OUTPUT									  */
/* TITLE2:  	 TITLE 2 FOR OUTPUT									  */
/* TITLE3:  	 TITLE 3 FOR OUTPUT									  */
/* XOUTPUT       PRINT EXTRA OUTPUT                                   */
/* REP_WT:  	 NUMBER OF REPLICATE WEIGHTS                          */
/*								(DEFAULT IS 44)		                  */
/*                              (OPTION IS 20)                        */
/* IMPUTATIONS:  NUMBER OF IMPUTATIONS (DEFAULT = 5)			      */
/* TEST1:        TEST1 FOR UNWEIGHTED NONIMPUTED DATA                 */
/* TEST2:        TEST2 FOR UNWEIGHTED NONIMPUTED DATA                 */
/* TEST3:        TEST3 FOR UNWEIGHTED NONIMPUTED DATA                 */
/* TEST4:        TEST4 FOR UNWEIGHTED NONIMPUTED DATA                 */
/* TEST5:        TEST5 FOR UNWEIGHTED NONIMPUTED DATA                 */
/* TEST6:        TEST6 FOR UNWEIGHTED NONIMPUTED DATA                 */
/* TEST7:        TEST7 FOR UNWEIGHTED NONIMPUTED DATA                 */
/* TEST8:        TEST8 FOR UNWEIGHTED NONIMPUTED DATA                 */
/* TEST9:        TEST9 FOR UNWEIGHTED NONIMPUTED DATA                 */
/**********************************************************************/
%MACRO PROC_LOGISTIC(DSN = , 
  				  FORMAT = , 
			 USE_WEIGHTS = ,
		          BYVARS = ,
				DEP_VARS = , 
				IND_VARS = , 
			IMPUTED_VARS = , 
			          DF = ,
			  SORT_ORDER = , 
			   CLASSVARS = ,
				  TITLE1 = ,
                  TITLE2 = ,
                  TITLE3 = ,
  		         XOUTPUT = ,
	  	      	  REP_WT = ,
 			 IMPUTATIONS = ,
				   TEST1 = ,
				   TEST2 = ,
				   TEST3 = ,
				   TEST4 = ,
				   TEST5 = ,
				   TEST6 = ,
				   TEST7 = ,
				   TEST8 = ,
				   TEST9 = );

%LET SORT_ORDER = %UPCASE(&SORT_ORDER);

%LET CLASSVARS = %UPCASE(&CLASSVARS);

/* DEFINE GLOBAL MACRO VARIABLES */
%GLOBAL MI_LOGISTIC_VARS;  
%LET MI_LOGISTIC_VARS = %UPCASE(&IMPUTED_VARS);

%GLOBAL REGRESSION;
%LET REGRESSION = ;

%GLOBAL LOGISTIC;
%LET LOGISTIC = YES;	

%GLOBAL PROC;  
%LET PROC = LOGISTIC;

%REGRESSIONS;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE A;
QUIT;

TITLE;
%MEND;

/**********************************************************************/
/**********************************************************************/
/* THE MACROS COMPARE, F_TEST, AND CHISQ_TEST                         */
/* PERFORM COMPARISON OF THE REGRESSION PARAMETER ESTIMATES           */
/* PE1 AND PE2 ARE THE PARAMETER ESTIMATES TO BE COMPARE              */
/* EQUIVALENT TO SAS STATEMENT: TEST PE1 = PE2                        */
/**********************************************************************/
/**********************************************************************/
%MACRO COMPARE_PARAMS(PE1, PE2);
/* COMPARE FOR WEIGHTED NONIMPUTED DATA */

%IF &UW. = YES AND (%SUPERQ(MI_VARS ) = ) %THEN %DO;
%PUT ;
%PUT Perform parameter comparisons for weighted non-imputed data.;
%PUT ;

DATA PARAM(KEEP=&PE1._VS_&PE2. &BY_VAR.);
SET PARAMS_&DVAR.;
&PE1._vs_&PE2. = &PE1 - &PE2 ;
RUN;

/* TRANSPOSE THE VARIABLE &PE1._&PE2. */
PROC TRANSPOSE DATA=PARAM PREFIX=COEFF OUT=TPARAMS;
BY &BY_VAR.;
RUN;

DATA TPARAMS;
ATTRIB _NAME_ LENGTH=$40;
SET TPARAMS;
RUN;

PROC APPEND BASE=TPARAMS2 DATA=TPARAMS FORCE;
RUN;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE PARAM TPARAMS;
QUIT;
%END;
/* COMPARE FOR WEIGHTED IMPUTED DATA */
%IF &UW. = YES AND (%SUPERQ(MI_VARS ) NE ) %THEN %DO;
%PUT ;
%PUT Perform parameter comparisons for weighted MI data.;
%PUT ;

DATA PARAM;
SET PARAMS4WTMI_&DVAR.;
/* IDENTIFY VARIABLES OF MULTIPLY IMPUTED DATA (DASH IN THE NAME) */
RX = RXPARSE("$'-'");
   match=rxmatch(rx,"&PE1.");
   IF MATCH GT 0 THEN DO;
   call rxsubstr(rx,"&PE1.",position1);
   position2=position1-1;
	vr1=substr("&PE1.",1,position2);
	position3=position1+1;
	vr2=substr("&PE1.",position3,position2);
	PE1=trim(vr1)||'_'||trim(vr2);
	PEN1=SUBSTR(PE1,1,14);
	END;
	ELSE DO;
		PE1 = "&PE1.";
		PEN1 = "&PE1.";
		END;
RX = RXPARSE("$'-'");
   match=rxmatch(rx,"&PE2.");
   IF MATCH GT 0 THEN DO;
   call rxsubstr(rx,"&PE2.",position1);
   position2=position1-1;
	vr1=substr("&PE2.",1,position2);
	position3=position1+1;
	vr2=substr("&PE2.",position3,position2);
	PE2=trim(vr1)||'_'||trim(vr2);
	PEN2=SUBSTR(PE2,1,14);
	END;
	ELSE DO;
		PE2 = "&PE2.";
		PEN2 = "&PE2.";
		END;
RUN;

%LET XPE1 = ;
%LET XPE2 = ;
%LET XPEN1 = ;
%LET XPEN2 = ;

PROC SQL NOPRINT;
 SELECT DISTINCT PE1, PE2, PEN1, PEN2 
	INTO :XPE1, :XPE2, :XPEN1, :XPEN2 
    FROM PARAM;
   QUIT;
   RUN;

%LET XPE1 = %QTRIM(&XPE1.);
%LET XPE2 = %QTRIM(&XPE2.);
%LET XPEN1 = %QTRIM(&XPEN1.);
%LET XPEN2 = %QTRIM(&XPEN2.);

%LET VARIABLE = %QTRIM(&XPEN1._vs_&XPEN2.); 
DATA PARAM;
SET PARAM;
&VARIABLE. = &XPE1. - &XPE2. ;
RUN;

PROC TRANSPOSE DATA=PARAM prefix=diff OUT=TYS;
BY &BY_VAR. IMPUTATION;
var &VARIABLE.;
RUN;

data TYS;
set TYS;
  ARRAY diff(&REPLICATES.) diff1-diff&REPLICATES.;
  ARRAY SQDIFF(&REPLICATES.) SQDIFF1-SQDIFF&REPLICATES.;
    DO I = 1 TO &REPLICATES.;
      SQDIFF(I) = (diff(I) - diff&TIMES.)**2;
      DROP I; 
    END; 
  MEAN = diff&TIMES.;
  VARIANCE = SUM(OF SQDIFF(*))/&REPLICATES.;
run;

DATA TYS(KEEP=&BY_VAR. IMPUTATION _name_ MEAN VARIANCE);
SET TYS;
RUN;

PROC TRANSPOSE DATA=TYS OUT=TM PREFIX=MEAN;
VAR MEAN;
BY &BY_VAR.;
RUN;

PROC TRANSPOSE DATA=TYS OUT=TV PREFIX=VAR;
VAR VARIANCE;
BY &BY_VAR.;
RUN;

DATA TALL(DROP=_NAME_ );
ATTRIB Compare_Coeff LENGTH=$40.;
MERGE TM TV;
Compare_Coeff="&PE1._vs_&PE2.";
RUN;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE PARAM TYS TM TV;
QUIT;
%END;
/* COMPARE FOR UNWEIGHTED IMPUTED DATA */
%ELSE %IF &UW. = NO %THEN %DO;
%PUT ;
%PUT Perform parameter comparisons for unweighted MI data.;
%PUT ;

DATA TY1(KEEP= &BY_VAR. VARIABLE MEAN_MEANS TVAR DF);
SET DEP_VAR_&DVAR.;
%IF &DFDEF. = RUBIN87 %THEN  DF=DFM;;
%IF &DFDEF. = RUBIN99 %THEN  DF=DDF;;
IF VARIABLE IN("&PE1.", "&PE2.") THEN OUTPUT TY1;
RUN;

%IF (%SUPERQ(BY_VAR) NE ) %THEN %DO;
PROC SORT DATA=TY1;
BY &BY_VAR.;
RUN;
%END;

PROC TRANSPOSE DATA=TY1 PREFIX=TVAR OUT=ZSCY;
BY &BY_VAR.;
VAR TVAR;
RUN;

PROC TRANSPOSE DATA=TY1 PREFIX=MEAN OUT=ZSCZ;
BY &BY_VAR.;
VAR MEAN_MEANS;
RUN;

PROC TRANSPOSE DATA=TY1 PREFIX=DF OUT=ZSCDF;
BY &BY_VAR.;
VAR DF;
RUN;

/* CALCULATE THE T_STAT VALUES */
DATA ZSALL;
ATTRIB Compare_Means LENGTH=$60;
MERGE ZSCZ ZSCY ZSCDF;
BY &BY_VAR.;
Compare_Means="&PE1._vs_&PE2.";
RUN;

PROC APPEND BASE=TY2 DATA=ZSALL FORCE;
RUN;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE TY1 ZSCY ZSCZ ZSCDF ZSALL;
QUIT;
%END;
%MEND;

/****************************************************************/
/* MACRO COMPARE_PE                                             */
/****************************************************************/
/****************************************************************/
/* DEP_VARS:     DEPENDENT VARIABLES					        */
/* PE:           PARAMETER ESTIMATE TO BE COMPARE				*/
/* TITLE1:  	 TITLE 1 FOR OUTPUT							    */
/* TITLE2:  	 TITLE 2 FOR OUTPUT							    */
/* TITLE3:  	 TITLE 3 FOR OUTPUT							    */
/****************************************************************/
/****************************************************************/
/* COMPARE PARAMETER ESTIMATES                                  */
/****************************************************************/

%MACRO COMPARE_PE(DEP_VARS = ,
					    PE = ,
			        TITLE1 = ,
			        TITLE2 = ,
			        TITLE3 = );

OPTIONS PAGENO=1 NOCENTER;

%LET DEPVARS = %UPCASE(&DEP_VARS);
%LET PE = %UPCASE(&PE);

%LET PROC_REGRESSION = %UPCASE(&REGRESSION);
%LET PROC_LOGISTIC = %UPCASE(&LOGISTIC);

	%IF &PROC_REGRESSION. = YES %THEN %LET MI_VARS = &MI_REG_VARS.;
	%ELSE %IF &PROC_LOGISTIC. = YES %THEN %LET MI_VARS = &MI_LOGISTIC_VARS.;;

* COUNT NUMBER OF DEPENDENT VARIABLES;
%COUNT_VARS(&DEPVARS.,DELIM=%STR( ));
%LET C_DEP_VARS = &N_VARS.;
	%DO CDEP_VARS = 1 %TO &C_DEP_VARS.;
		%LET DVAR = %SCAN(&DEPVARS., &CDEP_VARS, ' ');

/* COUNT NUMBER OF REPLICATE WEIGHTS */
%IF &UW. = YES %THEN %DO; 
%LET REP_WT = ;
PROC SQL NOPRINT;
 SELECT DFC INTO: REP_WT
 FROM DEP_VAR_&DVAR.;
QUIT;
%LET REP_WT = %LEFT(&REP_WT);
%GLOBAL REPLICATES;
%LET REPLICATES = &REP_WT.;
%GLOBAL TIMES;
%LET TIMES = %EVAL(&REPLICATES + 1); 
%END;

%IF (%SUPERQ(MI_VARS ) = ) AND &UW. = NO %THEN %DO; 
%PUT ERROR: Use PROC_&PROC. to perform comparisons of unweighted non-imputed data.;
%END;
%ELSE %DO;
	%COUNT_VARS(&PE.,DELIM=%STR( ));
	%LET C_PE = &N_VARS.;
		%DO CPE=1 %TO &C_PE. %BY 2;
			%LET PE1 = %SCAN(&PE., &CPE, ' ');
			%LET CPE2 = %EVAL(&CPE + 1);
			%LET PE2 = %SCAN(&PE., &CPE2, ' ');

* CALL MACRO COMPARE TO PERFORM COMPARISONS BETWEEN;
* PARAMETER ESTIMATES AS MANY TIMES AS NECESARY;
			%COMPARE_PARAMS(&PE1., &PE2.);
				%IF (%SUPERQ(MI_VARS )NE ) AND &UW. = YES %THEN %DO;				
				PROC APPEND BASE=TY2 DATA=TALL FORCE;
				RUN;
				PROC DATASETS LIBRARY=WORK NOLIST;
				DELETE TALL;
				QUIT;
				%END;
		%END;

%IF (%SUPERQ(MI_VARS )NE ) AND &UW. = YES %THEN %DO;
/* COUNT NUMBER OF IMPUTATIONS */
%LET MI = ;
PROC SQL NOPRINT;
 SELECT MI INTO: MI
 FROM DEP_VAR_&DVAR.;
QUIT;
%LET MI = %LEFT(&MI);

DATA B (DROP = Compare_Coeff MEAN1-MEAN&MI. VAR1-VAR&MI.);
ATTRIB _NAME_ LENGTH=$60;
SET TY2;
_NAME_ = Compare_Coeff;
MI = &MI.;
ADJ = 1 + (1/MI);

* CALCULATE COMPLETE DATASET STATISTICS;
Coeff=MEAN(OF MEAN1-MEAN&MI.);
Mean_Vars=MEAN(OF VAR1-VAR&MI.);
SUMSQRD=0;
%DO I=1 %TO &MI.;
    SUMSQRD=SUM(SUMSQRD,((MEAN&I.-Coeff)**2));
%END;
Var_Coeff = SUMSQRD/(MI - 1);
TVAR = MEAN_VARS + (ADJ*VAR_Coeff);
SE_Coeff = SQRT(TVAR);
IF SE_Coeff NE 0 THEN TValue = Coeff/SE_Coeff;
ELSE TValue = .;
Test = TVALUE*TVALUE;

RM = (ADJ*VAR_Coeff)/MEAN_VARS;
DFM = (MI - 1)*(1+(1/RM))**2;
%IF &DFDEF. = RUBIN87 %THEN DFF = DFM;
%ELSE %IF &DFDEF. = RUBIN99 %THEN %DO;
	REPLICATES = &REPLICATES.;
	VDF = ((REPLICATES + 1)/(REPLICATES + 3))*(1-(((MI+1)*VAR_Coeff)/(MI*TVAR)))*REPLICATES;
  	DFF = 1/((1/DFM)+(1/VDF)); 
	%END;;

P_Value=1-PROBF(TEST,1,DFF);
DF_Coeff = ROUND(DFF,1);
  CHIVALUE=1-PROBCHI(TEST,1); /* DF = 1 */
  DF=1;
RUN;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE TY2;
QUIT;
%END;

%ELSE %IF (%SUPERQ(MI_VARS ) = ) %THEN %DO;
DATA B;
  SET TPARAMS2;
  PARAMETER = _NAME_;
  ARRAY PARMS(&REPLICATES.) COEFF1-COEFF&REPLICATES.;
  ARRAY SQDIFF(&REPLICATES.) SQDIFF1-SQDIFF&REPLICATES.;
    DO I = 1 TO &REPLICATES.;
      SQDIFF(I) = (PARMS(I) - COEFF&TIMES.)**2;
    END; 
  COEFF = COEFF&TIMES.;
  REPLICATES = &REPLICATES.;
  SE = SQRT( SUM(OF SQDIFF(*))/REPLICATES); /* HORIZONTAL SUM */
  TVALUE = COEFF/SE;
  TEST=TVALUE*TVALUE;
  P_VALUE=1-PROBF(TEST,1,REPLICATES);/* DF = 1, REPLICATES */
  CHIVALUE=1-PROBCHI(TEST,1); /* DF = 1 */
  DF=1;
RUN;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE TPARAMS2;
QUIT;
%END;

%ELSE %IF (%SUPERQ(MI_VARS ) NE )%THEN %DO;
DATA B
   (KEEP= &BY_VAR. _NAME_ COEFF Var_Coeff_Diff TVALUE TEST DF DFC P_VALUE CHIVALUE);
ATTRIB _NAME_ LENGTH=$40;
SET TY2;
_NAME_ = Compare_Means;
Coeff = MEAN1 - MEAN2;
DFC = DF1 + DF2; /* DF FOR P_VALUE (OLS) */
Var_Coeff_Diff = TVAR1 + TVAR2;
TVALUE = Coeff / SQRT(Var_Coeff_Diff);
TEST = TVALUE*TVALUE;
  P_VALUE=1-PROBF(TEST,1,DFC);
  CHIVALUE=1-PROBCHI(TEST,1); 
  DF=1; /* DF FOR CHIVALUE (LOGISTIC) */
RUN;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE TY2;
QUIT;
%END;

%IF &PROC_REGRESSION. = YES %THEN %DO;	
PROC PRINT DATA=B SPLIT='*' UNIFORM;
    TITLE1 &TITLE1.;
    TITLE2 &TITLE2.;
    TITLE3 &TITLE3.;
  TITLE4 "Regression Dependent Variable &DVAR.";
  TITLE5 ;
  TITLE6 "Comparison of Parameter Estimates";

VAR &BY_VAR. COEFF TEST P_VALUE;
ID  _NAME_;
LABEL 
	_NAME_  = "Test"
   	COEFF   = "Coefficient *Difference"
	TEST    = "F Value"
	P_Value = "Pr > F"
    ;
RUN;
%END;

%IF &PROC_LOGISTIC. = YES %THEN %DO;	
PROC PRINT DATA=B SPLIT='*' UNIFORM;
    TITLE1 &TITLE1.;
    TITLE2 &TITLE2.;
    TITLE3 &TITLE3.;
  TITLE4 "Regression for Dependent Variable &DVAR.";
  TITLE5 ;
  TITLE6 "Linear Hypotheses Testing Results";

VAR &BY_VAR. COEFF TEST DF CHIVALUE;
ID  _NAME_;
LABEL 
	_NAME_    = "Test"
   	COEFF     = "Coefficient*Difference"
	TEST      = "       Wald*Chi-Square"
	CHIVALUE  = "Pr > ChiSq"
    ;
RUN;
%END;
%END;
TITLE;
%END;

PROC DATASETS LIBRARY=WORK NOLIST;
DELETE B;
QUIT;
%MEND;


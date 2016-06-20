
%let year = 2014;
%let drive = c:\2014_cex;

%let yr1 = %substr(&year,3,2);
%let yr2 = %substr(%eval(&year+1),3,2);

libname i&yr1 "&drive\intrvw&yr1";

proc format;
  value $inc (multilabel)
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
	/* create income class format */
run;

proc format library= work  cntlin= lblfmt;
  /* create label file formats */
run;

data fmly (keep = newid inclass wtrep01-wtrep44 finlwt21 repwt1-repwt45);

set i&yr1..fmli&yr1.1x (in = firstqtr)
    i&yr1..fmli&yr1.2
    i&yr1..fmli&yr1.3
    i&yr1..fmli&yr1.4
    i&yr1..fmli&yr2.1  (in = lastqtr);
	by newid;


    if firstqtr then 
      mo_scope = (qintrvmo - 1);
    else if lastqtr then
      mo_scope = (4 - qintrvmo);
    else 
      mo_scope = 3;


    array reps_a(45) wtrep01-wtrep44 finlwt21;
    array reps_b(45) repwt1-repwt45;

      do i = 1 to 45;
	  if reps_a(i) > 0 then
         reps_b(i) = (reps_a(i) * mo_scope / 12);
		 else reps_b(i) = 0;
	  end;

run;

data expend (keep=newid ucc cost);
  set i&yr1..mtbi&yr1.1x
      i&yr1..mtbi&yr1.2
      i&yr1..mtbi&yr1.3
      i&yr1..mtbi&yr1.4
      i&yr1..mtbi&yr2.1
      i&yr1..itbi&yr1.1x (rename=(value=cost))
      i&yr1..itbi&yr1.2  (rename=(value=cost))
      i&yr1..itbi&yr1.3  (rename=(value=cost))
      i&yr1..itbi&yr1.4  (rename=(value=cost))
      i&yr1..itbi&yr2.1  (rename=(value=cost));

   if refyr = "&year" or  ref_yr = "&year";
   if ucc = '710110'  then  
      cost = (cost * 4);              */
run;

proc summary data=expend;
	class newid ucc;
	var cost;
	output out = rcost (drop = _type_ _freq_) sum = cost;
run;

proc sort data=rcost;
	by newid ucc;
run;

data rcost;
	merge fmly(in=fmly) rcost(in=rcost);
	by newid;
	if fmly and rcost;
run;

proc freq data=rcost;
run;

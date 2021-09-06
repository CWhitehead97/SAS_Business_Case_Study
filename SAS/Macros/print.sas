***********************************************************************************************************************************************************************
*                                                                                                                                                                     *                                                                                            
*   Name:           print.sas                                                                                                                                         *                            
*                                                                                                                                                                     *
*   Description:    A macro to print a dataset via proc print                                                                                                         *                                          
*                                                                                                                                                                     *                                   
*   Parameters:     Required: lib - The library corresponding to the input data                                                                                       *                                                        
*                             file - The name of the input data                                                                                                       *
*                                                                                                                                                                     *
*                   Optional: obs - The number of observations to include in the report                                                                               *
*                             var - The variable(s) to include in the output report (as a space seperated list)                                                       *                  
*                             format - A parameter to hold the contents ofa format statement                                                                          *
*                             noobs - Specify if the noobs options should be used. Takes values "true" or "false"                                                     *
*                                                                                                                                                                     *                             
*                                                                                                                                                                     *                           
*   Creation Date:  24 08 2021                                                                                                                                        *                              
*                                                                                                                                                                     *
*   Created By:     Colm Whitehead                                                                                                                                    *                                  
*                                                                                                                                                                     *
*   Edit History:                                                                                                                                                     *                 
*   +----------------+----------+---------------------------------------------------------------------------------------------------------------------------------+   *
*   |   Programmer   |   Date   |   Description                                                                                                                   |   *                                              
*   +----------------+----------+---------------------------------------------------------------------------------------------------------------------------------+   *
*   |                |          |                                                                                                                                 |   *
*   +----------------+----------+---------------------------------------------------------------------------------------------------------------------------------+   *
**********************************************************************************************************************************************************************;

%macro print (lib=work, file=, obs=max, var=, format=, noobs=, nolabel=);
	%if %length(&lib..&file.)=0 %then %put
		%str(ER)ROR: Parameters LIB and FILE are required;
	%else %if %qsysfunc(exist(&lib..&file.))=0 %then %put
		%str(ER)ROR: Data set not found;

	%else %do;
		proc print data=&lib..&file. (obs=&obs.) %if %upcase(&noobs.) = TRUE %then noobs;
                                                 %else %if %length(&noobs.) > 0 AND %upcase(&noobs.) ne FALSE %then %put %str(ER)ROR: Noobs parameter must be true or false if included;
                                                 %if %upcase(&nolabel.) = FALSE OR %length(&nolabel.) = 0 %then label ;
                                                 %else %if %upcase(&nolabel.) ne TRUE %then %put %str(ER)ROR: Nolabel parameter must be true or false if included;
                                                ; 
			%if %length(&var.)>0 %then %do; 
				var &var.;
			%end;
			%if %length(&format.)>0 %then %do; 
				format &format.;
			%end;
		run;
	%end;
%mend;

***********************************************************************************************************************************************************************
*                                                                                                                                                                     *                                                                                            
*   Name:           2.1 - DataManagement_Households.sas                                                                                                               *                            
*                                                                                                                                                                     *
*   Description:    1 -  Derives a formal greeting column (output a new dataset)                                                                                      *
*                   2 -  Produces an ID number for unique households                                                                                                  *
*                   3 -  Decides the primary householder for each unique household (output a new data set)                                                            *
*                   4 -  Creates a table of booleans indicating the interests of customers (output a new dataset)                                                     *
*                   5 -  Creates two new data sets separating the contacts by their contact preference                                                                *
*                                                                                                                                                                     *
*   Parameters:     Required:                                                                                                                                         * 
*                                                                                                                                                                     *
*                   Optional:                                                                                                                                         *                             
*                                                                                                                                                                     *                           
*   Creation Date:  13 08 2021                                                                                                                                        *                              
*                                                                                                                                                                     *
*   Created By:     Colm Whitehead                                                                                                                                    *                                  
*                                                                                                                                                                     *
*   Edit History:                                                                                                                                                     *                 
*   +----------------+----------+---------------------------------------------------------------------------------------------------------------------------------+   *
*   |   Programmer   |   Date   |   Description                                                                                                                   |   *                                              
*   +----------------+----------+---------------------------------------------------------------------------------------------------------------------------------+   *
*   |Colm Whitehead  |23 08 2021|Adjusted the 2.1.1 data step for simplicity, rather than speed-efficien                                                          |   *
*   +----------------+----------+---------------------------------------------------------------------------------------------------------------------------------+   *
**********************************************************************************************************************************************************************;
%open_log_save(file=Section B - 1)
proc format lib = shared;
    value bool 0 = "False"
               1 = "True"
           other = ".";
run;
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

2.1.1 - Create a greetings message

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
data detail.households_detail except.households_detail;
    length formal_greeting $40; 
    label formal_greeting = "Formal Greeting";
    set raw.households;

    /*Try deriving gender*/
    if missing(gender) then do;
        if upcase(title) in ("MR","MR.","SIR") then gender = "M"; /*If title is missing, nothing is changed here*/
        else if upcase(title) in ("MRS","MRS.","MISS", "MS") then gender = "F";
    end;
    /*Use a generic title if possible*/
    else if missing(title) then do; /*If gender was just created, title will not exist */
        if upcase(gender) = "M" then title = "Mr";
        else if upcase(gender) = "F" then title = "Mrs";/*else output the exception*/
        else output except.households_detail; /*Catch the case where gender is not */
    end;
   /*Try to write greeting*/
   if not((missing(title) and missing(gender)) or missing(family_name)) then formal_greeting = greeting(title, forename, family_name);
   else formal_greeting = "Dear Customer";   
   output detail.households_detail;
run;


/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

2.1.2 - Unique households

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*Sort the data by postcode and address_1 so people at the same address will be adjacent*/
proc sort data = detail.households_detail out = staging.households_primary
          sortseq = linguistic (numeric_collation = on);
    by postcode address_1;
run;

data detail.households_detail;
    label household_id = "Household ID";
    set staging.households_primary;
    by postcode address_1;

    if first.address_1 then household_id + 1;
run;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

2.1.3 - Primary Householder

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
proc sort data = detail.households_detail out = staging.households_primary;
    by household_id gender dob customer_id; /*Note: Missing values of gender will be put first (assume that gender is male or female) */    
run;
 
data detail.households_detail;
    label primary_householder = "Primary Householder"; 
    format primary_householder bool.;

    /*The data is now sorted so the first of each household will be the primary householder according to our rules.*/
    set staging.households_primary;
    by household_id gender dob customer_id;

    primary_householder = first.household_id;
run;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

2.1.4 - Interests to boolean columns

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/    
proc sql noprint; 
    *Use system.interestsDictionary to produce macro variables for each ;
    SELECT activity, codes, activity INTO :act1 -, :codes1-, :activities SEPARATED BY " "
    FROM system.interestsDictionary;
quit;
options mprint;
%macro codeToActivity;
data detail.households_detail;
    set detail.households_detail;
    %do i=1 %to 14;
        label &&act&i = "%sysfunc(propcase(%sysfunc(translate(&&act&i,%str( ) ,_))))";
        format &&act&i bool.;
        &&act&i = indexc(upcase(interests), "&&codes&i") > 0;   
    %end;
run;
%mend;

%codeToActivity
options nomprint;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

2.1.5 - Split the datasets by 'contact preference'

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
%let address_vars = address_1 address_2 address_3 address_4 postcode;
data marts.contact_email(drop=&address_vars.)
     marts.contact_post(drop=email1) 
     except.contact_exceptions;

     set detail.households_detail(keep=customer_id contact_preference email1 &address_vars.);

	 if upcase(contact_preference) = 'E-MAIL' then output marts.contact_email;
     else if upcase(contact_preference) = 'POST' then output marts.contact_post;
     else output except.contact_exceptions;
run;
%symdel address_vars;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Printing

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
ods pdf file="&root.\SAS\Reports\2.1-DataManagement.pdf";
title1 "Households Detail:";
title2 "Primary Householder flag";
%print(lib=detail, file=households_detail, noobs = true, obs = 30, var = customer_id primary_householder)
title2 "Primary Householder flag";
%print(lib=detail, file=households_detail, noobs = true, obs = 30, var = customer_id &activities.)
title1 "Contact by post";
%print(lib=marts, file=contact_post, noobs = true, obs = 30)
title1 "Contact by email";
%print(lib=marts, file=contact_email, noobs = true, obs = 30)
title;
ods pdf close;

%close_log_save 
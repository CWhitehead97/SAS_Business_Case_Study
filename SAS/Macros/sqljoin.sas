***********************************************************************************************************************************************************************
*                                                                                                                                                                     *                                                                                            
*   Name:           sqljoin.sas                                                                                                                                       *                            
*                                                                                                                                                                     *
*   Description:    Creates a table from two input tables by performing an SQL join                                                                                   *
*                                                                                                                                                                     *                                                      
*   Parameters:     Required: table1 - The left table in the join                                                                                                     *                                             
*                             table2 - The right table in the join                                                                                                    *                                              
*                             key    - The variable to perform the join on                                                                                            *                                                      
*                                                                                                                                                                     *
*                   Optional: key2   - If the key variable in the right table is named differently, then use this parameter to specifiy it                            *                                             
*                             out_table - The library and table name to save the join as (by default, save as "temp_join" in the work library)                        *                                                 
*                             join_type - The type of join to perform (the default is inner), but other options are:                                                  *                            
*                                                   "left", "left_anti", "right", "right_anti", "cross" and "union"                                                   *                      
*                             repeated_vars - If some varaible take identical values in both tables, drop from the RIGHT table                                        *                                  
*                             debug - Takes any non-missing value as input and enables the mprint option                                                              *           
*                             keep1 - Space delimited list of variables to use in the keep data set option for table 1                                                * 
*                             keep2 - Space delimited list of variables to use in the keep data set option for table 2                                                *                         
*                             newcol - The code required to create a column using the SELECT statement                                                                *         
*                             where - The code for a where statement                                                                                                  *                                                 
*   Creation Date:  13 08 2021                                                                                                                                        *                              
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

/*COALESCE THE REPEATED VARS READ THE SPACED SEPARATED LIST AND COALESCE?, I THINK WHERE AND KEEP1/2 MIGHT BE UNUSED IDK*/

%macro sqljoin(table1 = , table2 = , key = , key2= , 
               out_table = temp_join, join_type = inner, repeated_vars= , debug =, keep1 =, keep2=, newcol=, where =);

    %let join_type = %sysfunc(lowcase(&join_type.));
    
    /*If the debugging argument is specified then enable mprint*/
    %if %length(&debug.) %then %do;
        options mprint;
    %end;

    %*If the key2 parameter was not used, then assume the key variable has the same name in each table;
    %if not(%length(&key2.)) %then %do;
        %let key2 = &key.;
    %end;

    %*Assume that the only common variable name across both tables is the key variable;
    proc sql noprint; 
        CREATE TABLE &out_table. (drop = key_a key_b rename=(key = &key.)) AS
            SELECT coalesce(key_a, key_b) AS key, * %if %length(&newcol.) %then , &newcol.;
                                                  
              FROM &table1. (rename = (&key. = key_a) keep = &keep1.) 
                    
                    /*Apply the selected join type*/
                    %if &join_type. = inner %then INNER JOIN;
                    %else %if &join_type. = left OR &join_type. = left_anti %then LEFT JOIN;
                    %else %if &join_type. = right OR &join_type. = right_anti %then RIGHT JOIN;
                    %else %if &join_type. = full %then FULL JOIN;
                    %else %if &join_type. = cartesian OR &join_type. = cross %then CROSS JOIN; 
                    %else %if &join_type. = union %then UNION JOIN; 

                   &table2. (rename = (&key2. = key_b keep = &keep2.)
                            /*Drop repeated rows specified by the "repeated_vars" parameter*/
                            %if %length(&repeated_vars.) %then %do;
                                 %str() drop = &repeated_vars.
                            %end;
                        )

                ON key_a = key_b

            %if %length(&where.) AND &join_type. ne left_anti AND &join_type. ne right_anti %then WHERE &where.;

            /*Exclude the mutual rows if an anti-join is selected*/
            %if &join_type. = left_anti %then %do;
                WHERE key_b IS MISSING
            %end;
            %else %if &join_type. = right_anti %then %do;
                WHERE key_a IS MISSING
            %end;
            
            %if %length(&where.)  AND (&join_type. = left_anti OR &join_type. = right_anti) %then AND &where.;
            %else %if %length(&where.) %then WHERE &where.;
            ;

    quit;

    %if %length(&debug.) %then %do;
        options nomprint;
    %end;

%mend;

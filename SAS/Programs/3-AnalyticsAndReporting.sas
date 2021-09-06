***********************************************************************************************************************************************************************
*                                                                                                                                                                     *                                                                                            
*   Name:           3 - AnalyticsAndReporting.sas                                                                                                                     *                            
*                                                                                                                                                                     *
*   Description:    Creates various reports using the data created earlier in the workflow                                                                            *
*   Parameters:     Required:                                                                                                                                         * 
*                                                                                                                                                                     *
*                   Optional:                                                                                                                                         *                             
*                                                                                                                                                                     *                           
*   Creation Date:  23 08 2021                                                                                                                                        *                              
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

%open_log_save(file=Section C)

proc sql noprint; 
/*Use the interests dictionary to create a macro variable, which is used to select which columns to keep*/
    SELECT activity INTO :activities SEPARATED BY " "
    FROM system.interestsDictionary;
quit;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

3.1.1 - Frequency for each interest

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
proc means data= detail.households_detail (keep = &activities.) noprint;
  format &activities. 8.;
  output out= marts.interests_freq_1 (drop = _TYPE_ _FREQ_) sum=;
run;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

3.1.2 - Frequency for each interest by age

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
%sqljoin(table1 = detail.households_detail, 
         table2 = detail.bookings,
         key = customer_id,
         out_table = staging.interests_freq_by_age,
         newcol = floor(yrdif(dob,departure_date)) AS age format = agefmt. label = "Age",
         repeated_vars = family_name)

proc means data= staging.interests_freq_by_age (keep = &activities. age)  noprint nway missing;
    class age;
    format &activities. 8.;
    output out= marts.interests_freq_2 (drop = _TYPE_ _FREQ_) sum=;
run;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

3.1.3 - Frequency for each interest by age, primary householders only

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
proc means data= staging.interests_freq_by_age (keep = &activities. age primary_householder where=(primary_householder = 1))  noprint nway missing;
    class age;
    format &activities. 8.;
    output out= marts.interests_freq_3 (drop = _TYPE_ _FREQ_ primary_householder) sum=;
run;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

3.2.1 - Report by gender

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
proc means data= detail.households_detail (keep = &activities. gender)  noprint nway;
    class gender;
    format &activities. 8.;
    output out= marts.interests_freq_4 (drop = _TYPE_ _FREQ_  ) sum=;
run;

proc transpose data = marts.interests_freq_4 out = staging.transposed_interests_gender name = Activity;
    id gender;
run;

proc sql;
    CREATE TABLE marts.interests_freq_4(rename=(F = Freq _label_ = Activity)) AS
        SELECT * FROM staging.transposed_interests_gender (keep = _label_ F )
        ORDER BY F desc;

    CREATE TABLE marts.interests_freq_5 (rename=(M = Freq _label_ = Activity)) AS
        SELECT * FROM staging.transposed_interests_gender (keep = _label_ M )
        ORDER BY M desc;
quit;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Printing

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
ods pdf file="&root.\SAS\Reports\3.1-InterestsFreq.pdf";
title1 "Frequency Analysis of Interests:";
title2 "ungrouped";
%print(lib=marts, file=interests_freq_1, noobs = true)
title2 "by age";
%print(lib=marts, file=interests_freq_2, noobs = true)
title2 "by age (primary householder only)";
%print(lib=marts, file=interests_freq_3, noobs = true)
ods pdf close;

ods excel file="&root.\SAS\Reports\3.2-InterestsFreqGender.xlsx";
ods excel options( sheet_name = "Female (top 5)"); /*embedded_titles ="yes" option*/
%print(lib=marts, file=interests_freq_4, obs = 5, noobs = true, nolabel = true)
ods excel options( sheet_name = "Male (top 5)");
%print(lib=marts, file=interests_freq_5, obs = 5, noobs = true, nolabel = true)
title;
ods excel close;

%close_log_save




/**/
/*/*------Revenue per year--------------------------------------------------------------------------------------------------------------*/*/
/*proc sql; */
/*    CREATE TABLE test2 AS*/
/*        SELECT year(booked_date) AS year label = "Year"*/
/*               , sum(holiday_cost) AS total_revenue format = nlmnlgbp. label = "Total Revenue"*/
/*        FROM raw.bookings*/
/*        GROUP BY year*/
/*        ORDER BY year */
/*        ;*/
/*quit;*/
/*proc sgplot data=test2 ;*/
/*     scatter x=year  y=total_revenue /  markerattrs=(symbol=dot size=25 color=black) ;*/
/*run;*/
/**/
/*/*------Revenue per day--------------------------------------------------------------------------------------------------------------*/*/
/*proc sql; /*Revenue per year*/*/
/*    CREATE TABLE test1 AS*/
/*        SELECT booked_date */
/*               , sum(holiday_cost) AS total_revenue format = nlmnlgbp. label = "Total Revenue"*/
/*        FROM raw.bookings*/
/*        GROUP BY booked_date*/
/*        ORDER BY booked_date */
/*        ;*/
/*quit;*/
/**/
/*proc sgplot data=test1 ;*/
/*     scatter x=booked_date  y=total_revenue /  markerattrs=(symbol=dot size=2 color=black) ;*/
/*run;*/
/**/
/*/*------ Distribution of number of holidays booked --------------------------------------------------------------------------------------------------------------*/*/
/*proc sql; */
/*    CREATE TABLE test3 AS*/
/*        SELECT booked_date */
/*               , count(*) AS num_holidays*/
/*        FROM raw.bookings*/
/*        GROUP BY booked_date*/
/*        ORDER BY booked_date*/
/*        ;*/
/*quit;*/
/*proc sgplot data=test3 ;*/
/*     scatter x=booked_date  y=num_holidays /  markerattrs=(symbol=dot size=2 color=black) ;*/
/*run;*/
/**/
/**/
/**/
/*proc sql; */
/*    CREATE TABLE test4 AS*/
/*        SELECT year(booked_date) AS year label = "Year"*/
/*               , count(*) AS freq_surname*/
/*               , family_name AS surname*/
/*        FROM raw.bookings*/
/*        GROUP BY family_name*/
/*        ORDER BY freq_surname desc*/
/*        ;*/
/*quit;*/
/**/
/**/
/**/
/*proc sgplot data=test4 ;*/
/*     vbar freq_surname ;*/
/*run;*/
/**/
/**/
/*/*Analysis on the relative performance of the share price via loyalty data. Suppose that 1 share is worth £1 today for simplicity*/*/
/*proc sql;*/
/*    CREATE TABLE stock_price AS*/
/*        SELECT invested_date AS date*/
/*               ,  initial_value/current_value AS price label = "Price per share"*/
/*        FROM raw.loyalty*/
/*        HAVING abs(price) < 2;*/
/*run;*/
/**/
/*proc sgplot data=stock_price ;*/
/*     scatter x=date  y=price /  markerattrs=(symbol=dot size=2 color=black) ;*/
/*run;*/
/**/
/**/
/**/
/**/
/**/
/*proc format lib = shared;*/
/*    value season 3-5     = 'Spring'*/
/*                 6-8     = 'Summer'*/
/*                 9-11    = 'Autumn'*/
/*                 1-2, 12 = 'Winter';*/
/*run;*/
/*proc sql; /*Revenue per year*/*/
/*    CREATE TABLE test5 AS*/
/*        SELECT year(departure_date) AS year label = "Year"*/
/*               , month(departure_date) AS season label = "Season" format = season.*/
/*               , departure_date format = season.*/
/*               , sum(holiday_cost) AS total_revenue format = nlmnlgbp. label = "Total Revenue"*/
/*        FROM raw.bookings*/
/*        GROUP BY departure_date*/
/*        HAVING 2012 <= year AND year <= 2014*/
/*        ORDER BY departure_date*/
/*        ;*/
/*quit;*/
/**/
/*proc sgplot data=test5;*/
/* scatter x=season y=total_revenue ;*/
/*run;*/
/**/
/**/
/**/
/**/

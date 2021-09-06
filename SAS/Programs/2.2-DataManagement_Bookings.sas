***********************************************************************************************************************************************************************
*                                                                                                                                                                     *                                                                                            
*   Name:           2.2 - DataManagement_Bookings.sas                                                                                                                 *                            
*                                                                                                                                                                     *
*   Description:    1 -  Use the destination table to format the corresponding column in the bookings table                                                           *
*                   2 -  Split the bookings data_set into booking 6 or more weeks prior                                                                               *
*                   3 -  Save the remaining data from part 2 above                                                                                                    *
*                                                                                                                                                                     *
*   Parameters:     Required:                                                                                                                                         * 
*                                                                                                                                                                     *
*                   Optional:                                                                                                                                         *                             
*                                                                                                                                                                     *                           
*   Creation Date:  20 08 2021                                                                                                                                        *                              
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

%open_log_save(file=Section B - 2)

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

2.2.1 - Formatting the destination_code column in Bookings

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*Create a format called "$destination_fmt, put it in the shared library */
data staging.destinations_fmt;
    retain fmtname "$destination_fmt" type "C";
    set raw.destinations(rename = (code = start description = label));
run;
proc format lib = shared cntlin = staging.destinations_fmt;
run;

/*Apply the new format to the destination_code column*/
data staging.bookings;
    format destination_code $destination_fmt.;
    set raw.bookings;
run;
proc print data = raw.bookings(obs=30);
run;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

2.2.2 - Create the bookings_deposit table
2.2.3 - Create the bookings_balance table

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
proc sql;
    CREATE TABLE detail.bookings AS
        SELECT * , 
               0.2 * holiday_cost as deposit,
               0.8 * holiday_cost as balance      
        FROM staging.bookings
        ORDER BY booked_date;
quit;

data marts.bookings_deposit marts.bookings_balance;
    set detail.bookings;
    if abs(intck("day", booked_date, departure_date, "continuous")) > 42 then output marts.bookings_deposit;
    else output marts.bookings_balance;
run;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Printing

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
%put "&root.\SAS\Reports\2.2-DataManagement.pdf";

ods pdf file="&root.\SAS\Reports\2.2-DataManagement.pdf";
title1 "Bookings:";
title2 "Deposit (booked over 6 weeks before start)";
%print(lib=marts, file=bookings_deposit, noobs = true, obs = 30)
title2 "Balance (booked 6 or fewer weeks before start)";
%print(lib=marts, file=bookings_balance, noobs = true, obs = 30)
title;
ods pdf close;

%close_log_save
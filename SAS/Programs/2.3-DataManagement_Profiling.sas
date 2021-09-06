***********************************************************************************************************************************************************************
*                                                                                                                                                                     *                                                                                            
*   Name:           2.3 - DataManagement_Profilings.sas                                                                                                               *                            
*                                                                                                                                                                     *
*   Description:    1 -  Join the loyalty and households datasets   ADD MORE                                                                                          *
*                   2 -  Create a table of the customers who aren't in the bookings table                                                                             *
*                   3 -  Create a table of the primary householders for households who booked several times                                                           *           
*                                                                                                                                                                     *
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

%open_log_save(file=Section B - 3)

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

2.3.1 - Formatting the destination_code column in Bookings

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
%sqljoin(table1 = raw.households, 
         table2 = raw.loyalty,
         key = loyalty_id,
         out_table = detail.shareholders)

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

2.3.2.1 - Create the households_only dataset

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
%sqljoin(table1 = detail.households_detail, 
         table2 = detail.bookings,
         key = customer_id,
         out_table = detail.households_only,
         join_type = left_anti,
         repeated_vars = family_name)

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

2.3.2.2 - Formatting the destination_code column in Bookings

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
proc format lib = shared;
    value agefmt low - 17 = "Under 18"
                  18 - 24 = "18-24"
                  25 - 34 = "25-34"
                  35 - 44 = "35-44"
                  45 - 54 = "45-54"
                  55 - 64 = "55-64"
                65 - high = "65+"
                    other = "Missing";
run;

proc sql;
    CREATE TABLE detail.bookings_multi (drop = fname_a fname_b id_a id_b) AS
        SELECT *,
               coalesce(fname_a, fname_b) AS family_name,
               coalesce(id_a, id_b) AS customer_id label = "Customer ID",
               count(household_id) AS freq label = "Frequency",
               CASE
                   WHEN missing(dob) THEN .
                   ELSE dobage(dob, departure_date) 
               END AS age label = "Age" format = agefmt.
        FROM detail.households_detail (where =(primary_householder = 1) rename =(family_name = fname_a customer_id = id_a)) a
                INNER JOIN  /*If we used a right join, we'd be unable to know if it's a primary householder*/
                detail.bookings(rename =(family_name = fname_b customer_id=id_b)) b
        ON id_a = id_b
        GROUP BY household_id
        HAVING freq > 1;
quit;

%close_log_save
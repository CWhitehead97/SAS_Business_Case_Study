***********************************************************************************************************************************************************************
*                                                                                                                                                                     *                                                                                            
*   Name:           1-ImportingInputData.sas                                                                                                                          *                            
*                                                                                                                                                                     *
*   Description:    Using files in the Inputs folder, 'bookings.csv, destinations.csv, households.csv, loyalty.dat', produce SAS tables in the Raw folder             *                                                                                                            
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


/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    Import .csv files using Data Steps (dsd option)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
%open_log_save(file=Section A) 

data raw.households;
    length family_name $17 
           forename $11
           title $5 
           gender $6 
           loyalty_id $10
           address_1 $51 
           address_2 $43 
           address_3 $42 
           address_4 $16
           postcode $8 
           email1 $45 
           contact_preference $18 
           interests $9;

	infile inputs(Households.csv) dsd firstobs = 2;

	input customer_id family_name $ forename $
          title $ Gender $ dob :date9. loyalty_id $
          address_1 $ address_2 $ address_3 $ address_4 $
          Postcode $ email1 $ contact_preference $ interests $ customer_startdate :date9. contact_date :date9.; 

    format dob customer_startdate contact_date date9.;

	label	customer_id = 'Customer Identification'
            postcode = 'Postcode'
			family_name = 'Family Name'
            forename = 'Forename'
            gender = 'Gender'
            title = 'Title'
            address_1 = "Address1"
            address_2 = "Address2"
            address_3 = "Address3"
            address_4 = "Address4"
			customer_startdate = 'Customer Enrolment Date'
			contact_date = 'Date Customer last contacted'
			dob = 'Date of Birth'
			contact_preference = 'Customer Contact Preference'
			loyalty_id = 'Loyalty Identification'
			Interests = 'Customer Interests'
			Email1 = 'Email Address';

run;

data raw.destinations;
	length	description $23;

	infile inputs(Destinations.csv) dsd firstobs=2;

	input	code $ description $;
run;

data raw.bookings;
	length	Family_Name $17
	       	room_type $9;

	infile  inputs(Bookings.csv) dsd firstobs=2;
	
	input	family_name $ brochure_code $ room_type $ booking_id $ customer_id booked_date :date9. departure_date :date9.
			duration pax insurance_code  holiday_cost :nlmnlgbp8.2 destination_code $;
	
	format	booked_date departure_date date9.
            holiday_cost nlmnlgbp8.2;
	
	label	booking_id = 'Booking ID'
			customer_id = 'Customer ID'
			family_name = 'Family Name'
			brochure_code = 'Brochure of Destination'
			booked_date = 'Date Customer Booked Holiday'
			departure_date = 'Holiday Departure Date'
			duration = 'Number of Nights'
			pax = 'Number of Passengers'
			insurance_code = 'Customer Added Insurance'
			room_type = 'Room Type'
			holiday_cost = 'Total Cost (£) of Holiday'
			destination_code = 'Destination Code';	
run;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    Import .dat file using Data Steps (delimiter = '09'x option)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

data raw.loyalty;
	length	investor_type $10;

	infile  inputs(Loyalty.dat) delimiter='09'x firstobs=2;

	input	account_id $ loyalty_id $ invested_date :date9. initial_value investor_type $ current_value;
	
	format	invested_date date9.;
	
	label	Loyalty_Id = 'Loyalty Identification'
			Account_Id = 'Customer Account Identification'
			Initial_Value = 'Initial Share Value'
			Investor_Type = 'Type of Investor'
			Current_Value = 'Current Share Value'
			Invested_Date = 'Investment Date';
run;


/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Create contents report of Files

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
ods pdf file = "&root.\SAS\Reports\1.1-InputDataContents.pdf";

title1 "Metadata of Created Table:";
title2 "Households";
proc contents data = raw.households;
run;
title2 "Destinations";
proc contents data = raw.destinations;
run;
title2 "Bookings";
proc contents data = raw.bookings;
run;
title2 "Loyalty";
proc contents data = raw.loyalty;
run;
title;

ods pdf close;


/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Create a data set containing each "interest" in the households data, and the corresponding code values

------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
data system.interestsDictionary;
    input activity $20. codes $3.;
    datalines;
Mountaineering      AKL
Water_Sports        B
Sightseeing         CX
Cycling             D
Climbing            E
Dancing             FW
Hiking              HG
Skiing              J
Snowboarding        M
White_water_rafting N
Scuba_diving        PQR
Yoga                S
Mountain_biking     TU
Trail_Walking       VYZ
;
run;

%close_log_save



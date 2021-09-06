_*Case Study*_

   This is a case study to demonstrate the processing and analysis of data from a travel agency. 

_*Installation*_

   1) To generate the required directory structre, edit the 'root' macro variable inside of 'autoexec.sas' and run the program.

   2) If not done already, put the following files inside the "SAS\Programs" folder in the root directory:
	1-ImportingInputData.sas, 2.1-DataManagement_Households.sas, 2.2-DataManagement_Bookings.sas, 2.3-DataManagement_Profiling.sas, 3-AnalyticsAndReporting.sas

   3) Place the following programs inside the "SAS\Macros":
	open_log_save.sas, close_log_save.sas, print.sas, sqljoin.sas

   4) Place the createFunctions.sas file in the "SAS\Shared" folder and run it.

   5) Place the following files inside the SAS\Data\Inputs:
	bookings.csv, destinations.csv, households.csv, loyalty.dat

_*Usage*_

   Run the files inside of the Programs folder in sequential order. Reports will be generated inside the
   "SAS\Reports" folder and the log for each program will be saved in the "SAS\Logs" folder.

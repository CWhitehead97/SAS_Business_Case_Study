***********************************************************************************************************************************************************************
*                                                                                                                                                                     *                                                                                            
*   Name:           open_log_save.sas                                                                                                                                 *                            
*                                                                                                                                                                     *
*   Description:    A macro to print a dataset via proc print                                                                                                         *                                          
*                                                                                                                                                                     *                                   
*   Parameters:     Required:     file - The name of the file to save the log to                                                                                      *                                                        
*                                                                                                                                                                     *
*                   Optional:     file_type - The file extension to use when saving the output log                                                                    *                 
                                  out_dir - The path to the folder where the log should be saved                                                                      *                            
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

%macro open_log_save ( file=, file_type=log, out_dir=&root.\SAS\Logs);
	%if %quote(%length((&file.)))=0 %then %put
		%str(ER)ROR: The parameter "file" is required;
	%else %do;
		proc printto log="&out_dir.\&file..&file_type.";
		run;
	%end;
%mend;




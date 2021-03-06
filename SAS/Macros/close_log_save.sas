***********************************************************************************************************************************************************************
*                                                                                                                                                                     *                                                                                            
*   Name:           close_log_save.sas                                                                                                                                *                            
*                                                                                                                                                                     *
*   Description:    A macro to stop recording the log                                                                                                                 *                                          
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

%macro close_log_save;
	proc printto;
	run;
%mend;
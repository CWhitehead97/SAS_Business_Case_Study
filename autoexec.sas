***********************************************************************************************************************************************************************
*                                                                                                                                                                     *                                                                                            
*   Name:           autoexec.sas                                                                                                                                      *                            
*                                                                                                                                                                     *
*   Description:    Opens relevant SAS libraries for the projects. Searches the Shared folder for formats and the Macro folder for autocall Macros. Also adjusts      *
*                   some system options.                                                                                                                              *
*                                                                                                                                                                     *
*   Parameters:     Required:    root                                                                                                                                 * 
*                                                                                                                                                                     *
*                   Optional:                                                                                                                                         *                             
*                                                                                                                                                                     *                           
*   Creation Date:  18 08 2021                                                                                                                                        *                              
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

/*Do not include a backslash at the end of the filepath*/
%let root = ;

/*======================================================================================================================================================================
||   DO NOT EDIT BELOW THIS LINE                                                                                                                                      ||
======================================================================================================================================================================*/

/* Creates the required folders if it doesn't already exist*/
data _null_;
  length folder $25;
  input folder $ &;
  new_folder=scan(folder,-1,'\');
  call scan(folder,-1,pos,len,'\');
  parent_folder=cats("&root\",substrn(folder,1,pos-2));
  full_path=dcreate(new_folder,parent_folder);
datalines;
SAS
SAS\Data
SAS\Data\Inputs
SAS\Data\Raw
SAS\Data\Staging
SAS\Data\Detail
SAS\Data\Marts
SAS\Data\Exceptions
SAS\Data\Metadata
SAS\Macros
SAS\Shared
SAS\Programs
SAS\Logs
SAS\Reports
run;

/* Set up libraries for all the Data subfolders*/
filename inputs "&root.\SAS\Data\Inputs";
libname detail "&root.\SAS\Data\Detail";
libname marts  "&root.\SAS\Data\Marts";
libname raw  "&root.\SAS\Data\Raw";
libname staging  "&root.\SAS\Data\Staging";
libname except "&root.\SAS\Data\Exceptions";
libname system "&root.\SAS\Data\MetaData";

/*Shared items, including formats*/
libname shared "&root.\SAS\Shared";

/*The autocall macro folder*/
filename macros "&root.\SAS\Macros";

/*The folder to save reports*/
filename reports "&root\SAS\Reports\";

/*Change some SAS options*/
options fmtsearch = (shared)
        mautosource
        sasautos = (macros sasautos)
        cmplib = shared.funcs
        nofmterr /*No format error*/
        msglevel  = i
        mcompilenote = noautocall
        nodate
        nonumber
        missing=""
        ;
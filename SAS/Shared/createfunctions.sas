***********************************************************************************************************************************************************************
*                                                                                                                                                                     *                                                                                            
*   Name:           createfunctions.sas                                                                                                                               *                            
*                                                                                                                                                                     *
*   Description:    Creates the functions required for this case study                                                                                                *                          
*   Creation Date:  20 08 2021                                                                                                                                        *                              
*                                                                                                                                                                     *
*   Created By:     Colm Whitehead                                                                                                                                    *                                  
*                                                                                                                                                                     *
*   Edit History:                                                                                                                                                     *                 
*   +----------------+----------+---------------------------------------------------------------------------------------------------------------------------------+   *
*   |   Programmer   |   Date   |   Description                                                                                                                   |   *                                              
*   +----------------+----------+---------------------------------------------------------------------------------------------------------------------------------+   *
*   |Colm Whitehead  |23 08 2021| Added a label to dobag()  and a function greeting()                                                                             |   *
*   +----------------+----------+---------------------------------------------------------------------------------------------------------------------------------+   *
*   |                |          |                                                                                                                                 |   *
*   +----------------+----------+---------------------------------------------------------------------------------------------------------------------------------+   *
**********************************************************************************************************************************************************************;

proc fcmp outlib = shared.funcs.dates;
    function dobage(dob, now) label = "Returns the integer part of the year difference";
        return(floor(yrdif(dob,now)));
    endsub;
quit;

proc fcmp outlib = shared.funcs.strings;
    function greeting(title $, forename $, family_name $) $ label = "Makes a formal greeting given a title, forename and surname. Corrects the case of the strings.";
            return(catx(" ","Dear", propcase(title), upcase(substr(forename,1,1)), propcase(family_name)));
    endsub;
quit;
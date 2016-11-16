# SmartScreener
Web Site for displaying and filtering stock charts build with IQFeed API data.

You`ll need radis server, containing ticker data in CSV format to update data. 
Key value consist of PERIOD+"-"+TICKER. Look at sources for more info.
I was using python based multithreading IQFeed API client, to export data from IQFeed app to radis.

Charts are dynamic and based on TechanJS.

There is production database already containing old data as a sample.

All rights for used components preserved.

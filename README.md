Database import / export Rake tasks
===================================

This Rake extension provides many ways to import / export data to / from database. At this time, the available tasks only deal with CSV format.

Available tasks are :

* *db:import:csv* - Import data from a CSV file right into the table associated to a given model
* *db:export:csv* - Export data from the given model table into a CSV file
* *db:export:csv:all* - It checks for presence, length, format and uniqueness. There is no guarantee that a validated email is real and deliverable.

Installation
------------

In your Rails app root, use the following command-line: 

	cd lib/tasks
	git clone git://github.com/synbioz/database.rake.git database
	
Usage
-----

Import data from a CSV file into given model table:

	# Your CSV file has headers
	rake db:import:csv MODEL=my_model_to_fill CSV=path_to_csv_file.csv

	# You want to purge the table before importing data
	rake db:import:csv MODEL=my_model_to_fill CSV=path_to_csv_file.csv PURGE=boolean

	# Your CSV file has no headers, fieldnames can be deduce, you have to specify it
	rake db:import:csv MODEL=my_model_to_fill CSV=path_to_csv_file.csv FIELDS=field1_name,field2_name,...

Export given model data into CSV file:

	# Data will be written to a file having the same name as the given model
	rake db:export:csv MODEL=model_name
	
	# Data will be written to the specified file
	rake db:export:csv MODEL=model_name CSV=path_for_the_generated_csv_file.csv

Export all models data into many CSV files:
	
	# All models data will be exported in separated CSV files according to their name
	rake db:export:csv:all
	
Other
-----

For more information see [Project homepage](http://github.com/synbioz/database.rake)

Problems, comments, and suggestions are welcome on the [issues system](http://github.com/synbioz/database.rake/issues)

Copyright (c) 2010 Synbioz, released under the MIT license
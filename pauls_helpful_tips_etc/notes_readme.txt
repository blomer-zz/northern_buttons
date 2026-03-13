This is a place to put helpful notes regarding this application

************************
*** Android Database ***
************************
Note: use Git Bash and NOT Powershell to run the command
Powershell will convert the .db file into UTF...somethin code,
but it needs to stay binary...I think that's the issue(?)
Git Bash command:
adb exec-out "run-as com.example.northern_buttons 
cat databases/northern_buttons.db" > northern_buttons.db

Then get your current working directory located to the 
northern_buttons.db file and you can access it using 
sqlite3 - and you can access it with Powershell, I believe


*********************************
*** Windows Database location ***
*********************************
C:\Users\blomer\zPaulsFiles\FlutterPauls\northern_buttons\.dart_tool\sqflite_common_ffi\databases\northern_buttons.db


**************
*** Claude updated database to make sqlite3 dates accurate and able to query ***
**************
After that, invoice_date will be stored as "2025-09-02" instead of "9/2/2025" 
for all historical records. New invoices created by the app (Phase 3) will use 
DateTime.now().toIso8601String().substring(0, 10) 
to match the same format.
(previously the database was just storing dates as TEXT. Sqlite doesn't have a way
of storing a DATE type, so it still uses TEXT - I think - but in a way that makes it
query-able)
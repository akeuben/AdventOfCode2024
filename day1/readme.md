# Day 1
I decided to implement the solution to day 1 using SQL using MariaDB as my DBMS.

## Input file
MariaDB will only load from a file (as far as I know) from the `/var/lib/mysql` directory.
For convenience, I've created the `copy_input.sh` script to copy the input file to that
directory. All of the calculations are still done using SQL, and this script can be ignored
if the file is manually copied.

# LIBER

<p align="center">
<img src="images/logo.JPG" />
</p>

by Bardia Parmoun and Christopher Shen

Released on: 12/17/2021

## Description

- Liber is an online bookstore which allows users to browse their favourite books and order them online.
- The users have the option of searching for the books using their title, ISBN, author name, and genre.
- LIBER also gives the staff the option of modifying the details for any books and it generates custom sales reports.

## Installaion

LIBER takes advantage of PostgreSQL and Apache servers. Proper installations of these softwares is required for LIBER to work properly.

1. Installing Apache (XAMPP):\
The recommended software for running an Apache server is an instance of the XAMPP (or LAMP) software. The latest version of XAMPP can be found here:\
[Install XAMPP](https://www.apachefriends.org/download.html)

2. Intalling PostgreSQL:\
LIBER was developed using PostgreSQL and as a result a proper installation of PostgreSQL is required. The latest version of this software can be found here:\
[Install PostgreSQL](https://www.postgresql.org/download/)

3. After PostgreSQL is installed make sure locate to the [SQL](https://github.com/bardia-p/LIBER/tree/master/SQL) folder to find the [dump](https://github.com/bardia-p/LIBER/tree/master/SQL/Bookstore-dump.sql)file for the Bookstore database.
4. Create a local version of that database and name it "Bookstore" and load the dump file.
5. Locate to the [liber-config.inc.php](https://github.com/bardia-p/LIBER/blob/master/includes/liber-config.inc.php) file to change the username and pass with your version.
6. Move the updated version of the repository under the "htdocs" folder in the installation folder for XAMPP. The path will most likely be the following for windows machines: 
```
C:\xampp\htdocs
```
## Running LIBER
1. Open XAMPP and start your Apache instance.
<p align="center">
<img src="images/xampp.JPG" />
</p>

2. Make sure your instance of PostgreSQL is running.
   
3. Once both the Apache server and the Postgres servers are running you can start the program by going to the following url:
```
http://localhost/liber/home.php
```

## Using LIBER
For a detailed explanation of how to navigate LIBER, please refer to the following video:\
[LIBER Demo]()

## LIBER Design Process
If you want to learn more about the design process for LIBER, locate to the following folders:
1. [ER and Schema Diagrams](https://github.com/bardia-p/LIBER/tree/master/diagrams)
2. [Design Report](https://github.com/bardia-p/LIBER/blob/master/documents/Project_Report.pdf)

## CREDITS
Authors: Bardia Parmoun and Christopher Shen

Copyright © 2021 Bardia Parmoun & Christopher Shen. All rights reserved

---
layout: post
title:  "Simple Scraper"
date:   2018-12-7 1:00:00
categories: programming
---

This is something that I did a while ago but kept forgetting to post. I needed to build a web scaper of sorts that would save online data at certains times of the day. Since I did not have a desktop or my own server I needed to find a location for my scripts to run on their own. For this purpose I chose Amazon Web Service (AWS). At the time AWS provided a basic free EC2 instance (Amazon Elastic Compute Cloud). In Amazon's owns words EC2 can be used 'to launch as many or as few virtual servers as you need, configure security and networking, and manage storage'. Essentially it is a computer that runs nonstop and you connect to set and specify tasks for it to work on. For the example in this post I scraped the [weather](https://github.com/uWaterloo/api-documentation/blob/master/v2/weather/current.md) in Waterloo (I scrapped other stuff as well). 

This post will skip the details for setting up an EC2 instance. There are many good resources for that such as [here](). The actual script for 'scraping' the data is simple:
The script for recording the weather:

*scrape.py*

```
#!/usr/bin/python
import requests
import json
import time
import os

response = requests.get("https://api.uwaterloo.ca/v2/weather/current.json")
if response.status_code == 200: #200 means everything is OK
	json_data = json.loads(response.text)
	current_temperature = json_data["data"]["temperature_current_c"]
	
	#record temperature in file with current date
        os.environ['TZ']='America/New_York'
	current_date_file = time.strftime("%Y_%m_%d_%H.txt")

	#files are stored in folder called data
	if not os.path.exists("data"):
		os.makedirs("data")
				
	f = open("data/"+current_date_file, "a+")
	f.write(str(current_temperature)+"\n")
	f.close()
else:
	raise RuntimeError("API request failed.") 
```  
   
A response is obtained from api.uwaterloo.ca which contains all sorts of weather data. Only the current temperature in celcius is saved in a file with format `%Y_%m_%d_%H.txt` in directory `data`. Let's assume your script is running on this instance scraping data on a daily basis. What if something goes wrong? A very easy/rough (not best) solution uses my previous [post](http://szonov.com/programming/2017/07/16/Creating-a-notification/) describing how to send yourself an email by using curl. This leads to the following error handling, wrapper script:

*dailyScript.sh*

```
#!/bin/bash

#assuming scrape.py is located in /home/ec2-user
cd /home/ec2-user

#if scrape.py crashes then we can check for error in error_file.txt
/usr/bin/python scrape.py 2>>error_file.txt

#if file is present and has size greater than zero
if [[ -s error_file.txt  ]]; then
	#if the file is not empty then we must alert the server that something is wrong
	curl -L "https://script.google.com/macros/s/some_sort_of_id/exec?subject=SERVER_ERROR&message=AWS_SCRIPT_HAS_CRASHED_NEED_TO_FIX_INFO"
else
	#backup and communicate that everything is OK
	curl -L "https://script.google.com/macros/s/some_sort_of_id/exec?subject=Working&message=Everything_is_working"
fi

```
Once an error happens for the first time then you will be emailed until you fix the error (and `rm error_file.txt`). However, this if-else does not catch the error of the `dailyScript.sh` not running in the first place. Now, let's add the additional feauture of backing up our scraped results. A nice of doing this (for small amounts of data) involves using a private Github repository. First you need to allow your EC2 to connect to github without entering your password. Within your EC2 instance:
```
$ cd ~
$ ssh-keygen -t rsa
``` 
(and press enter all the way through). Go to `github.com > settings` and copy the contents of your `~/.ssh/id_rsa.pub` into the field labeled 'Key'. Then on the EC2:
```
git remote set-url origin git+ssh://git@github.com/username/insert_your_repo_name.git
```
where `insert_your_repo_name` is a private repo you will make on github.com. Next modify *dailyScript.sh* to push/backup the newly added `%Y_%m_%d_%H.txt` file:
```
#!/bin/bash

cd /home/ec2-user/insert_your_repo_name

#if scrape.py crashes then we can check for error in error_file.txt
/usr/bin/python scrape.py 2>error_file.txt

#if file is present and has size greater than zero
if [[ -s error_file.txt  ]]; then
	#if the file is not empty then we must alert the server that something is wrong
	curl -L "https://script.google.com/macros/s/some_sort_of_id/exec?subject=SERVER_ERROR&message=AWS_SCRIPT_HAS_CRASHED_NEED_TO_FIX_INFO"
else
	#backup and communicate that everything is OK
	git add .
	git commit -m "backup"
	git push
	curl -L "https://script.google.com/macros/s/some_sort_of_id/exec?subject=Working&message=Everything_is_working"
fi

```
(where *scrape.py* and *dailyScript.sh* are located within `insert_your_repo_name`). All that is left to do is make sure the scripts run and records the weather at set hours of the day everyday. Let's say that you are interested in recording the weather every day at 0000,0600,1200,1800 then you would have to call `dailyScript.sh` at those times. This can be done using `crontab`. In your EC2 instance you run
```
$ crontab -e
```
and enter
```
CRON_TZ=America/New_York
0 0,6,12,18 * * * cd /home/ec2-user/insert_your_repo_name; ./dailyScript.sh
```
(don't forget to `chmod u+x dailyScript.sh`). You have now created a scraper that runs on its own that backups the data with emails if there is something wrong. 


#### Bonus content

Let's assume the scraper has already been running for a while. And you now want to analyse the temperature results on local. We will do this using mysql:

```
$ sudo apt-get update
$ sudo apt-get install mysql-server
$ mysql_secure_installation
```

Create file *createTable.sql*:
```
CREATE DATABASE IF NOT EXISTS weather_data;
USE weather_data;
DROP TABLE IF EXISTS temperature_waterloo;
CREATE TABLE temperature_waterloo (YEAR INT NOT NULL, MONTH INT NOT NULL, DAY INT NOT NULL, HOUR INT NOT NULL, TEMPERATURE DOUBLE NOT NULL, ID VARCHAR(13) NOT NULL) 
```

and run in order to create table organize the temperature data 
```
sudo mysql < createTable.sql
```

Now clone the repository and cd into the directory with all the `%Y_%m_%d_%H.txt` files and run the following script to fill the table:

*loadData.sh*

```
#!/bin/bash

for file in data/*.txt
do
	#echo $file
		
	cat $file | while read temperature; do
		id=${file##*/}
		id=${id%.txt}
		arr=($(echo $id | awk -F '_' '{print $1, $2, $3, $4}' ))
		year=${arr[0]}
		month=${arr[1]}
		day=${arr[2]}
		hour=${arr[3]}
		echo "USE weather_data;INSERT INTO temperature_waterloo (YEAR,MONTH,DAY,HOUR,TEMPERATURE,ID) VALUES ($year, $month, $day, $hour, $temperature,'$id');"
	done | sudo mysql 

done
```

and run `./loadData.sh`. Now we have the data loaded and can run some queries:


```
$ sudo mysql;
mysql> USE weather_data;
mysql> SELECT COUNT(*) FROM temperature_waterloo;
+----------+
| COUNT(*) |
+----------+
|      900 |
+----------+
mysql> 
```

```
mysql> SELECT * FROM  (SELECT * FROM temperature_waterloo WHERE ID = (SELECT MAX(ID) FROM temperature_waterloo))xxx;
+------+-------+-----+------+-------------+---------------+
| YEAR | MONTH | DAY | HOUR | TEMPERATURE | ID            |
+------+-------+-----+------+-------------+---------------+
| 2018 |     3 |   1 |   18 |         1.5 | 2018_03_01_18 |
+------+-------+-----+------+-------------+---------------+
mysql> SELECT * FROM  (SELECT * FROM temperature_waterloo WHERE ID = (SELECT MIN(ID) FROM temperature_waterloo))xxx;
+------+-------+-----+------+-------------+---------------+
| YEAR | MONTH | DAY | HOUR | TEMPERATURE | ID            |
+------+-------+-----+------+-------------+---------------+
| 2017 |     7 |  19 |   18 |        28.6 | 2017_07_19_18 |
+------+-------+-----+------+-------------+---------------+
```

The scraper ran from 2017/07/19 18:00 to 2018/03/01 18:00. Using similar queries we find the max temperature in this time period was 30.3 celcius and min temperature was -28.5. You can obviously do more complicated stuff with more interesting scraped data sets. This post was meant to show an ad-hoc way of scraping data that will remove the task of writing the scraper and will just let you focus on the data you are interested in.























---
layout: post
title:  "Creating a Notification"
date:   2017-07-16 22:00:00
categories: programming
use_math: false
---

Are you running some code that takes a long time to finish? Want to know exactly when it is done? 

Are you running some cron job? Want to know when some specific event occurs?

Want to know via email?



A simple way to solve your questions is to use Google App Script and create a web app:

1. Open up your Google Drive.

2. Create a new Google App Script called `AlertMessage`

3. Add the code to `code.gs`   
	```javascript
	function doGet(request) {
		MailApp.sendEmail("your@gmail.com", request.parameter.subject, request.parameter.message);
		var result = {
			sent: 0 == 0
		};
		return ContentService.createTextOutput(JSON.stringify(result))
	}
	```

   Where `your@gmail.com` is your Google email account on which you made the Google App Script.

4. `Publish > Deploy as web app...`.

5. Who has access to the app:`Anyone, even anonymous`

6. Press `Deploy` and give the appropriate permissions.

7. Copy the full current web app URL: `https://script.google.com/macros/s/.../exec` (`...` is the Google generated portion)

8. On your computer terminal you can now send notifications via:  
	```
	curl -L "https://script.google.com/macros/s/.../exec?subject=TITLE&message=UNDERSCORE_FOR_SPACES_INSIDE_MESSAGE"
	```
	which will cause your Gmail inbox to get a new message.



This is a very simple script that can be modified to do some really neat stuff. Hope this helps.


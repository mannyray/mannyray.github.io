---
layout: post
title:  "Piano Robot"
date:   2016-11-20 00:27:00
categories: programming
---

Back in September, I had the wonderful opportunity to participate in my first hackathon at Hack the North. It was nice to see so many enthusiastic people filled with ideas and talent all concentrated in one area. The keynote speaker: Vinod Khosla, presented his opinions and experiences that were inspiring to see. I especially enjoyed his views on focus and motivation from his life with which he achieved great success. A video of the interview is [here](https://www.youtube.com/watch?v=0FNsFPjdm5U).


During the hackathon, I worked with Michael Li and Joe Seng. We decided to create something physical instead of an app. We wanted to create a robot that did something on its own without any assistance. We settled on the idea of building a robot that played on a piano. For the robot, we used a couple of sets of [lego mindstorm](https://en.wikipedia.org/wiki/Lego_Mindstorms) kits we had laying around. 


When we started the project we did not realize how difficult it would be to get the motions of the robot down. Having the robot press a single key with consistent results or even different keys were two problems that took hours to solve. Our lack of lego building skills came to light early on and gave us a little bit of frustration. However, there were tons of moments of laughter during our tests where the robot aggressively tried to press the keys and ended up spinning out of control. 


We imagined that most of the time in the project would be spent writing up the code for the robot to play different melodies, but that was not the case. The construction of the robot took up so much time that I can proudly say that I took part in the "don't sleep" hackathon tradition.


Here is a picture of our robot during construction:

![image]({{ site.url }}/assets/legoBot.jpg)


And here is a [video](https://www.youtube.com/watch?v=er5BoZVnoGs&feature=youtu.be) of our robot in action.


One thing I learned is that debugging robots is very different from debugging code and mainly in its difficulty. When testing your code you can ( and you SHOULD ) create test cases and run them through your code. Every time you modify your code, you can rerun your test cases to see if your code produces the correct output to the specified input. This process is (usually) straightforward to set up and to automate.


In the case of a robot, you still have certain desired input-output sequences you are trying to achieve. However, you now have a lot more work in making sure your testing environment is consistent. The slightest change (as our group observed) can screw everything up. A slight shift of the robot's position as a result of pressing piano keys in the previous test will make the same test's rerun results completely different and unpredictable. Without the proper equipment/resources, achieving consistency is very difficult. I imagine that with the proper setup, the testing process for robots can be made to be similar to that of coding, but it would require a lot more effort in our case. (I do realize that this explanation is not completely bulletproof as code and their respective environments can get very complex as well - think concurrent and parallel programming for an example.)



This was my brief story of making a piano playing robot. I used to play a lot on the piano when I was younger, so it was somewhat interesting automating tunes that I used to play as a kid. By making this connection to automation, I immediately thought back to the ideas Vinod Khosla presented on artificial intelligence. The thoughts were promising on the potential of technology and how it can change our future and many aspects of our life.


At this moment, it is hard to predict or to fully appreciate how new technology will affect the future and our reaction to it. At least, in terms of robots and music, I think there is lots of room for creativity. However, with my past experience with music, I will still look for that human connection, effort and talent to fully enjoy and connect with music.

---
layout: post
title:  "Simple Online Realtime Tracker"
date:   2021-08-30 22:00:00
categories: programming
---

Hello dear reader! I come with another post about code related to my [prototype](https://szonov.com/programming/2021/03/28/prototype/) project. The [last post](https://szonov.com/programming/2021/08/15/controlling-dslr-using-android-app-raspberry-pi-and-gphoto2/) showcased code where an Android App was able to control a DSLR camera via Bluetooth with a Raspberry Pi's assistance. The Android App would send a capture image signal to the DSLR upon user's manual input on the Android App. For object detection applications we want to automate this based on some object's position.

For my prototype, I would take a high resolution picture with the DSLR when the object was detected in a specific range. In the gif below, this range would be the yellow box and the objects are oranges.

![]({{ site.url }}/assets/prototype/out.gif)

When a new orange enters the range box (scope) the Android app would send a take picture signal. In the image below is when the signal is taken. 

![img]({{ site.url }}/assets/prototype/video_capture.png)

And here is the picture taken by the DSLR (prototype setup so value of picture not important):

![img]({{ site.url }}/assets/prototype/IMG_6378.JPG)

### How does one track an object as it moves around the view of the Android's camera?

For this I used the Simple Online Realtime Tracker (SORT) algorithm based on

```
Bewley, Alex, et al. "Simple online and realtime tracking." 2016 IEEE international conference on image processing (ICIP). IEEE, 2016.
```

The SORT combines the Kalman Filter and Hungarian algorithm together to keep track of the bounding boxes an image detecting machine learning model would output for each frame of some video. Every frame the machine learning model tells you that _here_ is an orange and _there_ is an orange and _over there_. However, the image detecting machine learning model will not tell you that an orange in one frame at location X is the same orange at location Y. The SORT solves this problem.

I have created a Python implementation and then translated it to Java since that is the language used in Android App development. Developing and testing the algorithm in Python is easier. The code can be found [here](https://github.com/mannyray/sort). To get started with using the code go to

 - [https://github.com/mannyray/sort/tree/master/python_implementation](https://github.com/mannyray/sort/tree/master/python_implementation)
 - [https://github.com/mannyray/sort/tree/master/java_implementation](https://github.com/mannyray/sort/tree/master/java_implementation) 

For a detailed explanation of SORT algorithm and various ways you could tune its parameters please go to

 - [https://github.com/mannyray/sort/tree/master/python_implementation/example](https://github.com/mannyray/sort/tree/master/python_implementation/example)

The motiviation for creating this standalone SORT library was
 - Not wanting to learn/use someone else's code and discover its limitations a little to late into the implementation
 - Freedom to easily customize and modify my code based on my project's needs
 - I already had experience with the [Kalman Filter](https://github.com/mannyray/kalmanfilter) which is half of the SORT algorithm
 - Learn more about object detection type code
 - Create something someone else might use

If you are a reader who is looking for a SORT algorihtm, I hope you find mine useful!

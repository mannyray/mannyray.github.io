---
layout: post
title:  "Prototype"
date:   2021-03-28 21:00:00
categories: programming
---

I am very excited to show you a prototype of a project I have been working on. The project involves using an image detection cell phone application to detect "interesting events" and acting upon these events. An "interesting event" will be application specific. For example some cell phones use the [front facing camera to detect their owner's face as a way of authentication](https://www.youtube.com/watch?v=ZwCNG9KFdXs). In this example the "interesting event" is the owner's face. The action taken is unlocking the phone. 

In my application, I want the cell phone's image detection application to detect a specific object type. Upon detection, the cell phone will request a DSLR camera to take a high resolution picture of this object. This object will be around two hundred meters away: far enough that the cell phone's camera is insufficient to get a detailed view. Here is a diagram of my project:

![img]({{ site.url }}/assets/prototype/scheme.png)

In the previous diagram, additional implementation details are exposed. The Raspberry Pi, which can be replaced with some other computer, is necessary because there is no easy and direct way to send a signal from one's cellphone to a regular DSLR camera. New DSLR cameras often come with downloadable applications from the app store. However, these application are insufficient in providing detailed control over the DSLR for your custom application. The [gphoto](http://gphoto.org/) applications allows one to resolve this problem. 

gphoto allows one to send commands via USB cable from a computer to your DSLR camera. A bluetooth server was implemented and then installed on the Raspberry Pi to act as the middle man between the cell phone application and the DSLR. When the cell phone application detects the far away object, it sends a Bluetooth signal to the Raspberry Pi. Then, the Raspberry Pi sends the "take picture" command to the DSLR.

For my prototype, the far away objects will be oranges. I simulated this using a projector and a wall.

![img]({{ site.url }}/assets/prototype/IMG_6809.JPG)


![img]({{ site.url }}/assets/prototype/IMG_6808.JPG)

A script was written to simulate the oranges moving in the background. The script outputs a gif. Here is a small bit of the output:

![img]({{ site.url }}/assets/prototype/oranges.gif)


The cellphone with the detection application was placed with the oranges in view:

![img]({{ site.url }}/assets/prototype/IMG_6813.JPG)

In the above image, the cellphone application detects the oranges and displays a bounding box around each detected one. The middle yellow box acts as an aiming scope. When an orange is fully within the yellow box, the cellphone application will send the bluetooth signal for the DSLR to take the picture. The DSLR is setup so the direction it points to aligns with where the yellow box 'aim scope' is pointing to.


The application was built on top of a sample application provided by [TensorFlow](https://www.tensorflow.org/lite). My most significant upgrade for this application is adding my custom Simple Online and Realtime Tracking (SORT) algorithm described in [this paper](https://arxiv.org/abs/1602.00763). SORT allows the cellphone application to keep track of a trajectory of detected objects. The trajectory is used for identifying when a new orange has entered the yellow box.

![img]({{ site.url }}/assets/prototype/IMG_6810.JPG)

The camera is setup on a tripod with two cables sticking out. Top left one connects the DSLR to the Raspberry Pi while the bottom right connects the camera battery to an outlet. Using an outlet connected battery over a regular battery allows for you to run the camera over long periods of time.

A gif of the app running is below

![img]({{ site.url }}/assets/prototype/out.gif)


The incoming oranges are detected by the application and are bounded with a box with specified identification tag. When an orange with an id that has not yet been in the yellow box comes into the yellow box, the cellphone application sends a signal for the DSLR to take a picture. A dimming/brightening feature was added to brighten when the take picture signal is sent.

From the gif, a frame is extracted where the take picture signal was sent (based on brightness). At `2:16.440`, with the center of the orange numbered `42` directly above `:` of the `2:16`, the cellphone application sends the signal:

![img]({{ site.url }}/assets/prototype/video_capture.png)

The DSLR lags by half a second and takes the picture when the orange numbered `42` is centered above the `02`.

![img]({{ site.url }}/assets/prototype/IMG_6378.JPG)

Fine level of accuracy was not the level of focus for this prototype testing. The delay for my application is sufficient. However, limitations of the camera are important to note. For this experiment, the Canon EOS M100 was used. If lighting is poor, the DSLR will reject the "take picture" command. At times the camera will need to refocus (if on autofocus mode) which will cause a bit of lag with the "take picture" command. 

The simulation lasted a total of 2 and a half minutes with a total of 48 objects detected and matching pictures taken. Pictures took almost 500Mb of memory as a high resolution option was set for the captured images.

To apply this to something other than oranges, a new detection model must be created. This can be thought of as a new game cartridge to a game boy advance. The gaming experience (in this application) is dictated by the cartridge (in this case detection model). In addition, instead of sending a signal to a DSLR camera you can send the signal to some other device depending on what you are trying to do.

## Conclusion

I am satisfied with this prototype. It is ready for further testing. Most of the learning required for this prototype was android application development and the SORT algorithm. The code for these I will share later. The learning occupied a lot of time this past half year and I am grateful to see results. 

For amateur purposes, this prototype can most easily be setup in one's place of living as you need a secure place to leave your camera to run. This means that to take interesting pictures, you need to have an interesting view out your window. Once you have a subject area of focus and a trained image detecting model, you can apply set this prototype pretty easily. To some this prototype may seem like a fishing net in the desert - not very useful. However, if you are by the ocean then have fun!

The initial inspiration to create this prototype came from [this article](https://www.cbc.ca/news/canada/toronto/councillor-ana-bailao-vacancy-tax-jaco-joubert-condo-tower-study-1.5357198). Toronto at the time had a housing problem (probably does and will). Housing is scarce and ever increasing in price. A developer wanted to determine what percentage of condo units are unoccupied and unused in a city where people are desperate for housing. He setup a camera and started monitoring condo towers from afar so he could see which ones are occupied or not. After reading the article, I would look out my window and see what information I can observe and absorb with my camera.

The next big step for my prototype is to train a new image detecting model for what I want to observe and absorb outside my window. Will not spoil the details of what exactly here.

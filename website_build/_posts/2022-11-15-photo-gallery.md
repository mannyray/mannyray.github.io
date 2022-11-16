---
layout: post
title:  "Photo Gallery"
date:   2022-11-15 00:00:00
categories: programming
---

I have just upgraded my photo gallery on this website with my own custom code. It is now more compact, more visually appealing and more fun for me to use. Check out the gallery [here](https://szonov.com/photos/) (or navigate to it via the navigation bar at the top of the page). Here is a comparison of the before and after of the photo gallery home page:

| Original Photo Gallery Home Page             |  NEW Photo Gallery Home Page |
|:-------------------------|:-------------------------|
|![]({{ site.url }}/assets/photo_gallery_old_home.png)  |  ![]({{ site.url }}/assets/photo_gallery_new_home.png)|

Here is the comparison of the gallery page:

| Original Photo Gallery Home Page             |  NEW Photo Gallery Home Page |
|:-------------------------|:-------------------------|
|![]({{ site.url }}/assets/photo_gallery_old_gallery_page.png)  |  ![]({{ site.url }}/assets/photo_gallery_new_gallery_page.png)|


The main difference is now I am using square thumbnails for more compact design and dates to give the various picture themes a timeline. The previous gallery was based on [jekyll-photo-gallery](https://github.com/aerobless/jekyll-photo-gallery) which is a photo gallery plugin for Jekyll based sites. I was not satisfied with the gallery lay out and wanted to learn how to create my own [plugin for generating pages](https://jekyllrb.com/docs/plugins/generators/). This desire to explore generating pages was fueled by my recent discovery of vast amounts of generated sites that suck up Google search result spaces in order to suck up ad money. I was using the Google search bar as a basic division calculator (e.g. 123/11) and noticed the Google search result had a website telling me what a mixed fraction is and that the one I was searching for is one of them and oh look here is an advertisement. I am curious about mechanisms for generating such pages.


Jekyll plugin framework makes this process fairly easy. The core logic is in a single [ruby file](https://github.com/mannyray/jekyll-gallery-tags/blob/master/lib/gallery.rb) with about 100 lines of code. The trickiest part was figuring out how Jekyll structures things but once that is figured out it is all just some basic for loops. The _annoying_ part was the related UI html/css work as I am not the biggest fan of it. Fortunately, due to the way Jekyll is structured, the UI work was minimal. I have added a detailed README so you could reproduce the results yourself if you so choose.


In a gallery page, the plugin generator connects a square thumbnail to the original image. Together, all the square thumbnails create a compact design with lots of flashy thumbnails to see at once. This is similar to Instagram. I am relying on the collective knowledge of social-media-giants' brightest behavioural phycologists to create the most beautiful eye candy. The purpose of a photo gallery is not just to show beautiful pictures but to also do it in a beautiful way. With my own code and keyboard I can fine tune this beauty.

Focusing on presentation, beauty and aesthetics makes using the feature more exciting. By having a good way of presenting photos I am now excited to present even more photos. I am digging through my photos to see which additional ones I can upload. I am revisiting old memories. Furthermore, I am excited to get my camera out more often and improve my skills. There of course is the option of using a ready to go product like Instagram but where is the fun in that?

With using someone else's product, like Instagram, I am subject to how they want me to use it. I am not sure that I want to share my photos how they want to. Do I need the comments or likes? Do I need a user name? Do I need to view the commercials and algorithm curated posts? I am making this sounds more serious and spooky than it is. This isn't about being ungovernable. I am interested in creating a tool as I specify it and seeing if it improves photography for me. This is a new frontier for me. Initially computer science and programming sucked me in due to being able to automate things so I can be lazy. Oftentimes I would spend more time writing the script to automate something than if I did the task myself. There was a satisfcation in having the computer do something for me. However, now I am excited and motivated by creating tools that can simplify some processes for me.

Automating away laziness and simplifying processes sounds similar but there is a subtle difference. The former is reactionary while the latter is seeing where the newly created processes takes you next. I am not excited about the new photo gallery for automating something away but I am excited about how this will affect picture taking and sharing. In fact, with this new photo gallery I have more work to do than before as I now have to create the thumbnails.

The photo gallery is far from ideal. Creating the thumbnails is a manual process. I don't think there is a good way to automate it as only I can see the best 'square' of my picture. My current React based web browser tool is good but it can't be used on the go like some phone app. This is something I will work on next.

I have a few other projects in mind for my website. One's website is a fun and good way to motivate yourself to explore and to showcase your explorations. It is a little bit like who has the coolest lawn decorations and maybe considered a little self centered (I confess). I hope to not 'smell my own farts' too much here. My goal is to create tools and new processes and see if it helps others. The more the better.

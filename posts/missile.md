---
title: missile
date: 2018-05-27T13:01:05+02:00
---
"I was once working with a customer who was producing on-board software for a missile.  In my analysis of the code, I pointed out that they had a number of problems with storage leaks.  Imagine my surprise when the customers chief software engineer said "Of course it leaks".  He went on to point out that they had calculated the amount of memory the application would leak in the total possible flight time for the missile and then doubled that number.  They added this much additional memory to the hardware to "support" the leaks.  Since the missile will explode when it hits it's target or at the end of it's flight, the ultimate in garbage collection is performed without programmer intervention."

- Kent Mitchell
<!--more-->



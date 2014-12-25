
HuZERO *Caravan Edition* by Chris Covell
========================================

HuZERO is a futuristic racing game for the PC-Engine / Turbografx-16, which I made as a tribute to a great Mode-7 racer on the Super Famicom.  You know the one.

This version is a one-track "Summer Caravan" edition which, if you're familiar with Hudson's Caravans, gives you 2 minutes to attain a high score. And not die.

The controls are quite simple.  RUN starts and pauses the game, L/R steers, and the I button accelerates.  It's a futuristic jet-powered hovercraft levitating over a low-friction surface, and you have no brakes.  ('Cause I'm aiming for realism here...)

Try to survive 2 minutes, try to get a high score, and enjoy our little PC-Engine that could.


History
-------

I had the idea for something like this kicking around my head since 2009 or so, and I even made graphics and a map, but I got the math a little wrong.  So the idea got shelved while I did other exciting things.  Starting around February 2014, I drew up on a piece of paper the algorithms needed per-screen and per-scanline to project a "scaling" background on a single-plane tilemap video system with no Mode-7 and no math coprocessors, and coded it up.  As it turns out, doing a scaling, warping, and tilting engine like this was not so hard, and it only taxed 60% (or thereabouts) of the PCE's per-field CPU time so a full 60fps can be done in-game.

The moving, driving, scrolling, and bumping were all working within 2 weeks of starting this project, and from then to November 2014 it'd been a lot of fun just adding little things to the game, tweaking the math, logic, and making some art, etc.  I had no stress or demotivation during the entire time I was working on this (admittedly) little game, and that's the best thing a person can hope for in a hobbyist programming effort.

I have other ideas, such as making the track more elaborate (with "rotation", true corner effects, etc.) by using the SuperGrafx's dual layers...  Maybe I'll start working on that in another 5 years, who knows?

Many thanks to Arkhan at Aetherbyte for arranging the "Big Blue" song in Squirrel for me.

-----------------

Any questions, please e-mail me at chris_covell@yahoo.ca
Chris Covell, November 21, 2014
http://www.chrismcovell.com
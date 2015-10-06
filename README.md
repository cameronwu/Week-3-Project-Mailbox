Week 3 Project: Mailbox
=======================

This a prototype of Mailbox, created for CodePath's Week 3 assignment as outlined here: http://courses.codepath.com/courses/ios_for_designers/unit/3#!assignment.


Time spent: 12 hours


Completed Requirements:
-----------------------

Drag Left
- Initially, the revealed background color is gray.
- As the reschedule icon is revealed, it starts semi-transparent and becomes fully opaque. If released at this point, the message returns to its initial position.
- After 60 pts, the later icon moves with the translation and the background changes to yellow.
    - Upon release, the message reveals the yellow background. When the animation completes, it shows the reschedule options.
- After 260 pts, the icon changes to the list icon and the background color changes to brown.
    - Upon release, the message reveals the brown background. When the animation completes, it shows the list options.
- The user can tap to dismiss the reschedule or list options. After the reschedule or list options are dismissed, the message finishes its hide animation.

Drag Right
- Initially, the revealed background color is gray.
- As the archive icon is revealed, it starts semi-transparent and become fully opaque. If released at this point, the message returns to its initial position.
- After 60 pts, the archive icon starts moving with the translation and the background changes to green.
    - Upon release, the message reveals the green background. When the animation completes, it hides the message.
- After 260 pts, the icon changes to the delete icon and the background color changes to red.
    - Upon release, the message reveals the red background. When the animation completes, it hides the message.

Optionals
- Panning from the edge reveals the menu
	- If the menu is being revealed when the user lifts their finger, it continues revealing.
	- If the menu is being hidden when the user lifts their finger, it continues hiding.
- Tapping on compose reveals the compose view.
- Tapping the segmented control in the title swipes views in from the left or right.
- Shake to undo.


Bonus:
------

- Screen Edge Pan gesture ignores the message pan gesture.
- The inbox and archive views snap their scrollviews if the search field is partially open.
- The demo message can be scrolled.
	- If initiating scrolling from the demo message, it will not move left or right.
	- If dragging the demo message left or right, it will not scroll.


Walkthrough:
------------

![alt tag](https://github.com/cameronwu/Week-3-Project-Mailbox/raw/master/walkthrough.gif)

# lcCardLayoutToWeb
Design a card layout in LiveCode, then export the layout to HTML and CSS files

Project code name "parakeet"

![parakeet still 20161006](http://reactorlab.net/graphics/github_media/parakeet_20161007a.png)

This project is being built with the open-source, Community Edition of LiveCode. Get it at www.LiveCode.org.

Contributors are welcome. You need to use the LiveCode IDE in order to use this project or to contribute to development of this project. 

Each LiveCode control is referenced in CSS by id only. LiveCode controls include groups, standard buttons, menu buttons, checkboxes, radio buttons, locked fields, unlocked fields, and sliders (range inputs). 

The project is not intended to build full-featured web pages. There is no LiveCode script conversion.

My use of this project is to develop web apps that are interactive simulations of physical systems. Examples of web apps built with this project are posted at http://reactorlab.net/resources/web-app-experiments/ (Richard Herz).

HOW TO USE: 

Two stacks are used together: (1) a regular LiveCode stack "lcCardLayoutToWeb-stack.livecode" and (2) a script-only stack "lcCardLayoutToWeb-script.livecodescript"

Open stack (1) first in the LiveCode IDE. When stack (1) in the distribution is opened, its openStack command places stack (2) in use.  

Stack (2) contains all of the LiveCode script in the project. It is saved as a script-only stack to enable code comparison between branches in GitHub.

Card layouts are built in a card of stack (1). Clicking the development button with label "saveToWebPage" in stack (1) in the distribution saves the card layout to a folder with HTML and CSS files. All development controls in stack (2) are contained in one group. The user-given names of the development group and its controls contain the word "lcCardLayoutToWeb" so that they aren't exported to the HTML and CSS files.

WARNING: old web output versions are overwritten. Folders named "images" are not overwritten.

Output folder names include the user-given name of the card or, if no given name, the number of the card. 

Image files should be placed in a folder "images" in the output folder and then added to the card in stack (2) BY REFERENCE only. 

The minimum requirement for stack (1) is that it have the stack name "lcCardLayoutToWeb-stack". It may optionally have an openStack command that puts stack (2) in use. It may optionally have development controls, e.g., in a shared background group. The names of the development group(s) and control(s) must all contain the word "lcCardLayoutToWeb" among the words of their names in order for them to not be saved to HTML and CSS. One of the optional development controls could be a button that sends the command "saveToWebPage" to stack (2), which is the command that saves the card layout in stack (1) to HTML and CSS files. The copy of stack (1) in the github distribution has a field named "lcCardLayoutToWeb card name" to display the card name and a checkbox named "lcCardLayoutToWeb outlines" to specify whether or not dotted borders be added to all groups (div's) and locked fields (p's) in the web copy. Those specific names are referenced in the script of stack (2) but their existence is checked before they are accessed.

For responsive design, include controls that you want to move upon screen-size changes into groups. Make a copy of the original web output, move the groups, make new output to get the new left,top locations of the moved divs, then add an @media section to the original css file with the new div locations.

Another method is to clone the card and move the divs in the clone. However, when you clone a card, the control id numbers will differ between the clone copies. LiveCode control id's are unique within a stack. Therefore, you need to make sure the css id's in the @media section agree with the id's of those divs in the rest of the original css file.

------------
HOW TO CREATE EMPTY GROUP FOR PLOT CANVAS 

BETTER WAY: Add one button the size of the group and add the word "lcCardLayoutToWeb" to the button name, then select and group the button and name the group. *OR* define two opposing corners of what will be empty group by two buttons and add the word "lcCardLayoutToWeb" to each of their names. Then select both and group them. Then select group and name it as desired. When save to web, the button(s) will not appear in the output. 

OLD WAY & WARNING: Lock location of empty group or it will go to very small size when you stop editing. Add a button to the card, select it, group it, adjust size of group and lock the location. Then can delete the button to leave empty group.

ALSO CONSIDER adding two small buttons to fix two opposing corners of the group and leave them there so can leave group position unlocked so group doesn't collapse. Maybe name them special, e.g., use lcCardLayoutToWeb, so that they don't get translated to HTML-CSS output.

------------
MORE WARNINGS TO USER

Responsive design, @media: >> BETTER TO KEEP SAME CARD BUT RENAME IT AND HAVE FOLDERS NAMED AFTER CURRENT CARD NAME >> If clone a card in the stack to reposition controls for smaller width screens, realize that the CONTROL ID NUMBERS CHANGE and, thus, the CSS ID -#### CHANGE. So just make sure to change the -#### in the @media section to match those above and in the html. 

In order to add images to the LC card, you first have to create a parent folder for that card, then add an images folder, then put the image in the folder, then create a NEW REFERENCED CONTROL only, with reference to image file located in folder tImagesFolder = kImagesFolder. 
------------


# lcCardLayoutToWeb
Design a card layout in LiveCode, then export the layout to HTML and CSS files. 

This project is being built with the open-source, Community Edition of LiveCode. Get it at www.LiveCode.org. 

You need to use the LiveCode IDE in order to use this project or develop this project.

For the master version in the initial commit, at least, each LiveCode control is referenced in CSS by id only. LiveCode controls in initial commit include groups, standard buttons, menu buttons, checkboxes, radio buttons, locked fields, unlocked fields, and sliders (range inputs). 

There is no LiveCode script conversion in the master version in the initial commit, at least.

HOW TO USE: 

Two stacks are used together: (1) a script-only stack "lcCardLayoutToWeb-script.livecodescript" and (2) a regular LiveCode stack "lcCardLayoutToWeb-stack.livecode"

Open stack (1) first in the LiveCode IDE. Then open stack (2). When stack (2) is opened, its openStack command places stack (1) in use.  

Stack (1) contains all of the LiveCode script in the project. It is saved as a script-only stack to enable code comparison between branches in GitHub.

Card layouts are built in a card of stack (2). Clicking the development button "lcCardLayoutToWeb" in stack (2) saves the card layout to a folder with HTML and CSS files. All development controls in stack (2) are contained in one group. The user-given names of the development group and its controls contain the word "lcCardLayoutToWeb" so that they aren't exported to the HTML and CSS files.

WARNING: old web output versions are overwritten. Folders named "images" are not overwritten.

Output folder names include the user-given name of the card or, if no given name, the number of the card. 

Image files should be placed in the output folder in a folder "images" and then added to the card in stack (2) BY REFERENCE only. 

For responsive design, include controls that you want to move upon screen-size changes into groups. Make a copy of the original web output, move the groups, make new output to get the new left,top locations of the moved divs, then add an @media section to the original css file with the new div locations.

Another method is to clone the card and move the divs in the clone. However, when you clone a card, the control id numbers will differ between the clone copies. LiveCode control id's are unique within a stack. Therefore, you need to make sure the css id's in the @media section agree with the id's of those divs in the rest of the original css file.


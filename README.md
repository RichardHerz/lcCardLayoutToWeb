# lcCardLayoutToWeb
Design a card layout in LiveCode, then export the layout to HTML and CSS files. 

For initial commit, each LiveCode (LC) control is referenced in CSS by id only. LC controls in initial commit include groups, standard buttons, menu buttons, checkboxes, radio buttons, locked fields, unlocked fields, and sliders (range inputs). 

No LiveCode script conversion.

How to use: 

Two stacks are used together: (1) a regular LiveCode stack "lcCardLayoutToWeb-stack.livecode" and (2) a script-only stack "lcCardLayoutToWeb-script.livecodescript" 

When stack (1) is opened, its openStack command places stack (2) in use. Stack (2) contains all of the LiveCode script in the project. 

Card layouts are built in a card of stack (1). Clicking the button "lcCardLayoutToWeb" in stack (1) saves the card layout to a folder with HTML and CSS files. 

WARNING: old versions are overwritten. Folders named "images" is not overwritten.

Output folder names include the user-given name of the card or, if no given name, the number of the card. 

Image files should be placed in the output folder in a folder "images" and then added to the card in stack (1) BY REFERENCE only. 

If you clone a card, then the control id numbers will differ between the clone copies. The control id's are unique within a stack. 

For responsive design, include controls that you want to move upon screen-size changes into groups. Make a copy of the original web output, move the groups, make new output to get the new left,top locations of the moved divs, then add an @media section to the original css file with the new div locations.

Another way is to clone the card and move the divs in the clone. However, when you clone a card, the control id numbers will differ between the clone copies. The LiveCode control id's are unique within a stack. Therefore, you need to make sure the css id's in the @media section agree with the id's of those divs in the rest of the original css file.


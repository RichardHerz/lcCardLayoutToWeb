# lcCardLayoutToWeb
Design a card layout in LiveCode, then export the layout to HTML and CSS files. Drag and drop web page design!

The project is "reversible" - an exported web page, which has changes such as addition of file and event function references, can be imported back into to the project, edited (controls moved, added and deleted), and then exported back to a revised web page with the file and event references preserved.

![parakeet still 20161006](http://reactorlab.net/graphics/github_media/parakeet_20161007a.png)

This project is being built with the open-source, Community Edition of LiveCode. Get it at www.LiveCode.org. You need to use the LiveCode IDE, version 8 or higher, in order to use this project.

The project is not intended to build full-featured web pages. There is no LiveCode script conversion.

My use of this project is to develop web apps that are interactive simulations of physical systems. Examples of web apps built with this project are posted at http://reactorlab.net/resources/web-app-experiments/ 

Each LiveCode control is referenced in CSS by id only, thus cascading is limited. LiveCode controls supported include groups, standard buttons, menu buttons, checkboxes, radio buttons, locked fields, unlocked fields, and scrollbars (as range inputs). See the project wiki for other limitations.

The files css-processor-stack.livecode and css-processor-script.livecodescript can be used to process CSS files in order to scale a card layout to other widths and (in the future) other heights.

SEE THIS PROJECT'S WIKI IN THE TAB ABOVE FOR MORE INFO. 

CONTACT INFO FOR Richard Herz IS AT www.ReactorLab.net ( Richard K. Herz ) 

# lcCardLayoutToWeb
Design a card layout in LiveCode, then export the layout to HTML and CSS files. Project code name "parakeet"

Import of exported files with preservation of added file references and events, revision of layout, and re-export are supported.

_**New**_ - The project now is "reversible" in that exported files can be modified to add Javascript and CSS file references in the html header and function calls in HTML events, and then imported back into the project with the file references and function calls preserved. Thus, a card/page layout which has had file and function references added can imported and edited (controls moved, added and deleted), and then exported back to a revised web page.

![parakeet still 20161006](http://reactorlab.net/graphics/github_media/parakeet_20161007a.png)

This project is being built with the open-source, Community Edition of LiveCode. Get it at www.LiveCode.org.

Contributors are welcome. You need to use the LiveCode IDE, version 8 or higher, in order to use this software. See this project's WIKI in the tab above for help.

Each LiveCode control is referenced in CSS by id only, thus cascading is limited. LiveCode controls include groups, standard buttons, menu buttons, checkboxes, radio buttons, locked fields, unlocked fields, and sliders (range inputs). 

The project is not intended to build full-featured web pages. There is no LiveCode script conversion.

My use of this project is to develop web apps that are interactive simulations of physical systems. Examples of web apps built with this project are posted at http://reactorlab.net/resources/web-app-experiments/ (Richard Herz).

SEE THIS PROJECT'S WIKI IN THE TAB ABOVE FOR MORE INFO. 

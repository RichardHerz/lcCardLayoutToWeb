script "lcCardLayoutToWeb-script"
/*
Design, text, images and code by Richard K. Herz, 2017
Copyrights held by Richard K. Herz
Licensed for use under the GNU General Public License v3.0
https://www.gnu.org/licenses/gpl-3.0.en.html
*/

/* 
WARNING - output files for same LiveCard card will be written over each time saveToWebPage runs, 
so save copies of the output files you want to keep

WARNING - use LF line endings when constructing text and write to file with file opened for binary write,
so that you can view source in all browsers with lines broken at line endings
*/

/*
WARNING - RESPONSIVE DESIGN
BETTER TO KEEP SAME CARD BUT RENAME IT AND HAVE FOLDERS NAMED AFTER CURRENT CARD NAME 
>> If clone a card in the stack to reposition controls for smaller width screens, realize that 
the CONTROL ID NUMBERS CHANGE and, thus, the CSS ID -#### CHANGE. So just make sure to change
the -#### in the @media section to match those above and in the html. 

For responsive web page, to rearrange some groups/divisions for smaller screens, add an example like this 
to bottom of CSS, making sure ID numbers _#### match original elements above
(and found max-width: didn't work with this script):

@media (orientation: portrait) {
#div_simulation_3_frame_1154 {
width: 620px;
height: 940px;
}

I ADDED LIGHT BLUE VERTICAL LINE TO PAGE AT 640px AS MOBILE LAYOUT GUIDE
*/

/* 
HOW TO CREATE EMPTY GROUP FOR A PLOT CANVAS 

BEST WAY: Add one button the size of the group and add the word "lcCardLayoutToWeb" to the button name, 
then select and group the button and name the group. When saved to web, the button will not appear in the output. 

ALTERNATIVE is to add two small buttons to fix two opposing corners of the group. 
Add the word "lcCardLayoutToWeb" to the button names.When saved to web, the buttons will not appear in the output. 

OLD WAY & WARNING: Lock location of EMPTY group or it will go to very small size when you stop editing. 
Empty group made by adding a button to the card, select it, group it, adjust size of group and lock the location. 
Then can delete the button to leave empty group.
*/

-----------------------------------------------

on openCard
   if the short name of the topStack is "lcCardLayoutToWeb-stack" then
      if there is a field "lcCardLayoutToWeb card name" then
         put the name of the current card into tName
         if tName contains "card id" & space then
            put "card" && the number of the current card into tName
         end if
         replace quote with empty in tName
         put tName into field "lcCardLayoutToWeb card name"
      end if
   end if
   pass openCard
end openCard

-----------------------------------------------

on saveToWebPage
   
   -- WARNING - output files for same LiveCard card will be written over
   -- each time this runs, so save ones you want to keep
   
   set the defaultStack to "lcCardLayoutToWeb-stack"
   
   ---------- START INPUT DATA ------------
   
   -- Writes to files in output folder kWebOutputFolder & "card" & LC stack card number
   constant kWebOutputFolder = "web output"
   -- images should be added to LiveCode stack only BY REFERENCE
   --      to image file which should be located in images folder kImagesFolder
   --      and not imported into LC stack
   constant kImagesFolder = "images"
   constant kCssFolder = "css"
   constant kJavascriptFolder = "js"
   constant kHtmlFileName = "index.html"
   constant kCssFileName = "index.css"
   -- set number of spaces to indent
   --      used to increase and decrease indents
   --      not only makes html look nice but text editors use indents to fold/unfold sections
   constant kIndentSpaces = 3
   
   -- SET ARRAY WITH CONVERSION BETWEEN LIVECODE AND CSS PROPERTIES
   -- keys of array aCSSprops are LiveCode properties
   -- values are equivalent CSS properties
   -- put value into aCSSprops["key"]
   -- SOME DEACTIVATED BY COMMENT BELOW
   put empty into aCSSprops
   -- use LC blendLevel instead of LC opaque
   -- put "opacity" into aCSSprops["opaque"] -- LC true or false; CSS 1 or 0
   put "opacity" into aCSSprops["blendLevel"] -- LC 100 > 0 (0 is opaque); CSS 0 > 1 (1 is opaque)
   put "visibility" into aCSSprops["visible"] -- LC true-false; CSS visible-hidden
   -- development button "outlines" overrides border-style
   put "border-style" into aCSSprops["showBorder"]
   -- LC true-false; CSS none, hidden, dotted, dashed, solid, double, groove, ridge, inset, outset
   -- as of now, only one CSS style picked in fReturnCSSprops
   put "border-width" into aCSSprops["borderWidth"]
   -- LC is pixel value; CSS thin, medium, thick or px
   -- stop using margin, interferes with location of some controls
   -- put "margin" into aCSSprops["margins"] -- LC is pixel value; CSS px
   put "background-color" into aCSSprops["backColor"]
   -- LC RGB values; CSS Valid color names, rgb(#,#,#), hexidecimal notation
   
   ---------- END INPUT DATA ------------
   
   -- Controls with short name containing "lcCardLayoutToWeb"
   --      will NOT be saved to web page, since
   --      that name is reserved for development controls
   
   -- uses function fExportGroup
   -- uses function fExportImage
   -- uses function fExportStandardButton
   -- uses function fExportRadioButton
   -- uses function fExportCheckBox
   -- uses function fExportMenuButton
   -- uses function fExportField
   -- uses function fExportScrollBar
   -- uses function fIDname
   -- uses function fReturnCSSprops
   
   -- indents not only makes html look nice but text editors use indents to fold/unfold sections
   repeat kIndentSpaces times
      put space after tOneIndent
   end repeat
   put empty into tIndent -- indent for HTML
   put empty into tCSS -- holds CSS being built up
   put empty into tHTML -- holds HTML being built up
   
   -- create output folders
   put the long name of this stack into tStack
   replace quote with empty in tStack
   delete the first word of tStack
   set the itemDelimiter to "/"
   delete the last item of tStack
   put the number of the current card into tCardNum
   if there is a field "lcCardLayoutToWeb card name" then
      put field "lcCardLayoutToWeb card name" into tName
   else
      put "card" && tCardNum into tName
   end if
   put kWebOutputFolder & space & tName into tOutputFolderName
   put tStack & "/" & tOutputFolderName into tOutputFolderPath -- also used at end this handler
   if there is a folder tOutputFolderPath then
      -- do nothing
   else
      create folder tOutputFolderPath
   end if
   -- create folder for css
   put tOutputFolderPath & "/" & kCssFolder into tCssFolderPath
   if there is a folder tCssFolderPath then
      -- do nothing
   else
      create folder tCssFolderPath
   end if
   -- tCssFolder worked when this script in design stack but change to tCssFolderPath when
   -- in script-only stack in use by design stack
   -- put tCssFolder & "/" & kCssFileName into tCssFilePath -- also used at end this handler
   put tCssFolderPath & "/" & kCssFileName into tCssFilePath -- also used at end this handler
   -- xxx probably don't want to make js folder unless put some stuff there...
   --    -- create folder for javascript
   --    put tOutputFolderPath & "/" & kJavascriptFolder into tJavascriptFolderPath
   --    if there is a folder tJavascriptFolderPath then
   --       -- do nothing
   --    else
   --       create folder tJavascriptFolderPath
   --    end if
   -- create folder for images
   put tOutputFolderPath & "/" & kImagesFolder into tImagesFolderPath
   if there is a folder tImagesFolderPath then
      -- do nothing
   else
      create folder tImagesFolderPath
   end if
   
   -- reset the itemDelimiter to default, which is comma
   set the itemDelimiter to comma
   
   -- start building the html
   put "<!doctype html>" & LF & "<html>" & LF & "<head>" & LF after tHTML
   put "<!-- load style sheets for this lab  -->" & LF after tHTML
   put "<link rel=" & quote & "stylesheet" & quote && "href=" & quote & tCssFilePath & quote & ">" & LF after tHTML
   -- need to add links for javascript files
   put "</head>" & LF & "<body>" & LF after tHTML
   
   -- start building the css
   -- input
   put "input {" & LF after tCSS
   put space & "display: block;" & LF after tCSS
   put space &  "position: absolute;" & LF after tCSS
   put space &  "text-align: left;" & LF after tCSS
   put "}" & LF & LF after tCSS -- finish css for input
   -- override "text-align: left;" for input type="button"
   put "input, button {" & LF after tCSS
   put space &  "text-align: center;" & LF after tCSS
   put "}" & LF & LF after tCSS -- finish css for input, button
   -- WARNING: write notice NOT to make general div style since
   -- interferes with plotting by flot.js
   put "/* do NOT write general style for div since interferes" & LF  after tCSS
   put "    with plotting by jquery.flot.js */" & LF & LF after tCSS
   -- for UNlocked INPUT field, html already adds outline
   -- locked field = <p>
   -- do NOT put position: absolute here because bad for other text added later to HTML
   -- need position: absolute only for fields laid out by LC
   put "p {" & LF after tCSS
   put space & "display: block;" & LF after tCSS
   put space &  "text-align: left;" & LF after tCSS
   if there is a button "lcCardLayoutToWeb outlines" then
      if the hilite of button "lcCardLayoutToWeb outlines" is true then
         put space & "border-style: dotted;" & LF after tCSS
      end if
   end if
   put "}" & LF & LF after tCSS -- finish css for p, locked field
   -- label
   put "label {" & LF after tCSS
   put space & "display: block;" & LF after tCSS
   put space &  "position: absolute;" & LF after tCSS
   put "}" & LF & LF after tCSS -- finish css for label
   -- img
   put "img {" & LF after tCSS
   put space & "display: block;" & LF after tCSS
   put space &  "position: absolute;" & LF after tCSS
   put "}" & LF & LF after tCSS -- finish css for img
   -- select (menu buttons)
   put "select {" & LF after tCSS
   put space & "display: block;" & LF after tCSS
   put space &  "position: absolute;" & LF after tCSS
   put "}" & LF & LF after tCSS -- finish css for select
   
   -- When you repeat down the list of control numbers
   -- LiveCode groups them together in the LC groups
   -- in which they appear, no matter in what time order they were added to card.
   -- So LiveCode does a lot of the work.
   -- Have do some work ourselves to find when a group ends,
   -- which is when reference to current group does not appear in next control
   
   -- For css position: absolute; you need top and left to be relative to the parent group.
   -- The top and left of a nested group needs to be relative to its parent group, and
   -- the contents of the nested group need to be relative to the nested group.
   
   -- tGrpList is list of active groups
   put empty into tGrpList
   -- tGrpLocList is list of left,top coordinates of active groups
   put empty into tGrpLocList
   
   repeat with tControlNumber = 1 to the number of controls
      
      if the short name of control tControlNumber contains "lcCardLayoutToWeb" then
         -- skip these development controls
         next repeat
      end if
      
      put the id of control tControlNumber into tControl_ID
      put the long name of control tControlNumber into tControlLongName
      -- warning: need id of control as main identifier because long name of control with a given
      -- name does not include the id and so could have confusion with two similar
      -- controls with same given name, e.g., Field, since they
      -- have the same long name and only the first long name would return correct ID for css ID's
      
      put word 1 of tControlLongName into tType
      
      -- lists of current groups and locations are in variables
      -- tGrpList and tGrpLocList, which are added to in
      -- function fExportGroup
      
      -- when a group terminates, its group name in the
      -- last line of tGrpList will disappear from next control's long name
      -- when that happens, write </div> and delete last line from tGrpList
      -- groups can be nested, so repeat checking if have reached end of a
      -- group because other groups might end there
      
      -- warning: do not have two nested groups with same short name
      
      put true into tFlagEndGrp
      repeat while tFlagEndGrp is true
         
         -- at start of each repeat, assume have NOT reached end of group
         -- if find below that have reached end of group, then flag set to true
         -- so repeat will check for end of another group at same place
         put false into tFlagEndGrp
         
         if tGrpList is empty then
            put empty into tGrpCurrent
         else
            -- these "current" variables are used below in functions for group, button, field, etc.s
            put the last line of tGrpList into tGrpCurrent
         end if
         
         if tGrpList is not empty and tGrpCurrent is not in tControlLongName then
            -- have reached end of a group
            put true into tFlagEndGrp
            -- reached end of most recent group
            -- decrease indent
            repeat kIndentSpaces times
               delete the last char of tIndent
            end repeat
            -- delete previous group from group list
            delete the last line of tGrpList
            delete the last line of tGrpLocList
            -- add end tag </div> with comment using id of the div
            put tGrpCurrent into ttemp
            delete word 1 of ttemp -- delete "of" in "of group..."
            put the long name of ttemp into ttemp
            put the id of ttemp into ttempID
            get fIDname(ttempID)
            put tIndent & "</div>" && "<!-- end of div" & space & it & "-->" & LF into tNewLine
            put tNewLine after tHTML
            
         end if -- end of: if tGrpList is not empty and tGrpCurrent is not in tControlLongName then
         
      end repeat -- end of: repeat while tFlagEndGrp is true
      
      -- now handle the element in this new line
      
      if tType = "group" then
         -- do nothing here
      else
         if tGrpList is empty then
            -- need to clear temp variables set above
            put empty into tGrp
            put empty into tGrpLoc
         else
            put the last line of tGrpList into tGrp
            put the last line of tGrpLocList into tGrpLoc
         end if
      end if
      
      switch tType
         case "group"
            -- start of a group
           get fExportGroup(tControl_ID, tGrpList, tGrpLocList, tOneIndent, tIndent, aCSSprops)
            put it into tResult
            -- also get other items modified by fExportGroup
            put tResult["tGrpList"] into tGrpList
            put tResult["tGrpLocList"] into tGrpLocList
            put tResult["tIndent"] into tIndent
            -- put the group result after tHTML and tCSS
            put tResult["html"] after tHTML
            put tResult["css"] after tCSS
            break
         case "button"
            -- there are different styles of buttons
            put the style of control tControlNumber into tStyle
            -- get the html for this style of button
            switch tStyle
               case "standard"
                 get fExportStandardButton(tControl_ID, tGrp, tGrpLoc, tIndent, aCSSprops)
                  break
               case "radiobutton"
                 get fExportRadioButton(tControl_ID, tGrp, tGrpLoc, tIndent)
                  break
               case "checkbox"
                  get fExportCheckBox(tControl_ID, tGrp, tGrpLoc, tIndent)
                  break
               case "menu"
                 get fExportMenuButton(tControl_ID, tGrp, tGrpLoc, tIndent, aCSSprops)
                  break
               default
                 get fExportStandardButton(tControl_ID, tGrp, tGrpLoc, tIndent, aCSSprops)
            end switch
            -- put the button result after tHTML and tCSS
            put it into tResult
            put tResult["html"] after tHTML
            put tResult["css"] after tCSS
            break
         case "field"
           get fExportField(tControl_ID, tGrp, tGrpLoc,tIndent)
            -- put the field result after tHTML and tCSS
            put it into tResult
            put tResult["html"] after tHTML
            put tResult["css"] after tCSS
            break
         case "image"
           get fExportImage(tControl_ID, tGrp, tGrpLoc, tIndent, kImagesFolder, aCSSprops)
            -- put the field result after tHTML and tCSS
            put it into tResult
            put tResult["html"] after tHTML
            put tResult["css"] after tCSS
            break
         case "scrollbar"
           get fExportScrollBar(tControl_ID, tGrp, tGrpLoc, tIndent, kImagesFolder)
            -- put the field result after tHTML and tCSS
            put it into tResult
            put tResult["html"] after tHTML
            put tResult["css"] after tCSS
            break
         default
            answer "unknown control, id, long name = " & LF & tControl_ID & LF & the long name of control tControlNumber
            put "*********UNKNOWN CONTROL**" && "LC id =" && the long name of control tControlNumber & LF after tHTML
      end switch
   end repeat
   
   -- at the end of all controls
   -- BUT, if there are lines in tGrpList, then that means
   -- you need to end divs with </div> for each line
   -- BE CAREFUL, if last LC controls are groups, and they at end of first group, then
   -- they will be listed in tGrpList after the first group,
   -- so be careful comments at end divs don't get reversed, check last to first
   put the number of lines of tGrpList into tLines
   repeat with k = tLines down to 1 -- check last to first
      -- decrease indent
      repeat kIndentSpaces times
         delete the last char of tIndent
      end repeat
      -- add end tag </div> with comment using id of the div
      put line k of tGrpList into ttemp
      delete word 1 of ttemp
      put the long name of ttemp into ttemp
      put the id of ttemp into ttempID
      get fIDname(ttempID)
      put tIndent & "</div>" && "<!-- end of div" & space & it & "-->" & LF into tNewLine
      put tNewLine after tHTML
   end repeat
   
   -- at end so no need to empty group lists but do so in case add stuff later
   put empty into tGrpList
   put empty into tGrpLocList
   
   -- finish building the html
   put "</body>" & LF & "</html>" & LF after tHTML
   
   -- WARNING: write output to files with BINARY WRITE and use all LF in CSS & HTML construction above
   -- ALL TESTED BROWSERS SHOW SOURCE OK WITH ALL line feed LF line endings
   -- when developing on a Mac, the following options for "open for write" do different things
   --      open for "write" with no option on Mac writes CR & LF line endings as CR, carraige returns
   --      open for "text write" on Mac writes CR & LF line endings as CR, carraige returns
   --      open for "binary write" on Mac writes CR & LF line endings as LF, line feeds
   -- viewing html source in browser with line endings as CR carriage returns
   -- shows lines broken OK in Mac Safari and Firefox, but NOT Mac Chrome (lines run together), 
   -- source lines all broken OK on Win 7 IE Explorer, Chrome and Firefox
   -- all tested browsers work OK with line feed endings
   --
   -- write html text with binary write
   put tOutputFolderPath & "/index.html" into tHtmlFilePath
   open file tHtmlFilePath for binary write
   write tHTML to file tHtmlFilePath
   close file tHtmlFilePath
   -- write css text with binary write
   open file tCssFilePath for binary write
   write tCSS to file tCssFilePath
   close file tCssFilePath
   
end saveToWebPage

-----------------------------------------------

function fReturnCSSprops tControl_ID, tGrpLoc, tGrpLocList, aCSSprops
   -- groups and some controls use this, other controls are special
   put empty into tCSS -- tCSS is local to this function, build it up, then return it
   put the rect of control id tControl_ID into tRect
   put item 1 of tRect into tLeft
   put item 2 of tRect into tTop
   if word 1 of the long name of control id tControl_ID is "group" then
      -- answer "group, tGrpLocList = " & word 1 of the long name of control id tControl_ID & LF & the short name of control id tControl_ID & LF& tGrpLocList -- xxx
      -- handle group position
      if tGrpLocList is not empty then
         put the last line of tGrpLocList into tGrpLocCurrent
         subtract item 1 of tGrpLocCurrent from tLeft
         subtract item 2 of tGrpLocCurrent from tTop
      end if
   else
      -- not a group, handle position
      -- answer "NOT group, tGrpLoc = " & word 1 of the long name of control id tControl_ID & LF & the short name of control id tControl_ID & LF& tGrpLoc -- xxx
      if tGrpLoc is empty then
         -- element not in a group
         -- position is relative to left, top of page
      else
         -- element is in a group
         -- position it relative to the group, not
         -- LiveCode's position relative to card
         subtract item 1 of tGrpLoc from tLeft
         subtract item 2 of tGrpLoc from tTop
      end if
   end if
   put space & "left:" && tLeft & "px;" & LF after tCSS
   put space & "top:" && tTop & "px;" & LF after tCSS
   put the width of control id tControl_ID into tWd
   put the height of control id tControl_ID into tHt
   put space & "width:" && tWd & "px;" & LF after tCSS
   put space & "height:" && tHt & "px;" & LF after tCSS
   put the keys of aCSSprops into tHitList
   put the properties of control id tControl_ID into aControlProps
   put the keys of aControlProps into tKeyList
   repeat for each line tKey in tKeyList
      if tKey is among the lines of tHitList then
         if aControlProps[tKey] is not empty then
            -- get CSS value from LC value in aControlProps[tKey]
            -- probably could set up this value correspondence in
            -- array(s) but use switch for now
            -- WARNING: some properties listed below have been deactivated
            -- by comments at top of script at specification of aCSSprops array
            switch tKey
               case "opaque"
                  -- LC true or false; CSS 1 or 0
                  if aControlProps[tKey] is "true" then
                     put 1 into tValue
                  else
                     put 0 into tValue
                  end if
                  break
               case "blendLevel"
                  -- LC 100 > 0 (0 is opaque); CSS 0 > 1 (1 is opaque)
                  put aControlProps[tKey] into ttemp
                  put 1 - ttemp/100 into tValue
                  break
               case "visible"
                  -- LC true-false; CSS visible-hidden
                  if aControlProps[tKey] is "true" then
                     put "visible" into tValue
                  else
                     put "hidden" into tValue
                  end if
                  break
               case "showBorder"
                  -- LC true-false; CSS none, hidden, dotted, dashed, solid, double, groove, ridge, inset, outset
                  if aControlProps[tKey] is "true" then
                     put "outset" into tValue
                  else
                     put "none" into tValue
                  end if
                  -- let development button override for groups and fields only
                  if there is a button "lcCardLayoutToWeb outlines" then
                     if the hilite of button "lcCardLayoutToWeb outlines" is true then
                        put word 1 of the long name of control id tControl_ID into tType
                        if tType is "group" or tType is "field" then
                           put "dotted" into tValue
                        end if
                     end if
                  end if
                  break
               case "borderWidth"
                  -- LC is pixel value; CSS thin, medium, thick or px
                  put aControlProps[tKey] & "px" into tValue
                  -- modify for menu buttons only
                  -- if set standard buttons to 1px then they become rectanges
                  if word 1 of the long name of control id tControl_ID is "button" then
                     -- not all control types have style property so check for button first
                     if the style of control id tControl_ID is "menu" then
                        put "1px" into tValue
                     end if
                  end if
                  break
               case "margins"
                  -- LC is pixel value; CSS px
                  put aControlProps[tKey] & "px" into tValue
                  break
               case "backColor"
                  -- LC RGB values; CSS Valid color names, rgb(#,#,#), hexidecimal notation
                  put "rgb(" & aControlProps[tKey] & ")" into tValue
                  break
               default
                  put empty into tValue
            end switch
            put space & aCSSprops[tKey] & ":" && tValue & ";" & LF after tCSS
         end if
      end if
   end repeat
   return tCSS
end fReturnCSSprops

-----------------------------------------------

function fIDname tControl_ID
   -- warning: long name of controls with user-given names do not include the LC control id number
   --   which is why input here is LC control id = tControl_ID and get long names from that
   -- CSS ID of a control is to be unique on a page
   --    this happens automatically when control has no name and here use LC control id number of control
   --    but for controls with names ALSO add here LC id number of control
   -- returns, e.g., button_2222 or button_Run_2222
   --    with spaces and "." in control names replaced by "_"
   --    with quotes in control names replaced by empty
   put word 1 of the long name of control id tControl_ID into t1 -- control type: group, field, button, etc.
   switch t1
      case "group"
         put "div" into t1
         break
      case "field"
         if the lockText of control id tControl_ID is false then
            put "input_" before t1
         end if
         break
      case "scrollbar"
         put the style of control id tControl_ID into tStyle
         -- LiveCode styles: progress, scale, scrollbar
         switch tStyle
            case "progress"
               put tStyle into t1
               break
            case "scale"
               -- range is html type for LC scale
               put "range" into t1
               break
            case "scrollbar"
               put tStyle into t1
         end switch
         break
      case "button"
         put the style of control id tControl_ID into tStyle
         switch tStyle
            case "standard"
               put "button" into t1
               break
            case "radiobutton"
               put "radio" into t1
               break
            case "checkbox"
               put tStyle into t1
               break
            case "menu"
               put "select" into t1
               break
            default
               put "button" into t1
         end switch
   end switch
   put word 2 of the long name of control id tControl_ID into t2
   if t2 is "id" then
      -- no name assigned by user, use LC control id
      -- reference in long names will be, e.g., field id 3333
      put word 1 to 3 of the long name of control id tControl_ID into t3
      delete word 2 of t3 -- delete "id"
      replace space with "_" in t3
      put t3 into tResult
   else
      -- element has a name assigned by user
      delete char 1 of t2
      delete the last char of t2
      replace space with "_" in t2
      replace quote with empty in t2
      replace "." with "_" in t2
      put t1 & "_" & t2 & "_" & tControl_ID into tResult
   end if
   return tResult
end fIDname

-----------------------------------------------

function fExportImage tControl_ID, tGrp, tGrpLoc, tIndent, tImagesFolder, aCSSprops
   -- uses function fReturnCSSprops
   -- uses function fIDname
   -- images should be added to LiveCode stack as a NEW REFERENCED CONTROL only
   -- with reference to image file located in folder tImagesFolder = kImagesFolder
   put tIndent & "<img" after tHTML
   put fIDname(tControl_ID) into tIDname
   put space & "id=" & quote & tIDname & quote after tHTML
   put space & "src=" & quote & tImagesFolder & "/" & the short name of control id tControl_ID & quote & ">" & LF after tHTML
   -- end of html
    -- write css
   put "#" & fIDname(tControl_ID) && "{" & LF into tCSS
   put empty into tGrpLocList -- used in fReturnCSSprops for groups, this copy local to this function
   put fReturnCSSprops(tControl_ID, tGrpLoc, tGrpLocList, aCSSprops) after tCSS
   -- conclude css
   put "}" & LF & LF after tCSS
   -- end of css
   -- finally return the result
   put tHTML into tResult["html"]
   put tCSS into tResult["css"]
   return tResult
end fExportImage

-----------------------------------------------

function fExportScrollBar tControl_ID, tGrp, tGrpLoc, tIndent
   -- uses function fIDname
   put the style of control id tControl_ID into tStyle
   -- LiveCode styles of scrollbars are: progress, scale, scrollbar
   -- xxx for now write all as html type range = LC scale (slider)
   switch tStyle
      case "progress"
         put "range" into tType
         break
      case "scale"
         -- range is html type for LC scale (slider)
         put "range" into tType
         break
      case "scrollbar"
         put "range" into tType
   end switch
   put tIndent & "<input type=" & quote & tType & quote into tHTML
   put fIDname(tControl_ID) into tIDname
   put space & "id=" & quote & tIDname & quote after tHTML
   put the startValue of control id tControl_ID into tStartValue
   put the endValue of control id tControl_ID into tEndValue
   put the thumbPosition of control id tControl_ID into tThumbPosition
   put the style of control id tControl_ID into tStyle
   put the pageInc of control id tControl_ID into tStep
   put space & "min=" & quote & tStartValue & quote after tHTML
   put space & "max=" & quote & tEndValue & quote after tHTML
   put space & "step=" & quote & tStep & quote after tHTML
   put space & "value=" & quote & tThumbPosition & quote after tHTML
   put ">" & LF after tHTML
   put tIndent & "</input>" & LF after tHTML
   -- end html
   -- write css
   -- THIS IS SPECIAL and does NOT use fReturnCSSprops
   put "#" & fIDname(tControl_ID) && "{" & LF into tCSS
   put the rect of control id tControl_ID into tRect
   put item 1 of tRect into tLeft
   put item 2 of tRect into tTop
   if  tGrpLoc is empty then
      -- element not in a group
      -- position is relative to left, top of page
   else
      -- element is in a group
      -- position it relative to the group, not
      -- LiveCode's position relative to card
      subtract item 1 of tGrpLoc from tLeft
      subtract item 2 of tGrpLoc from tTop
   end if
   put the width of control id tControl_ID into tWd
   put the height of control id tControl_ID into tHt
   if tHt > tWd then
      -- vertical scrollbar when height > width
      -- default in html and css is horizontal, so need to do something special to get vertical
      -- xxx need to test on various browsers: rotate appears to work on Mac Safari, Mac Firefox, Mac Chrome
      -- xxx rotate appears to work in Google browser on Andoid phone
      -- xxx there are a variety of techniques
      -- xxx see http://stackoverflow.com/questions/15935837/how-to-display-a-range-input-slider-vertically
      -- xxx also see http://www.useragentman.com/blog/csssandpaper-a-css3-javascript-library/
      -- HERE USE CSS ROTATE, need to swap height and width from LC, i.e.,
      -- make horizontal, then rotate (270deg to get higher values at top)
      -- save both old values for modify positioning below
      put tWd into tOldWd
      put tHt into tOldHt
      put tOldWd into tHt
      put tOldHt into tWd
      put space & "transform: rotate(270deg);" & LF after tCSS
      -- now need to modify positioning left and top
      -- as if you rotate original vertical about roughly its
      -- center to horizontal, make those left, top the new left, top
      -- then rotate the new back to vertical
      subtract tOldHt/2 from tLeft
      add tOldWd/4 to tLeft
      add tOldHt/2 to tTop
      subtract tOldWd/2 from tTop
   end if
   put space & "left:" && tLeft & "px;" & LF after tCSS
   put space & "top:" && tTop & "px;" & LF after tCSS
   put space & "width:" && tWd & "px;" & LF after tCSS
   put space & "height:" && tHt & "px;" & LF after tCSS
   -- conclude css
   put "}" & LF & LF after tCSS
   -- end of css
   -- finally return the result
   put tHTML into tResult["html"]
   put tCSS into tResult["css"]
   return tResult
end fExportScrollBar

-----------------------------------------------

function fExportGroup tControl_ID, tGrpList, tGrpLocList, tOneIndent, tIndent, aCSSprops
   -- uses function fReturnCSSprops
   -- uses function fIDname
   -- these inputs are not modified: tControl_ID, tOneIndent
   -- these inputs are modified and returned in result along with HTML & CSS
   --      tGrpList,tGrpLocList,tIndent
   -- add div tag - groups in LC are divisions in HTML
   put tIndent & "<div" after tHTML
   put fIDname(tControl_ID) into tIDname
   put space & "id=" & quote & tIDname & quote after tHTML
   put ">" & LF after tHTML
   -- end of html
   -- write css
   put "#" & fIDname(tControl_ID) && "{" & LF after tCSS
   -- WARNING: need to write display and position here for each separate div
   -- because doing so for all div interferes with plotting with jquery.flot.js
   put space & "display: block;" & LF after tCSS
   put space &  "position: absolute;" & LF after tCSS
   put empty into tGrpLoc -- used in fReturnCSSprops for non group controls, this copy local to this function
   put fReturnCSSprops(tControl_ID, tGrpLoc, tGrpLocList, aCSSprops) after tCSS
   -- conclude css
   put "}" & LF & LF after tCSS
   -- end of css
   -- now add to list of group names to handle nested groups
   -- WARNING - do not use fIDname - MUST use format of LiveCode long names
   put word 2 of the long name of control id tControl_ID into t2
   if t2 is "id" then
      -- no given name, just id number
      put word 3 of the long name of control id tControl_ID into t3
      -- reference in long names will be, e.g., of group id 3333
      put "of group" && t2 && t3 into tGrpRef
      put tGrpRef & LF after tGrpList -- record start of group
   else
      -- group has given name
      put "of group" && t2 into tGrpRef
      put tGrpRef & LF after tGrpList -- record start of group
   end if
   -- increase indent if not top-level group
   if tGrpList is empty then
      -- start of a top level group
      put empty into tIndent
   else
      -- increase indent
      -- indents not only makes html look nice but text editors use indents to fold/unfold sections
      put tOneIndent after tIndent
   end if
   -- now add to list the left and top locations of new group
   -- to use in positioning elements contained by the group in css
   put the rect of control id tControl_ID into tRect
   put item 1 of tRect into item 1 of tGrpLoc
   put item 2 of tRect into item 2 of tGrpLoc
   put tGrpLoc & LF after tGrpLocList
   -- finally return the result
   put tHTML into tResult["html"]
   put tCSS into tResult["css"]
   -- also need to return other items modified: tGrpList, tGrpLocList, tIndent
   put tGrpList into tResult["tGrpList"]
   put tGrpLocList into tResult["tGrpLocList"]
   put tIndent into tResult["tIndent"]
   return tResult
end fExportGroup
-----------------------------------------------

function fExportRadioButton tControl_ID, tGrp, tGrpLoc, tIndent
   -- uses function fIDname
   -- the long name of control id tControl_ID is the full name of the control
   -- tGrp = for example, "of group 1045" or empty
   -- although LC radios MUST be grouped to work in LC
   -- tGrpLoc = for example, "237,49" or empty
   /*
   For all radio buttons in same group in LC, need to write html with same "name" attribute,
   which is the requirement to get only one selected at a time.
   Use id of the LC group they are in as the "name" attribute - better than requiring
   a special name be given to radio button by designer...
   */
   put "radio_" & tGrp into tRadioGroupName
   replace quote with empty in tRadioGroupName
   replace space with "_" in tRadioGroupName
   -- tRadioGroupName is used below in html for both the html button and the button label
   put fIDname(tControl_ID) into tIDname
   put the short name of control id tControl_ID into tRadioButtonName
   -- write html for label tag
   put tIndent & "<label" into tHTML
   put space & "id=" & quote & tIDname & "_LABEL" & quote after tHTML
   put space & "name=" & quote & tRadioGroupName & quote after tHTML
   put ">" & LF after tHTML
   -- end of html for <label> NEED TO END WITH </label> BELOW
   -- write html for input tag
   put tIndent & tIndent & "<input type=" & quote & "radio" & quote after tHTML
   put space & "id=" & quote & tIDname & quote after tHTML
   put space & "name=" & quote & tRadioGroupName & quote after tHTML
   if the hilite of control id tControl_ID is true then
      put space & "checked" after tHTML
   end if
   put ">" & LF after tHTML
   -- end of html for input tag
   -- write html for span tag with radio button name
   put tIndent & tIndent & "<span" after tHTML
   put space & "id=" & quote & tIDname & "_SPAN" & quote & ">" after tHTML
   put tRadioButtonName after tHTML
   put "</span>" & LF after tHTML
   -- end html for span tag with checkbox name
   -- write html for end of label tag
   put tIndent & "</label>" & LF after tHTML
   -- end of html
   -- write css for label tag
   -- THIS IS SPECIAL and does NOT use fReturnCSSprops
   put "#" & tIDname & "_LABEL" && "{" & LF into tCSS
   put the rect of control id tControl_ID into tRect
   put item 1 of tRect into tLeft
   put item 2 of tRect into tTop
   if  tGrpLoc is empty then
      -- element not in a group
      -- position is relative to left, top of page
   else
      -- element is in a group
      -- position it relative to the group, not
      -- LiveCode's position relative to card
      subtract item 1 of tGrpLoc from tLeft
      subtract item 2 of tGrpLoc from tTop
   end if
   put space & "left:" && tLeft & "px;" & LF after tCSS
   put space & "top:" && tTop & "px;" & LF after tCSS
   -- conclude css
   put "}" & LF & LF after tCSS
   -- end of css for label tag
   -- DO NOT seem to need css for input (radio button) tag
   -- write css for span tag
   put "#" & fIDname(tControl_ID) & "_SPAN" && "{" & LF after tCSS
   put space & "margin-left: 22px;" & LF after tCSS
   put space & "line-height: 22px;" & LF after tCSS
   -- conclude css
   put "}" & LF & LF after tCSS
   -- end css for span tag
   -- finally return the result
   put tHTML into tResult["html"]
   put tCSS into tResult["css"]
   return tResult
end fExportRadioButton

-----------------------------------------------

function fExportStandardButton tControl_ID, tGrp, tGrpLoc, tIndent, aCSSprops
   -- uses function fIDname
   -- uses function fReturnCSSprops
   -- There are different types of buttons
   -- The types you click to run a script are Javascript input type="button"
   -- This function is for the type you click to run a script
   -- <input type="button" value="button label">
   put "button" into tType
   put tIndent & "<input type=" & quote & tType & quote into tHTML
   put fIDname(tControl_ID) into tIDname
   put space & "id=" & quote & tIDname & quote after tHTML
   put the label of control id tControl_ID into tButtonName
   if tButtonName is empty then
      put the short name of control id tControl_ID into tButtonName
   end if
   put space & "value=" & quote & tButtonName & quote after tHTML
   put ">" after tHTML
   put "</input>" & LF after tHTML
   -- end html
   -- write css
   put "#" & fIDname(tControl_ID) && "{" & LF into tCSS
   put empty into tGrpLocList -- used in fReturnCSSprops for groups, this copy local to this function
   put fReturnCSSprops(tControl_ID, tGrpLoc, tGrpLocList, aCSSprops) after tCSS
   -- conclude css
   put "}" & LF & LF after tCSS
   -- end of css
   -- finally return the result
   put tHTML into tResult["html"]
   put tCSS into tResult["css"]
   return tResult
end fExportStandardButton

-----------------------------------------------

function fExportMenuButton tControl_ID, tGrp, tGrpLoc, tIndent, aCSSprops
   -- uses function fReturnCSSprops
   -- uses function fIDname
   put tIndent & "<select" into tHTML
   put fIDname(tControl_ID) into tIDname
   put space & "id=" & quote & tIDname & quote after tHTML
   put the label of control id tControl_ID into tButtonName
   if tButtonName is empty then
      put the short name of control id tControl_ID into tButtonName
   end if
   put space & "value=" & quote & tButtonName & quote after tHTML
   put ">" & LF after tHTML
   -- now need to enter menu options
   put the text of control id tControl_ID into tOptions
   repeat for each line tOpt in tOptions
      -- add double indents so text editors can fold/unfold select
      put tIndent & tIndent & "<option value=" after tHTML
      put quote & tOpt & quote & ">" & tOpt & "</option>" & LF after tHTML
   end repeat
   put tIndent & "</select>" & LF after tHTML
   -- end html
   -- write css
   put "#" & fIDname(tControl_ID) && "{" & LF into tCSS
   put empty into tGrpLocList -- used in fReturnCSSprops for groups, this copy local to this function
   put fReturnCSSprops(tControl_ID, tGrpLoc, tGrpLocList, aCSSprops) after tCSS
   -- conclude css
   put "}" & LF & LF after tCSS
   -- end of css
   -- finally return the result
   put tHTML into tResult["html"]
   put tCSS into tResult["css"]
   return tResult
end fExportMenuButton

-----------------------------------------------

function fExportCheckBox tControl_ID, tGrp, tGrpLoc, tIndent
   -- uses function fIDname
   -- the long name of control id tControl_ID is the full name of the control
   -- tGrp = for example, "of group 1045" or empty
   -- tGrpLoc = for example, "237,49" or empty
   -- returns associative array with ["html"] and ["css"] contents
   put fIDname(tControl_ID) into tIDname
   put the short name of control id tControl_ID into tCheckBoxName
   -- write html for label tag
   put tIndent & "<label" into tHTML
   put space & "id=" & quote & tIDname & "_LABEL" & quote after tHTML
   put ">" & LF after tHTML
   -- end of html for <label> NEED TO END WITH </label> BELOW
   -- write html for input tag
   put tIndent & tIndent & "<input type=" & quote & "checkbox" & quote after tHTML
   put space & "id=" & quote & tIDname & quote after tHTML
   if the hilite of control id tControl_ID is true then
      put space & "checked" after tHTML
   end if
   put ">" & LF after tHTML
   -- end of html for input tag
   -- write html for span tag with checkbox name
   put tIndent & tIndent & "<span" after tHTML
   put space & "id=" & quote & tIDname & "_SPAN" & quote & ">" after tHTML
   put tCheckBoxName after tHTML
   put "</span>" & LF after tHTML
   -- end html for span tag with checkbox name
   -- write html for end of label tag
   put tIndent & "</label>" & LF after tHTML
   -- end of html
   -- THIS IS SPECIAL and does NOT use fReturnCSSprops
   -- write css for label tag
   put "#" & tIDname & "_LABEL" && "{" & LF into tCSS
   put the rect of control id tControl_ID into tRect
   put item 1 of tRect into tLeft
   put item 2 of tRect into tTop
   if  tGrpLoc is empty then
      -- element not in a group
      -- position is relative to left, top of page
   else
      -- element is in a group
      -- position it relative to the group, not
      -- LiveCode's position relative to card
      subtract item 1 of tGrpLoc from tLeft
      subtract item 2 of tGrpLoc from tTop
   end if
   put space & "left:" && tLeft & "px;" & LF after tCSS
   put space & "top:" && tTop & "px;" & LF after tCSS
   -- conclude css
   put "}" & LF & LF after tCSS
   -- end of css for label tag
   -- DO NOT seem to need css for input (checkbox) tag
   -- write css for span tag
   put "#" & fIDname(tControl_ID) & "_SPAN" && "{" & LF after tCSS
   put space & "margin-left: 22px;" & LF after tCSS
   put space & "line-height: 18px;" & LF after tCSS
   -- conclude css
   put "}" & LF & LF after tCSS
   -- end css for span tag
   -- finally return the result
   put tHTML into tResult["html"]
   put tCSS into tResult["css"]
   return tResult
end fExportCheckBox

-----------------------------------------------

function fExportField tControl_ID, tGrp, tGrpLoc, tIndent
   -- uses function fIDname
   -- the long name of control id tControl_ID is the full name of the control
   -- tGrp = for example, "of group 1045" or empty
   -- tGrpLoc = for example, "237,49" or empty
   -- there are different types of fields, e.g., <p> for locked, <input> for unlocked
   -- TEXT IN LOCKED LC FIELDS will be written to html in <p> tags
   -- TEXT IN UN-LOCKED LC FIELDS will be written as VALUE attribute in <input> tags
   if the lockText of control id tControl_ID is true then
      put "p" into tFieldType
   else
      put "input" into tFieldType
   end if
   put tIndent & "<" & tFieldType into tHTML
   put fIDname(tControl_ID) into tIDname
   put space & "id=" & quote & tIDname & quote after tHTML
   if tFieldType is "input" then
      put the text of control id tControl_ID into tValue
      put space & "value=" & quote & tValue & quote after tHTML
   end if
   put ">" & space after tHTML
   if tFieldType is "p" then
      -- the htmlText has extra <p></p> tags which then
      -- won't be referenced in CSS and thus flow that text from top of page
      -- but some tags such as <font> for color and <sup> work...
      put the htmlText of control id tControl_ID into tTempText
      replace "<p>" with "<br>" in tTempText
      replace "</p>" with empty in tTempText
      -- delete first <br>
      if char 1 to 4 of tTempText is "<br>" then
         delete char 1 to 4 of tTempText
         -- use double indents so text editor can fold/unfold <p>
         put tIndent & tIndent before tTempText
      end if
      -- use double indents on the rest of the <br> so text editor can fold/unfold <p>
      -- but do this after delete first <br>
      replace "<br>" with tIndent & tIndent & "<br>" in tTempText
      put LF & tTempText after tHTML
   end if
   put LF & tIndent & "</" & tFieldType & ">" & LF after tHTML
   -- write css
   -- THIS IS SPECIAL and does NOT use fReturnCSSprops
   put "#" & fIDname(tControl_ID) && "{" & LF into tCSS
   put the rect of control id tControl_ID into tRect
   put item 1 of tRect into tLeft
   put item 2 of tRect into tTop
   if  tGrpLoc is empty then
      -- element not in a group
      -- position is relative to left, top of page
   else
      -- element is in a group
      -- position it relative to the group, not
      -- LiveCode's position relative to card
      subtract item 1 of tGrpLoc from tLeft
      subtract item 2 of tGrpLoc from tTop
   end if
   if tFieldType is "p" then
      -- xxx having trouble locating fields, so try a subtraction here...
      -- xxx maybe location of text inside field differs and may depend on font size?
      subtract 16 from tTop -- was 16
   end if
   -- need position: absolute here but not for general <p>
   -- because that messes up text added to HTML later
   put space &  "position: absolute;" & LF after tCSS
   put space & "left:" && tLeft & "px;" & LF after tCSS
   put space & "top:" && tTop & "px;" & LF after tCSS
   put the width of control id tControl_ID into tWd
   put the height of control id tControl_ID into tHt
   put space & "width:" && tWd & "px;" & LF after tCSS
   put space & "height:" && tHt & "px;" & LF after tCSS
   put the textAlign of control id tControl_ID into tTextAlign
   if tTextAlign is not "left" then
      put space & "text-align:" & space & tTextAlign & ";" & LF after tCSS
   end if
   -- conclude css
   put "}" & LF & LF after tCSS
   -- end of css
   -- finally return the result
   put tHTML into tResult["html"]
   put tCSS into tResult["css"]
   return tResult
end fExportField

-----------------------------------------------

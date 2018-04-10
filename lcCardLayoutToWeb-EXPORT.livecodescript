script "lcCardLayoutToWeb-EXPORT"
/*
Design, text, images and code by  ichard K. Herz, 2017-2018
Copyrights held by Richard K. Herz
https://github.com/RichardHerz
Licensed for use under the GNU General Public License v3.0
https://www.gnu.org/licenses/gpl-3.0.en.html
*/

constant kProjectName = "lcCardLayoutToWeb" -- controls with this in name aren't written to html
-- make sure value of constant kProjectName is the same in both script files

constant kFieldShift = 16 -- was 16, subtract to shift locked fields when exporting <p> tags, add on import 
-- make sure value of constant kFieldShift is the same in both script files

constant kTextFontExportAdd = 3 -- was 3, value to add to font size on export, subtract on import
-- make sure value of constant kTextFontExportAdd is the same in both script files 

constant kScriptTagPrefix = "scriptTag" -- used on IMPORT and EXPORT of script tags in html body
-- make sure value of constant kScriptTagPrefix is the same in both script files 

constant kCommentTagPrefix = "commentTag" -- used on IMPORT and EXPORT of script tags in html body
-- make sure value of constant kCommentTagPrefix is the same in both script files 

constant kDottedBorderColor = "DodgerBlue"

-- Writes to files in output folder kWebOutputFolder & "card" & LC stack card number
constant kWebOutputFolder = "web output"
-- images should be added to LiveCode stack only BY REFERENCE
--      to image file which should be located in images folder kImagesFolder
--      and not imported into LC stack
constant kImagesFolder = "images"
constant kJavascriptFolder = "js"
constant kCssFolder = "css"
constant kCssFileName = "index.css"
constant kHtmlFileName = "index.html"
-- set number of spaces to indent
--      used to increase and decrease indents
--      not only makes html look nice but text editors use indents to fold/unfold sections
constant kIndentSpaces = 3

-- use kReporter "true" to activate all reports below to msg box
-- or use a special value to activate only selected reports below
-- EXAMPLE:  if kReporter is "true" then put LF & tData after msg -- true displays all 
-- EXAMPLE:  if kReporter is "TEST" then put LF & tData after msg -- only displays some
constant kReporter = "false"

local oBorderFlag -- used to show borders of fields on mouseEnter during development

/* 
WARNING - output files for same LiveCard card will be written over each time exportWebPage runs, 
so save copies of the output files you want to keep

WARNING - use LF line endings when constructing text and write to file with file opened for binary write,
so that you can view source in all browsers with lines broken at line endings
*/

-----------------------------------------------

on openCard
   if the short name of the topStack is kProjectName then
      set the backgroundColor of this card to 255,255,255
      put kProjectName && "card name" into tCardName
      if there is a field tCardName then
         put the name of the current card into tName
         if tName contains "card id" & space then
            put "card" && the number of the current card into tName
         end if
         replace quote with empty in tName
         put tName into field tCardName
      end if
   end if
   pass openCard
end openCard

-----------------------------------------------

on mouseEnter
   -- show borders of fields without borders during development
   put the name of this stack into tStack
   if kProjectName is not in tStack then exit mouseEnter
   put the long name of the target into tLongName
   if there is tLongName then -- was getting errors when property panel open
      if word 1 of tLongName is "field" then
         -- put "stack = " & tStack & " ; tLongName = " & tLongName into msg
         set the showFocusBorder of tLongName to false
         if the showBorder of tLongName is false then
            set the showBorder of tLongName to true
            put true into oBorderFlag
         end if
      end if
   end if
end mouseEnter

-----------------------------------------------

on mouseLeave
   put the name of this stack into tStack
   if kProjectName is not in tStack then exit mouseLeave
   put the long name of the target into tLongName
   if there is tLongName then -- was getting errors when property panel open
      if word 1 of tLongName is "field" then
         -- put empty into msg
         if oBorderFlag is true then
            set the showBorder of tLongName to false
            --  -- if below used in development
            --          if the commandKey is down then
            --             -- leave border set
            --          else
            --             set the showBorder of tLongName to false
            --          end if
         end if
      end if
   end if
   put false into oBorderFlag
end mouseLeave

-----------------------------------------------

on exportWebPage
   
   -- WARNING - output files for same LiveCard card will be written over
   -- each time this runs, so save ones you want to keep
   
   set the defaultStack to kProjectName
   
   ---------- START INPUT DATA ------------
   
   -- SET ARRAY WITH EXPORT CONVERSION OF LIVECODE TO CSS PROPERTIES
   -- keys of array aCSSprops are LiveCode properties
   -- values are equivalent CSS properties
   -- put CSS value into aCSSprops[LC key]
   -- SOME DEACTIVATED BY COMMENTS BELOW
   put empty into aCSSprops
   -- CSS opacity = 0 -> 1 (1 is opaque), LC blendLevel =100 -> 0 (0 is opaque)
   -- opacity/blendLevel apply to div/group contents as well as area
   put "opacity" into aCSSprops["blendLevel"]
   -- visibility/visible apply to div/group contents as well as area
   put "visibility" into aCSSprops["visible"] -- LC true-false; CSS visible-hidden
   -- LC showBorder is true-false
   -- CSS border-style is none, hidden, dotted, dashed, solid, double, groove, ridge, inset, outset
   -- as of now, only one CSS style picked in fReturnCSSprops
   -- development button "outlines" overrides border-style
   put "border-style" into aCSSprops["showBorder"]
   -- LC borderWidth is pixel value; CSS border-width is thin, medium, thick or px
   put "border-width" into aCSSprops["borderWidth"]
   -- LC RGB values; CSS Valid color names, rgb(#,#,#), rgba(#,#,#,#), hexidecimal notation
   -- also for LC backColor need to check LC opaque, which applies to group/div area only not contents
   put "background-color" into aCSSprops["backColor"]
   -- stop using LC margins, interferes with location of some controls
   -- --       put "margin" into aCSSprops["margins"] -- LC is pixel value; CSS px
   
   --  answer "just set the keys of aCSSprops = " & the keys of aCSSprops -- xxx
   
   ---------- END INPUT DATA ------------
   
   -- Controls with short name containing kProjectName
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
   
   -- MUST USE MESSAGE BOX FOR DEVELOPMENT RECORD - NOT FIELD
   -- BECAUSE CAN'T ACCESS FIELD WHEN EDITING A GROUP easily at least
   -- do not always put empty into msg here because will open msg box even if not used
   if kReporter is not "false" then put empty into msg 
   
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
   put kProjectName && "card name" into tCardName
   if there is a field tCardName then
      put field tCardName into tName
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
   put tCssFolderPath & "/" & kCssFileName into tCssFilePath -- tCssFilePath used at end this handler
   -- create folder for Javascript
   put tOutputFolderPath & "/" & kJavascriptFolder into tJavascriptFolderPath
   if there is a folder tJavascriptFolderPath then
      -- do nothing
   else
      create folder tJavascriptFolderPath
   end if
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
   put "new" into tHeaderFlag
   if the cHeaderData of this card is empty then
      -- do nothing
      -- leave tHeaderFlag = "new"
   else
      -- have text in cHeaderData of this card
      -- this would have been set during previous import of an html file
      -- without a CLEAR CARD before this export
      
      -- xxx maybe automatically edit cHeaderData to change meta viewport 
      -- width for any current simFrame width & left
      
      answer "Old HTML head tag exists from last import - replace with new data?" with "yes" or "no"
      
      if it is "no" then
         put "old" into tHeaderFlag
         put the cHeaderData of this card after tHTML
      else
         -- leave tHeaderFlag = "new"
      end if
      
   end if
   
   if tHeaderFlag is "new" then
      -- write new header data for a new html file
      put "<!doctype html>" & LF & "<html>" & LF & "<head>" & LF & LF after tHTML
      
      put "<title>** EDIT TITLE **</title>" & LF & LF after tHTML
      
      -- NOTE can use double-quotes around text with single quotes vs. adding quote constants in string
      put "<meta name='description' content='designed with lcCardLayoutToWeb project at GitHub'>" & LF & LF after tHTML
      
      put "<!-- A VIEWPORT META LINE IN HTML HEAD IS NECESSARY FOR CSS @MEDIA TO WORK -->" & LF after tHTML
      put "<!-- ID used to modify with Javascript after initial loading - OR EDIT HERE -->" & LF after tHTML
      
      put "<!-- suggest use content width = div_simFrame width + 2 * div_simFrame left, and no scale -->" & LF after tHTML
      if there is a group "simFrame" of this card then put the width of group "simFrame" of this card into tSimFrameWidth
      if there is a group "simFrame" of this card then put the left of group "simFrame" of this card into tSimFrameLeft
      -- note: special simFrame group will get css position: relative but left still affects placement
      add 2*tSimFrameLeft to tSimFrameWidth
      
      put "<meta id='meta-viewport' name='viewport' content='width=" & tSimFrameWidth & "'>" & LF & LF after tHTML
      
      -- load CSS style sheets
      put "<!-- load CSS style sheets for this lab  -->" & LF after tHTML
      -- use relative path to css file here:  kCssFolder & "/" & kCssFileName 
      -- and NOT full path so that it works both on web and in LC project
      put "<link rel=" & quote & "stylesheet" & quote && "href=" & quote & kCssFolder & "/" & kCssFileName & quote & ">" & LF & LF after tHTML
      -- need to add links for javascript files
      put "<!-- load JAVASCRIPT files for this lab  -->" & LF after tHTML
      put "<!-- e.g., <script language='javascript' src='js/process_main.js' type='text/javascript'></script> -->" & LF & LF after tHTML
      
      put "</head>" & LF after tHTML
   end if -- end check for old header data
   put "<body>" & LF after tHTML
   
   -- start building the css
   -- sup - superscript - decrease text size
   put "sup {" & LF after tCSS
   put space & space & "font-size: smaller;" & LF after tCSS
   put "}" & LF & LF after tCSS
   -- sub - subscript - decrease text size
   put "sub {" & LF after tCSS
   put space & space & "font-size: smaller;" & LF after tCSS
   put "}" & LF & LF after tCSS
   -- input
   put "input {" & LF after tCSS
   put space & space & "display: block;" & LF after tCSS
   put space & space & "position: absolute;" & LF after tCSS
   put space & space & "text-align: center;" & LF after tCSS -- override LC textAlign setting for input fields
   put "}" & LF & LF after tCSS -- finish css for input
   -- button
   put "input, button {" & LF after tCSS
   put space & space & "text-align: center;" & LF after tCSS -- override LC textAlign setting for buttons
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
   put space & space & "display: block;" & LF after tCSS
   put space & space & "text-align: left;" & LF after tCSS
   put kProjectName && "outlines" into tBtnName
   if there is a button tBtnName then
      if the hilite of button tBtnName is true then
         put space & space & "border-style: dotted;" & LF after tCSS
         put space & space & "border-color:" &&  kDottedBorderColor & ";" & LF after tCSS
      end if
   end if
   put "}" & LF & LF after tCSS -- finish css for p, locked field
   -- label
   put "label {" & LF after tCSS
   put space & space & "display: block;" & LF after tCSS
   put space & space & "position: absolute;" & LF after tCSS
   put "}" & LF & LF after tCSS -- finish css for label
   -- img
   put "img {" & LF after tCSS
   put space & space & "display: block;" & LF after tCSS
   put space & space & "position: absolute;" & LF after tCSS
   put "}" & LF & LF after tCSS -- finish css for img
   -- select (menu buttons)
   put "select {" & LF after tCSS
   put space & space & "display: block;" & LF after tCSS
   put space & space & "position: absolute;" & LF after tCSS
   put "}" & LF & LF after tCSS -- finish css for select
   -- canvas - html canvas element
   put "canvas {" & LF after tCSS
   put space & space & "display: block;" & LF after tCSS
   put space & space & "position: absolute;" & LF after tCSS
   put space & space & "text-align: left;" & LF after tCSS
   put "}" & LF & LF after tCSS -- finish css for input
   -- special for Internet Explorer, remove tooltips, especially from range-slider inputs
   put "::-ms-tooltip {" & LF after tCSS
   put space & space & "display: none;" & LF after tCSS
   put "}" & LF & LF after tCSS -- finish css for special for IE tooltip 
   
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
      
      if the short name of control tControlNumber contains kProjectName then
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
            -- "<!-- end of div" literal used on import to not duplicate comment - do not change here
            put tIndent & "</div>" && "<!-- end of div" && it && "-->" & LF into tNewLine
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
            -- get the html and css for this style of button
            switch tStyle
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
                  -- check for special button
                  if the first word of the short name of control tControlNumber is "PLOTDIV" then
                     -- button used to represent an empty html div tag in html body for x-y plotting
                     get fExportPLOTDIV(tControl_ID, tGrpList, tGrpLocList, tOneIndent, tIndent, aCSSprops)
                  else if the first word of the short name of control tControlNumber is "CANVAS" then
                     -- button used to represent an html canvas tag in html body
                     get fExportCANVAS(tControl_ID, tGrp, tGrpLoc, tIndent, aCSSprops)
                  else if the first word of the short name of control tControlNumber is kScriptTagPrefix then
                     -- button used to hold a script tag in html body
                     get fExportScriptTag(tControl_ID, tIndent)
                  else if the first word of the short name of control tControlNumber is kCommentTagPrefix then
                     -- button used to hold a comment tag in html body
                     get fExportCommentTag(tControl_ID, tIndent)
                  else
                     -- a standard button
                     get fExportStandardButton(tControl_ID, tGrp, tGrpLoc, tIndent, aCSSprops)
                  end if
            end switch
            -- put the button result after tHTML and tCSS
            put it into tResult
            put tResult["html"] after tHTML
            put tResult["css"] after tCSS
            break
         case "field"
            get fExportField(tControl_ID, tGrp, tGrpLoc, tIndent, aCSSprops)
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
            if kReporter is "true" then
               put "unknown control, id, long name = " & LF & tControl_ID & LF & the long name of control tControlNumber & LF after msg
            end if
            -- **UNKNOWN CONTROL** referenced at end this command so edit if change text here
            put "<!-- *********UNKNOWN CONTROL**" && "LC id =" && the long name of control tControlNumber && "-->" & LF after tHTML
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
      -- "<!-- end of div" literal used on import to not duplicate comment - do not change here
      put tIndent & "</div>" && "<!-- end of div" && it && "-->" & LF into tNewLine
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
   
   -- finish building the css with example @media
   put "/* example @media for responsive design */" & LF after tCSS
   put "/* requires meta viewport element in HTML head */" & LF after tCSS
   put "@media(max-width: 640px) {" & LF after tCSS
   put "  /* change the following when the screen width is <= 640px */" & LF after tCSS
   put "  /* #div_controller {" & LF after tCSS
   put "    top: 600px;" & LF after tCSS
   put "    left: 20px;" & LF after tCSS
   put "   } */" & LF after tCSS
   put "}" & LF after tCSS
   
   -- write css text with binary write
   open file tCssFilePath for binary write
   write tCSS to file tCssFilePath
   close file tCssFilePath
   
   beep
   
   if tHTML contains "**UNKNOWN CONTROL**" then
      answer "Unknown controls were detected - see comments **UNKNOWN CONTROL** in HTML file for info"
   end if
   
end exportWebPage

-----------------------------------------------

function fReturnHtmlEvents pControl_ID
   -- get and return any html event code
   -- only events handled on IMPORT are those in constant kEventList of the IMPORT script-only stack
   -- naming convention for html events saved as LC custom props is, e.g., event_onchange
   -- with the key prefix event_
   -- make sure same naming convention in both IMPORT and EXPORT script-only stacks
   put empty into tHtml
   put the customKeys of control id pControl_ID into tEventLines
   repeat for each line tLIne in tEventLines
      put tLine into tLongName
      if offset("event_",tLongName) = 1 then
         put tLongName into tShortName
         delete char 1 to 6 of tShortName -- chars of "event_"
         put the tLongName of control id pControl_ID into tEventCode
         put space & tShortName & "=" & quote & tEventCode & quote after tHtml
      end if
   end repeat
   return tHtml
end fReturnHtmlEvents
-----------------------------------------------

function fReturnCSSprops tControl_ID, tGrpLoc, tGrpLocList, aCSSprops
   
   -- functions which do NOT use this function:
   -- fExportScrollBar
   -- fExportRadioButton
   -- fExportCheckBox
   
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
      put space & space & "position: absolute;" & LF after tCSS -- all elements will have position: absolute
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
   put space & space & "left:" && tLeft & "px;" & LF after tCSS
   put space & space & "top:" && tTop & "px;" & LF after tCSS
   put the width of control id tControl_ID into tWd
   put the height of control id tControl_ID into tHt
   put space & space & "width:" && tWd & "px;" & LF after tCSS
   put space & space & "height:" && tHt & "px;" & LF after tCSS
   put the keys of aCSSprops into tHitList -- key is LC prop name, value is CSS prop name 
   put the properties of control id tControl_ID into aControlProps
   put the keys of aControlProps into tKeyList -- key is LC prop name, value is LC prop value
   repeat for each line tKey in tKeyList
      -- tKey is LC prop name
      if tKey is among the lines of tHitList then
         -- LC prop name is a key of aCSSprops[LC prop name] = CSS prop name
         if aControlProps[tKey] is not empty then
            -- LC prop name has a value set
            -- switch case sets CSS value from LC value in aControlProps[tKey]
            --        but probably could set up this value correspondence in
            --        array(s) but use switch for now
            -- WARNING: some properties listed below have been deactivated
            -- by comments in exportWebPage where aCSSprops array is specified
            put empty into tValue -- check below if switch sets a prop value to write to tCSS
            switch tKey
               -- put CSS prop values into tValue variable,
               -- then append CSS prop name: value to tCSS immediately after switch structure below
               case "margins"
                  -- LC is pixel value; CSS px
                  put aControlProps[tKey] & "px" into tValue
                  break
               case "backColor"
                  -- WARNING: will not get here if no backColor is set so
                  --     need to check LC opaque below
                  --     if LC opaque is false need to set rgba of CSS background-color even if no LC backColor
                  -- LC RGB values; CSS Valid color names, rgb(#,#,#), rgba(#,#,#,#), hexidecimal notation
                  if the opaque of control id tControl_ID is true then
                     put "rgb(" & aControlProps[tKey] & ")" into tValue
                  else
                     -- LC opaque is false, so need to set rgba color with alpha (a) = 0
                     -- LC opaque applies to group/div area only not contents
                     put "rgba(" & aControlProps[tKey] & ", 0)" into tValue
                  end if
                  break
               case "blendLevel"
                  -- LC blendLevel 100 -> 0 (0 is opaque); CSS opacity 0 -> 1 (1 is opaque)
                  -- opacity/blendLevel apply to div/group contents as well as area
                  put aControlProps[tKey] into ttemp
                  put 1 - ttemp/100 into tValue
                  break
               case "visible"
                  -- LC true-false; CSS visible-hidden
                  -- visibility/visible apply to div/group contents as well as area
                  if aControlProps[tKey] is "true" then
                     put "visible" into tValue
                  else
                     put "hidden" into tValue
                  end if
                  break
               case "showBorder"
                  -- LC true-false; CSS none, hidden, dotted, dashed, solid, double, groove, ridge, inset, outset
                  -- different types of LC control affected differently, get type of control
                  put word 1 of the long name of control id tControl_ID into tControlType
                  if aControlProps[tKey] is "true" then
                     -- showBorder is true
                     -- was outset but looks bad (solid) on Win IE and Edge browsers?
                     if tControlType is "button" then
                        put "outset" into tValue -- try outset or none
                     else
                        put "dotted" into tValue
                     end if
                     -- LC property threeD affects border for groups & fields on LC card
                     -- light border if threeD true, solid border if threeD false
                     -- xxx so maybe should set border-style to solid with 1px width??
                     if tControlType is "group" or tControlType is "field" then
                        if the threeD of control id tControl_ID is true then
                           put "none" into tValue
                        end if
                     end if
                  else
                     put "none" into tValue
                  end if -- end if aControlProps[tKey] is "true" (tKey = showBorder)
                  -- let development button override for groups and fields only
                  put kProjectName && "outlines" into tBtnName
                  if there is a button tBtnName then
                     if the hilite of button tBtnName is true then
                        if tControlType is "group" or tControlType is "field" then
                           put "dotted" into tValue
                        end if
                     end if
                  end if
                  break
               case "borderWidth"
                  -- LC is pixel value; CSS thin, medium, thick or px
                  put aControlProps[tKey] & "px" into tValue
                  -- set unlocked input fields to have borderWidth of 1 px
                  if the long name of control id tControl_ID contains "field" then
                     if the locked of control id tControl_ID is false then
                        put "1px" into tValue
                     end if
                  end if
                  -- modify for menu style buttons only
                  -- if set standard buttons to 1px then they become rectanges
                  if word 1 of the long name of control id tControl_ID is "button" then
                     -- not all control types have style property so check for button first
                     if the style of control id tControl_ID is "menu" then
                        put "1px" into tValue
                     end if
                  end if
                  break
               default
                  put empty into tValue
            end switch
            
            -- write property and value to CSS
            if tValue is not empty then
               put space & space & aCSSprops[tKey] & ":" && tValue & ";" & LF after tCSS
               -- e.g., CSS prop name: value;
            end if -- end if tValue is not empty 
            
         end if -- end if aControlProps[tKey] is not empty
      end if -- end if tKey is among the lines of tHitList
   end repeat -- repeat for each line tKey in tKeyList
   
   -- SPECIAL - need to check LC opaque
   -- if LC backColor not empty, then this is handled above
   -- but if LC backColor is empty, then need to check here
   -- if LC opaque is false need to set rgba of CSS background-color even if no LC backColor
   -- last number of rgba is alpha, a = 0 is transparent, a = 1 is opaque
   -- LC opaque applies to group/div area only, not contents
   if the backColor of control id tControl_ID is empty then
      if the opaque of control id tControl_ID is true then
         put space & space & "background-color: rgba(255, 255, 255, 1);" & LF after tCSS
      else
         put space & space & "background-color: rgba(255, 255, 255, 0);" & LF after tCSS
      end if
   end if
   
   -- SPECIAL for PLOTDIV button to be exported as div
   -- need to override some border settings above after they are set
   -- and do this before special LC properties below so special LC props will be set on import
   if the first word of the short name of control id tControl_ID is "PLOTDIV" then
      put space & space & "border-style: dotted;" & LF after tCSS
      put space & space & "border-color:" &&  kDottedBorderColor & ";" & LF after tCSS
   end if
   
   -- SPECIAL LC PROPERTIES
   -- to get reversibility on export-import need to save special LC properties
   -- these are ignored by CSS processor but used on import back into this project
   
   -- start handle LCvScrollbar
   -- xxx for now, "try" for quick fix - should apply to groups and fields only?
   try 
      if the vScrollbar of control id tControl_ID is true then
         put space & space & "LCvScrollbar: true;" & LF after tCSS
      else
         put space & space & "LCvScrollbar: false;" & LF after tCSS
      end if
   end try
   -- endhandle LCvScrollbar
   
   -- start handle LCthreeD
   if the threeD of control id tControl_ID is true then
      put space & space & "LCthreeD: true;" & LF after tCSS
   else
      put space & space & "LCthreeD: false;" & LF after tCSS
   end if
   -- end handle LCthreeD
   
   -- start handle LCshowBorder  
   if the showBorder of control id tControl_ID is true then
      put space & space & "LCshowBorder: true;" into tTempCSS
   else
      put space & space & "LCshowBorder: false;" into tTempCSS
   end if
   -- let development button override showBorder for groups and fields only
   put kProjectName && "outlines" into tBtnName
   if there is a button tBtnName then
      if the hilite of button tBtnName is true then
         if tControlType is "group" or tControlType is "field" then
            put space & space & "LCshowBorder: true;" into tTempCSS
         end if
      end if
   end if
   put tTempCSS & LF after tCSS
   -- end handle LCshowBorder  
   
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
               -- check for button representing an HTML CANVAS element
               if word 1 of the short name of control id tControl_ID is "CANVAS" then
                  put "canvas" into t1
               else
                  -- this is a standard button
                  put "button" into t1
               end if
         end switch
   end switch
   put word 2 of the long name of control id tControl_ID into t2
   if t2 is "id" then
      -- no name assigned by user, use LC control id
      -- reference in long names will be, e.g., field id 3333
      -- after export, on subsquent import, the short name will be, e.g., field_3333
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
      put t1 & "_" & t2 into tResult
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
   put the filename of control id tControl_ID into tFileName
   put space & "src=" & quote & tFileName & quote after tHTML
   -- get and write any html event code
   get fReturnHtmlEvents(tControl_ID)
   put it after tHtml
   put ">" & LF after tHTML
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
   
   if kReporter is "true" then put LF & "fExportScrollBar, tStartValue = " & tStartValue after msg -- development field
   
   -- at least in LC 9(dp 7) getting empty for startValue even when property inspector
   -- shows 0 but if manually increment and decrement value in prop inspec then
   -- will get 0 here....
   if tStartValue is empty then put 0 into tStartValue
   
   if kReporter is "true" then put LF & "fExportScrollBar, tStartValue = " & tStartValue after msg -- development field
   
   put the endValue of control id tControl_ID into tEndValue
   
   if kReporter is "true" then put LF & "fExportScrollBar, tEndValue = " & tEndValue after msg -- development field
   
   -- WILL WRITE SOME MORE HTML BELOW
   
   -- WRITE CSS (AND SOME MORE HTML) 
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
   
   -- THERE ARE 4 POSSIBLE ARRANGEMENTS CONSIDERED HERE FOR RANGE, SCROLLBAR, SCALE, SLIDER
   -- FOR ALL, HTML "min" value must < "max" value & change orientation by css transform rotation
   -- LC startValue is always on left of horizontal, top of vertical & change orientation by startValue < or > endValue
   -- 1) horizontal with smaller value on left, larger on right (essentially default for both LC and HTML)
   -- 2) horizontal with max larger on left, smaller on right (css transform rotation 180 deg)
   -- 3) vertical with larger value on top, smaller on bottom (css transform rotation 270 deg)
   -- 4) vertical with smaller value on top, larger on bottom (css transform rotation 90 deg)
   -- DETECT WHICH CASE IN LC by width vs. height, startValue vs. endValue
   
   if tHt < tWd and tStartValue < tEndValue then put 1 into tScrollCase
   if tHt < tWd and tStartValue > tEndValue then put 2 into tScrollCase
   if tHt > tWd and tStartValue > tEndValue then put 3 into tScrollCase
   if tHt > tWd and tStartValue < tEndValue then put 4 into tScrollCase
   
   -- set html range min and max values
   switch tScrollCase
      case 1
         -- 1) horizontal with smaller value on left, larger on right
         put space & "min=" & quote & tStartValue & quote after tHTML
         put space & "max=" & quote & tEndValue & quote after tHTML
         break
      case 2
         -- 2) horizontal with max larger on left, smaller on right (css transform rotation 180 deg)
         put space & "min=" & quote & tEndValue & quote after tHTML
         put space & "max=" & quote & tStartValue & quote after tHTML
         break
      case 3
         -- 3) vertical with larger value on top, smaller on bottom (css transform rotation 270 deg)
         put space & "min=" & quote & tEndValue & quote after tHTML
         put space & "max=" & quote & tStartValue & quote after tHTML
         break
      case 4
         -- 4) vertical with smaller value on top, larger on bottom (css transform rotation 90 deg)
         put space & "min=" & quote & tStartValue & quote after tHTML
         put space & "max=" & quote & tEndValue & quote after tHTML
         break
      default
         answer "bad scrollbar orientation!"
   end switch
   
   -- LC pageInc and HTML range step not equivalent
   -- pageInc is where thumb jumps when click away in LC
   -- step is precision of value during drag in HTML, whereas click away thumb jumps to click
   put abs(tEndValue-tStartValue)/100 into tStep
   put space & "step=" & quote & tStep & quote after tHTML
   
   put the thumbPosition of control id tControl_ID into tThumbPosition
   put space & "value=" & quote & tThumbPosition & quote after tHTML
   
   -- get and write any html event code
   get fReturnHtmlEvents(tControl_ID)
   put it after tHtml
   
   -- conclude html
   put ">" & LF after tHTML
   -- no </ or /> end of tag for <input> used in HTML
   -- END HTML
   
   -- CONTINUE WITH CSS
   -- set css values
   switch tScrollCase
      case 1
         -- 1) horizontal with smaller value on left, larger on right (essentially default for both LC and HTML)
         -- so don't need to do anything here
         break
      case 2
         -- 2) horizontal with max larger on left, smaller on right (css transform rotation 180 deg)
         put space & space & "transform: rotate(180deg);" & LF after tCSS
         break
      case 3
         -- 3) vertical with larger value on top, smaller on bottom (css transform rotation 270 deg)
         put space & space & "transform: rotate(270deg);" & LF after tCSS
         -- need to swap LC ht and wd to get horiz, which will then be rotated
         put tWd into tOldWd
         put tHt into tOldHt
         put tOldWd into tHt
         put tOldHt into tWd
         -- now need to modify positioning left and top
         -- as if you rotate original vertical about roughly its
         -- center to horizontal, make those left, top the new left, top
         -- then rotate the new back to vertical
         -- note that original tLeft and tTop set above
         subtract tOldHt/2 from tLeft
         add tOldWd/4 to tLeft
         add tOldHt/2 to tTop
         subtract tOldWd/2 from tTop
         break
      case 4
         -- 4) vertical with smaller value on top, larger on bottom (css transform rotation 90 deg)
         put space & space & "transform: rotate(90deg);" & LF after tCSS
         -- need to swap LC ht and wd to get horiz, which will then be rotated
         put tWd into tOldWd
         put tHt into tOldHt
         put tOldWd into tHt
         put tOldHt into tWd
         -- now need to modify positioning left and top
         -- as if you rotate original vertical about roughly its
         -- center to horizontal, make those left, top the new left, top
         -- then rotate the new back to vertical
         -- note that original tLeft and tTop set above
         subtract tOldHt/2 from tLeft
         add tOldWd/4 to tLeft
         add tOldHt/2 to tTop
         subtract tOldWd/2 from tTop
         break
      default
         -- do nothing here, already alerted above
   end switch
   
   put space & space & "left:" && tLeft & "px;" & LF after tCSS
   put space & space & "top:" && tTop & "px;" & LF after tCSS
   put space & space & "width:" && tWd & "px;" & LF after tCSS
   put space & space & "height:" && tHt & "px;" & LF after tCSS
   -- conclude css
   put "}" & LF & LF after tCSS
   -- END CSS
   
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
   put space & space & "display: block;" & LF after tCSS
   if tIDname contains "div_simFrame" then
      -- SPECIAL outer group-div-frame name
      -- make position: relative so can add text above and below on web page
      put space & space & "position: relative;" & LF after tCSS
   else
      put space & space & "position: absolute;" & LF after tCSS
   end if
   put space & space & "border-color:" &&  kDottedBorderColor & ";" & LF after tCSS
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
   if "radio_of_group_" is in tRadioGroupName then
      replace "radio_of_group_" with "radio_of_div_" in tRadioGroupName
   end if
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
   -- get and write any html event code
   get fReturnHtmlEvents(tControl_ID)
   put it after tHtml
   put ">" & LF after tHTML
   -- end of html for input tag
   -- write html for span tag with radio button label
   put tIndent & tIndent & "<span" after tHTML
   put space & "id=" & quote & tIDname & "_SPAN" & quote & ">" after tHTML
   if the label of control id tControl_ID is not empty then
      put the label of control id tControl_ID after tHTML
   else
      put the short name of control id tControl_ID after tHTML
   end if
   put "</span>" & LF after tHTML
   -- end html for span tag with checkbox name
   -- write html for end of label tag
   put tIndent & "</label>" & LF after tHTML
   -- end of html
   -- write css for label tag
   -- THIS IS SPECIAL and does NOT use fReturnCSSprops
   put "#" & tIDname & "_LABEL" && "{" & LF into tCSS
   put space & space & "display: block;" & LF after tCSS
   put space & space & "position: absolute;" & LF after tCSS
   put the width of control id tControl_ID into tWd
   put the height of control id tControl_ID into tHt
   put space & space & "width:" && tWd & "px;" & LF after tCSS
   put space & space & "height:" && tHt & "px;" & LF after tCSS
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
   put space & space & "left:" && tLeft & "px;" & LF after tCSS
   put space & space & "top:" && tTop & "px;" & LF after tCSS
   -- conclude css
   put "}" & LF & LF after tCSS
   -- end of css for label tag
   -- DO NOT seem to need css for input (radio button) tag
   -- write css for span tag
   put "#" & fIDname(tControl_ID) & "_SPAN" && "{" & LF after tCSS
   put space & space & "margin-left: 22px;" & LF after tCSS
   put space & space & "line-height: 22px;" & LF after tCSS
   put the textSize of control id tControl_ID into tTextSize
   if tTextSize is empty then put 13 into tTextSize -- textSize does not get value if default shown in prop inspector
   add kTextFontExportAdd to tTextSize
   put space & space & "font-size:" && tTextSize & "px;" & LF after tCSS
   -- conclude css
   put "}" & LF & LF after tCSS
   -- end css for span tag
   -- finally return the result
   put tHTML into tResult["html"]
   put tCSS into tResult["css"]
   return tResult
end fExportRadioButton

-----------------------------------------------

function fExportScriptTag tControl_ID, tIndent
   -- this is for <script> tags that appear in the html body (those in header get saved with header)
   -- button custom prop cScriptTagCode holds <script> to </script> 
   -- cScriptTagCode must match name used in both IMPORT and EXPORT scripts
   put the cScriptTagCode of control id tControl_ID into tScriptCode
   put tIndent before tScriptCode
   put tScriptCode into tHTML
   put empty into tCSS
   -- finally return the result
   put tHTML into tResult["html"]
   put tCSS into tResult["css"]
   return tResult
end fExportScriptTag

-----------------------------------------------

function fExportCommentTag tControl_ID, tIndent
   -- this is for <!-- comment tags that appear in the html body (those in header get saved with header)
   -- button custom prop cCommentTagCode holds <!-- to --> 
   -- cCommentTagCode must match name used in both IMPORT and EXPORT scripts
   put the cCommentTagCode of control id tControl_ID into tCommentCode
   put tIndent before tCommentCode
   put tCommentCode into tHTML
   put empty into tCSS
   -- finally return the result
   put tHTML into tResult["html"]
   put tCSS into tResult["css"]
   return tResult
end fExportCommentTag

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
   -- get and write any html event code
   get fReturnHtmlEvents(tControl_ID)
   put it after tHtml
   put ">" & LF after tHTML
   -- no </ or /> end of tag for <input> used in HTML
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

function fExportPLOTDIV tControl_ID, tGrpList, tGrpLocList, tOneIndent, tIndent, aCSSprops   
   -- uses function fReturnCSSprops
   -- uses function fIDname
   -- these inputs are not modified: tControl_ID, tOneIndent
   -- PLOTDIV BUTTON in LC becomes an empty DIV in HTML
   -- add div tag
   -- indent manually here without altering tIndent, since will be terminated immediately
   put tIndent & tOneIndent & "<div" after tHTML
   put fIDname(tControl_ID) into tIDname
   delete char 1 to 7 of tIDname -- delete: button_
   put "div_" before tIDname
   put space & "id=" & quote & tIDname & quote after tHTML
   put ">" & LF after tHTML
   -- new for PLOTDIV - terminate the empty div immediately
   -- "<!-- end of div" literal used on import to not duplicate comment - do not change here
   put tIndent & tOneIndent & "</div>" && "<!-- end of div" && tIDname && "-->" & LF after tHTML
   -- end of html
   -- write css
   put fIDname(tControl_ID) into tIDname
   delete char 1 to 7 of tIDname -- delete: button_
   put "div_" before tIDname
   put "#" & tIDname && "{" & LF after tCSS
   -- WARNING: need to write display and position here for each separate div
   -- because doing so for all div interferes with plotting with jquery.flot.js
   put space & space & "display: block;" & LF after tCSS   
   put the last line of tGrpLocList into tGrpLoc
   -- PLOTDIV gets some special handling in fReturnCSSprops
   put fReturnCSSprops(tControl_ID, tGrpLoc, tGrpLocList, aCSSprops) after tCSS
   put space & space & "LCvScrollbar: false;" & LF after tCSS -- add, since will be a div 
   -- conclude css
   put "}" & LF & LF after tCSS
   -- end of css
   -- finally return the result
   put tHTML into tResult["html"]
   put tCSS into tResult["css"]
   return tResult
end fExportPLOTDIV

-----------------------------------------------

function fExportCANVAS tControl_ID, tGrp, tGrpLoc, tIndent, aCSSprops
   -- uses function fIDname
   -- uses function fReturnCSSprops
   -- this is for an LC button representing the area of an HTML CANVAS element
   -- (elsewhere I may have used "plotCanvas" for groups/divs for use with flot.js plotting)
   -- HTML EXAMPLE:  <canvas id="canvas_CANVAS_rate"></canvas>
   -- NOTE: width and height are special for canvas elements
   -- so get props first for CSS and then edit
   -- write css
   put "#" & fIDname(tControl_ID) && "{" & LF into tCSS
   put empty into tGrpLocList -- used in fReturnCSSprops for groups, this copy local to this function
   put fReturnCSSprops(tControl_ID, tGrpLoc, tGrpLocList, aCSSprops) into tTempCSS
   -- now need to get width and height for HTML and delete from CSS
   -- THIS IS WHAT IS IN tTempCSS
   --    put space & space & "width:" && tWd & "px;" & LF after tCSS
   --    put space & space & "height:" && tHt & "px;" & LF after tCSS
   put lineOffset("width:",tTempCSS) into tLineWd
   put line tLineWd of tTempCSS into tTempWd
   put lineOffset("height:",tTempCSS) into tLineHt
   put line tLineHt of tTempCSS into tTempHt
   -- delete lines from tTempCSS, higher number line first, and add comment
   if tLineHt > tLineWd then
      delete line tLineHt of tTempCSS
      put space & "/* canvas element width & height must be set in HTML and not in CSS */" into line tLineWd of tTempCSS
   else
      delete line tLineWd of tTempCSS
      put space & "/* canvas element width & height must be set in HTML and not in CSS */" into line tLineHt of tTempCSS
   end if
   put tTempCSS after tCSS
   -- conclude css
   put "}" & LF & LF after tCSS
   -- end of css 
   -- now extract width and height from tTempWd and tTempHt
   -- 300 w x 150 h is default for canvas element unless specify otherwise in HTML
   put 300 into tWidth
   put 150 into tHeight
   -- THIS IS WHAT IS IN tTempCSS
   --    put space & space & "width:" && tWd & "px;" & LF after tCSS
   --    put space & space & "height:" && tHt & "px;" & LF after tCSS
   put word 2 of tTempWd into tWidth
   put word 2 of tTempHt into tHeight
   -- delete "px;" (3 chars) since don't use units here in HTML
   repeat 3 times
      delete the last char of tWidth
      delete the last char of tHeight
   end repeat
   put tIndent & "<canvas" into tHTML
   put fIDname(tControl_ID) into tIDname
   put space & "id=" & quote & tIDname & quote after tHTML 
   -- add width and height here in HTML for canvas elements
   -- NOTE must use quotes (width="400") and not apostrophes (width='400') nor neither (width=400)
   -- and no spaces for later import by this project - see function fGetHtmlAttribute in IMPORT script stack
   put space & "width=" & quote & tWidth & quote && "height=" & quote & tHeight & quote & ">" after tHTML
   put "</canvas>" && "<!-- canvas for colormap graphic -->" & LF after tHTML
   -- add comment explaining special width and height
   put tIndent & "<!-- canvas element width & height must be specified here in HTML and not in CSS -->" & LF after tHTML
   -- end of html
   -- finally return the result
   put tHTML into tResult["html"]
   put tCSS into tResult["css"]
   return tResult
end fExportCANVAS

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
   -- get and write any html event code
   get fReturnHtmlEvents(tControl_ID)
   put it after tHtml
   -- end start of select tag
   put ">" & LF after tHtml
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
   -- get and write any html event code
   get fReturnHtmlEvents(tControl_ID)
   put it after tHtml 
   put ">" & LF after tHTML
   -- end of html for input tag
   -- write html for span tag with checkbox name
   put tIndent & tIndent & "<span" after tHTML
   put space & "id=" & quote & tIDname & "_SPAN" & quote & ">" after tHTML
   if the label of control id tControl_ID is not empty then
      put the label of control id tControl_ID after tHTML
   else
      put the short name of control id tControl_ID after tHTML
   end if
   put "</span>" & LF after tHTML
   -- end html for span tag with checkbox name
   -- write html for end of label tag
   put tIndent & "</label>" & LF after tHTML
   -- end of html
   -- THIS IS SPECIAL and does NOT use fReturnCSSprops
   -- write css for label tag
   put "#" & tIDname & "_LABEL" && "{" & LF into tCSS
   put the width of control id tControl_ID into tWd
   put the height of control id tControl_ID into tHt
   put space & space & "width:" && tWd & "px;" & LF after tCSS
   put space & space & "height:" && tHt & "px;" & LF after tCSS
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
   put space & space & "left:" && tLeft & "px;" & LF after tCSS
   put space & space & "top:" && tTop & "px;" & LF after tCSS
   -- conclude css
   put "}" & LF & LF after tCSS
   -- end of css for label tag
   -- DO NOT seem to need css for input (checkbox) tag
   -- write css for span tag
   put "#" & fIDname(tControl_ID) & "_SPAN" && "{" & LF after tCSS
   put space & space & "margin-left: 22px;" & LF after tCSS
   put space & space & "line-height: 18px;" & LF after tCSS
   put the textSize of control id tControl_ID into tTextSize
   if tTextSize is empty then put 13 into tTextSize -- textSize does not get value if default shown in prop inspector
   add kTextFontExportAdd to tTextSize
   put space & space & "font-size:" && tTextSize & "px;" & LF after tCSS
   -- conclude css
   put "}" & LF & LF after tCSS
   -- end css for span tag
   -- finally return the result
   put tHTML into tResult["html"]
   put tCSS into tResult["css"]
   return tResult
end fExportCheckBox

-----------------------------------------------

function fExportField tControl_ID, tGrp, tGrpLoc, tIndent, aCSSprops
   -- uses function fIDname
   -- uses function fReturnCSSprops
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
      -- unlocked field for user input
      put the text of control id tControl_ID into tValue
      put space & "value=" & quote & tValue & quote after tHTML
   end if
   -- get and write any html event code
   get fReturnHtmlEvents(tControl_ID)
   put it after tHtml
   -- end first tag
   put ">" & LF after tHTML
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
      put tTempText after tHTML
   end if
   
   -- need </p> for tFieldType = "p" but no end of tag for <input> used in HTML
   if tFieldType is "p" then
      put LF & tIndent & "</" & tFieldType & ">" & LF after tHTML
   end if
   
   -- write css
   
   put "#" & fIDname(tControl_ID) && "{" & LF into tCSS
   put empty into tGrpLocList -- used in fReturnCSSprops for groups, this copy local to this function
   put fReturnCSSprops(tControl_ID, tGrpLoc, tGrpLocList, aCSSprops) after tCSS
   
   -- there are some special properties of "p" and "input" fields so search for the lines involved 
   
   if tFieldType is "p" then
      
      -- top location is special for "p" fields - need to shift to get same loc in LC card and web page
      -- do not use top from the topLeft of control here because it may be in a group
      -- group location taken care of in fReturnCSSprops above
      -- shift the adjusted top location written by fReturnCSSprops above
      put lineoffset("top:", tCSS) into tline
      if tline > 0 then
         put line tline of tCSS into tprop
         set the itemDelimiter to colon
         put item 2 of tprop into tvalue -- may have spaces and px;
         replace space with empty in tvalue
         replace "px;" with empty in tvalue
         subtract kFieldShift from tvalue
         put space & tvalue & "px;" into item 2 of tprop
         put tprop into line tline of tCSS
         set the itemDelimiter to comma
      end if
      
      -- set LC textSize as font-size for locked fields
      put the textSize of control id tControl_ID into tTextSize
      -- xxx at least in LC 9 (dp7) the textSize of fields is coming up empty 
      -- xxx even though property palette shows  default of 12 unless user purposely sets the value
      if tTextSize is empty then put 13 into tTextSize -- will get incremented below by kTextFontExportAdd
      add kTextFontExportAdd to tTextSize
      put lineoffset("font-size:", tCSS) into tline
      if tline > 0 then
         put space & space & "font-size:" && tTextSize & "px;" into line tline of tCSS
      else
         put space & space & "font-size:" && tTextSize & "px;" & LF after tCSS
      end if
      
      put the showBorder of control id tControl_ID into tShowBorder
      put the borderWidth of control id tControl_ID into tBorderWidth
      put the threeD of control id tControl_ID into tThreeD
      
      if tShowBorder is true then
         
         put lineoffset("border-style:", tCSS) into tline
         if tline > 0 then
            if tThreeD is true then
               -- was outset but looks solid on Win IE & Edge, use dotted instead
               put space & space & "border-style: dotted;" into line tline of tCSS
               put space & space & "border-color:" &&  kDottedBorderColor & ";" & LF after tCSS
            else
               -- was solid
               put space & space & "border-style: dotted;" into line tline of tCSS
               put space & space & "border-color:" &&  kDottedBorderColor & ";" & LF after tCSS
            end if
         else
            if tThreeD is true then
               -- was outset but looks solid on Win IE & Edge, use dotted instead
               put space & space & "border-style: dotted;" & LF after tCSS
               put space & space & "border-color:" &&  kDottedBorderColor & ";" & LF after tCSS
            else
               -- was solid
               put space & space & "border-style: dotted;" & LF after tCSS
               put space & space & "border-color:" &&  kDottedBorderColor & ";" & LF after tCSS
            end if
         end if
         
         put lineoffset("border-width:", tCSS) into tline
         if tline > 0 then
            put space & space & "border-width:" && tBorderWidth & "px;" into line tline of tCSS
         else
            put space & space & "border-width:" && tBorderWidth & "px;" & LF after tCSS
         end if
         
      end if -- end of if tShowBorder is true
      
   end if -- end of if tFieldType is "p" 
   
   if tFieldType is "input" then
      
      -- let unlocked input fields get default html font size
      put lineoffset("font-size:", tCSS) into tline
      if tline > 0 then
         delete line tline of tCSS
      end if
      -- set unlocked input fields with 1px solid borders
      put lineoffset("border-style:", tCSS) into tline
      if tline > 0 then
         -- delete line tline of tCSS -- for default style
         put "border-style: solid;" into line tline of tCSS
      end if
      put lineoffset("border-width", tCSS) into tline
      if tline > 0 then
         -- delete line tline of tCSS -- for default style
         put "border-width: 1px;" into line tline of tCSS
      end if
      
   end if -- end of if tFieldType is "input"
   
   -- conclude css
   put "}" & LF & LF after tCSS   
   -- end of css   
   
   -- finally return the result
   put tHTML into tResult["html"]
   put tCSS into tResult["css"]
   return tResult
end fExportField

-----------------------------------------------

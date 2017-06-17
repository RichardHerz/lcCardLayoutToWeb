script "lcCardLayoutToWeb-IMPORT"
/*
Design, text, images and code by Richard K. Herz, 2017 
Copyrights held by Richard K. Herz
https://github.com/RichardHerz
Licensed for use under the GNU General Public License v3.0 
https://www.gnu.org/licenses/gpl-3.0.en.html
*/

constant kKillWord = "lcCardLayoutToWeb" -- controls with this in name aren't written to html
-- make sure value of constant kKillWord is the same in both script files

constant kFieldShift = 16 -- was 16, subtract to shift locked fields when exporting <p> tags, add on import 
-- make sure value of constant kFieldShift is the same in both script files

constant kCssTopShift = 50 -- value used in css file for computed shift of elements
-- make sure value of constant kCssTopShift is the same in both script files

constant kTextFontExportAdd = 3 -- was 3, value to add to font size on export, subtract on import
-- make sure value of constant kTextFontExportAdd is the same in both script files 

-- use kReporter "true" to activate all reports below to msg box
-- or use a special value to activate only selected reports below
-- EXAMPLE:  if kReporter is "true" then put LF & tData after msg -- true displays all 
-- EXAMPLE:  if kReporter is "TEST" then put LF & tData after msg -- only displays some
constant kReporter = "false"

local oScrollbarList -- used to set the vScrollbar of groups

-----------------------------
/*
TAGS DONE -----------
div = group 
p = locked field 
img = image 
select = menu button
input with no type = unlocked field
input with type="button" = button
input with type="range" = scrollbar
label > input type="checkbox" > span = checkbox
label > input type="radio" > span = radio button (will be several inside one div/group)
canvas 
TAGS TO DO -----------
--
ALL TAGS TO HANDLE WILL HAVE id ATTRIBUTE 
search css for the id and parse to set properties of LC control
HANDLE OTHER ATTRIBUTES control by control
FORMATTING AND ANCHOR TAGS IN FIELDS
save to write out later in case LC htmlText can't handle
also set as the htmlText of the field in LC card
HOW TO HANDLE ONCLICK AND ONCHANGE ATTRIBUTES?
maybe set as custom props of the LC controls, then handle in save to web?
HOW TO HANDLE COMMENTS?
maybe save as custom prop of previous or next LC control, then handle in save to web?
or maybe each as custom prop of a button created for each in order handled, whose
names include save to web kill word? - can just put these in same place on card and pile them up...
*/

-----------------------------

on deleteNonDevControls
   -- this can be run before importing html and css data to make a new card layout
   -- if card has old controls on it
   answer "WARNING: DELETE ALL GROUPS AND CONTROLS OTHER THAN DEVELOPMENT CONTROLS?" with "yes" or "NO!"
   if it is "NO!" then exit to top
   repeat with tControlNumber = the number of controls down to 1
      if the short name of control tControlNumber contains kKillWord then
         -- skip these development controls
         next repeat
      end if
      delete control tControlNumber
   end repeat
end deleteNonDevControls
   
   -----------------------------
   
   on importWebPage
   
   -- calls function fMakeLiveCodeCard
   
   set the defaultStack to "lcCardLayoutToWeb"
   
   -- CHECK IF CARD HAS NO CONTROLS OTHER THAN DEVELOPMENT CONTROLS
   put "true" into tCleanOfControls
   repeat with tControlNumber = 1 to the number of controls
      if the short name of control tControlNumber contains kKillWord then
         -- skip these development controls
         next repeat
      end if
      put "false" into tCleanOfControls
   end repeat
   if tCleanOfControls is not "true" then
      answer "WARNING: DELETE ALL GROUPS AND CONTROLS OTHER THAN DEVELOPMENT CONTROLS"
      exit to top
   end if
   
   -- Note on LC syntax: "answer file" only allows one file to be selected
   -- "answer files" allows more than one file to be selected and returns paths on separate lines
   
   put empty into tHtmlFile
   
   answer file "select HTML file" with type "html|html|html"
   if the result is empty then
      put it into tHtmlFile
      if ".html" is in tHtmlFile then
         -- assume OK for now but check if at end
      else
         answer "This is not an html file"
         put empty into tHtmlFile
      end if -- end if ".html" is in tHtmlFile
   end if -- end if the result is empty
   
   if tHtmlFile is not empty then
      put empty into tCssFile
      answer file "select CSS file" with type "css|css|css"
      if the result is empty then
         put it into tCssFile
         if ".css" is in tCssFile then
            -- assume OK for now but check if at end
         else
            answer "This is not a CSS file"
            put empty into tCssFile
         end if -- end if ".css" is in tCssFile
      end if -- end if the result is empty
   end if -- end if tHtmlFile is not empty
   
   -- at this point should have tHtmlFile data
   -- and may have tCssFile data if there is a css file
   -- NOTE there may be a style tag(s) inside html data!
   
   if tHmtlFile is not empty then
      put "file:" before tHtmlFile
      put url tHtmlFile into tHtmlFileData
   else
      exit to top
   end if
   
   if tCssFile is not empty then
      put "file:" before tCssFile
      put url tCssFile into tCssFileData
   else
      exit to top
   end if
   
   get fMakeLiveCodeCard(tHtmlFileData, tCssFileData) 
   
   select empty
   
   beep
   
end importWebPage

-----------------------------

function fMakeLiveCodeCard pHtmlFileData, pCssFileData
   
   -- uses constant kKillWord
   -- is called by command importWebPage
   
   put empty into tGrpList
   put empty into tGrpLocList
   put empty into oScrollbarList
   
   -- get all data above <body>
   
   put offset("<body>",pHtmlFileData) into tBodyStartChar
   put char 1 to tBodyStartChar-1 of pHtmlFileData into tHeaderData
   set the cHeaderData of this card to tHeaderData
   
   -- MUST USE MESSAGE BOX FOR DEVELOPMENT RECORD - NOT FIELD
   -- BECAUSE CAN'T ACCESS FIELD WHEN EDITING A GROUP easily at least
   -- do not always put empty into msg here because will open msg box even if not used
   if kReporter is not "false" then put empty into msg 
   if kReporter is "true" then put LF & tHeaderData into msg -- NOTE "INTO" FOR FIRST ONE
   
   put tBodyStartChar into tSkipChar
   add 5 to tSkipChar -- set to end > of <body>
   put empty into tCommentList
   
   repeat
      put offset("<",pHtmlFileData,tSkipChar) into tNextTagStart
      if tNextTagStart is 0 then exit repeat
      add tNextTagStart to tSkipChar
      put tSkipChar into tNextTagStart
      -- save comments in body which are outside of other tags
      if offset("!--",pHtmlFileData,tSkipChar) = 1 then 
         -- tSkipChar points to < of <!-- comment
         if kReporter is "true" then put LF & "comment found" & LF after msg
         -- want to skip to end comment in case have commented out some controls
         put offset("-->",pHtmlFileData,tSkipChar) into tEndComment
         add 2 to tEndComment -- include -> of -->
         add tEndComment to tSkipChar
         put tSkipChar into tEndComment
         put char tNextTagStart to tEndComment of pHtmlFileData into tComment
         if tComment contains "end of div div_" then
            -- export writes end of div comments like this: <!-- end of div div_EMPTY_group_1017 -->
            -- do not save these
         else
            put tComment & LF after tCommentList
            -- tCommentList will be saved at end fMakeLiveCodeCard
            -- can not access header button when editing a group
            -- these are comments in body which are outside of non-div tags
         end if
         next repeat
         /*
         -- xxx need to save comments somewhere
         -- can't directly add them to header button when editing a group
         -- for now, add to a variable and then handle at end of this function
         -- what about adding as a cComment custom prop to last control added
         -- to card, checked by highest control number (problems if editing group?), then 
         -- on export write to html file after that control is written to the html file...
         -- but need to not duplicate comments already added on export, e.g., at end div's
         -- will still have problems with any comment inside a tag
         */
      end if
      if offset("/div>",pHtmlFileData,tSkipChar) = 1 then 
         -- tSkipChar points to < of </div>
         if kReporter is "true" then put LF & "JUST BEFORE get fImportGroupEnd, tGrpList = " & "---||" & tGrpList & "||---" & LF after msg
         if kReporter is "true" then put LF & "JUST BEFORE get fImportGroupEnd, tGrpLocList = " & "---||" & tGrpLocList & "||---" & LF after msg
         get fImportGroupEnd(tSkipChar, tGrpList, tGrpLocList)
         put it into tResult
         put tResult["SkipChar"] into tSkipChar
         put tResult["GrpList"] into tGrpList
         put tResult["GrpLocList"] into tGrpLocList
         if kReporter is "true" then put LF & "JUST AFTER get fImportGroupEnd, tGrpList = " & "---||" & tGrpList & "||---" & LF after msg
         if kReporter is "true" then put LF & "JUST AFTER get fImportGroupEnd, tGrpLocList = " & "---||" & tGrpLocList & "||---" & LF after msg
         next repeat
      end if
      if offset("/",pHtmlFileData,tSkipChar) = 1 then 
         -- tSkipChar points to < of </tag
         -- these are usually handled in tag functions but get for </body> and </html>
         add 1 to tSkipChar -- get off this
         next repeat
      end if
      put offset(space,pHtmlFileData,tSkipChar) into tNextSpaceChar
      -- but could be <tag> and space down the line...
      -- make sure it's not past end this tag
      put offset(">",pHtmlFileData,tSkipChar) into tNextEndChar
      if tNextEndChar < tNextSpaceChar then
         -- not a tag with an attribute such as type or id
         if kReporter is "true" then 
            put LF & "tNextEndChar < tNextSpaceChar so not a tag with attribute such as type or id" & LF after msg
         end if
      else
         add tSkipChar to tNextSpaceChar
         put char tNextTagStart + 1 to tNextSpaceChar - 1 of pHtmlFileData into tTagName
         if kReporter is "true" then 
            put LF & "before switch in makeLiveCodeCard, tTagName = " & tTagName & LF after msg
         end if
         switch tTagName
            case "div"
               -- import div = group
               if kReporter is "true" then put LF & "JUST BEFORE get fImportGroupStart, tGrpList = " & "---||" & tGrpList & "||---" & LF after msg
               if kReporter is "true" then put LF & "JUST BEFORE get fImportGroupStart, tGrpLocList = " & "---||" & tGrpLocList & "||---" & LF after msg
               get fImportGroupStart(tSkipChar, pHtmlFileData, pCssFileData, tGrpList, tGrpLocList)
               put it into tResult
               put tResult["SkipChar"] into tSkipChar
               put tResult["GrpList"] into tGrpList
               put tResult["GrpLocList"] into tGrpLocList
               if kReporter is "true" then put LF & "JUST AFTER get fImportGroupStart, tGrpList = " & "---||" & tGrpList & "||---" & LF after msg
               if kReporter is "true" then put LF & "JUST AFTER get fImportGroupStart, tGrpLocList = " & "---||" & tGrpLocList & "||---" & LF after msg
               break
            case "p"
               -- import p = locked field
               put fImportLockedField(tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList) into tSkipChar
               break
            case "img"
               -- import img = image
               put fImportImage(tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList) into tSkipChar
               break
            case "select"
               -- import select = menu button
               put fImportMenuButton(tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList) into tSkipChar
               break
            case "input"
               -- import input that are not inside <label tags
               -- 3 types: none = unlocked field, button = button, range = slider
               put fImportInputTag(tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList) into tSkipChar
               break
            case "label"
               -- import label
               -- need to look for <input inside
               -- two input types: checkbox, radio button
               -- <label <input followed by <span
               put fImportLabelTag(tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList) into tSkipChar
               break
            case "canvas"
               put fImportCANVAS(tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList) into tSkipChar
               break
            default
               --  ignore for now
         end switch
      end if
   end repeat
   
   -- save comment list, if any
   if tCommentList is empty then
      -- no comments found in body outside of non-div tags, other than end of div
   else
      put "<!-- *** START COLLECTION OF COMMENTS IN BODY OUTSIDE NON-DIV TAGS *** -->" & LF before tCommentList
      put "<!-- *** END COLLECTION OF COMMENTS IN BODY OUTSIDE NON-DIV TAGS *** -->" & LF after tCommentList
      put the cHeaderData of this card into tHeaderData
      put LF & tCommentList after tHeaderData
      set the cHeaderData of this card to tHeaderData
   end if
   
   -- xxx for unknown reason, at least in LC 9(dp6), setting the vScrollbar property of a group
   -- xxx in fGetSetControlProps changed in some unknown way the left value
   -- xxx that was set in the topLeft of one of the groups inside the group with the vScrollbar
   -- xxx saving the vScrollbar property value in fGetSetControlProps and then setting it now works
   if tScrollerList is not empty then
      set the itemDelimiter to "$" -- need delimiter that does not appear in a file name
      repeat for each line tLine in oScrollbarList
         put item 1 of tLine into tControlName
         put item 2 of tLine into tValue
         set the vScrollbar of tControlName to tValue
      end repeat
      set the itemDelimiter to comma
   end if
   
end fMakeLiveCodeCard

----------------------------- 

function fImportCANVAS tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList
   -- this is to import an LC button that represents the area of an HTML CANVAS element
   -- used for generating images on HTML canvas by Javascript
   -- need to return updated tSkipChar
   -- EXAMPLE: <canvas id="canvas_CANVAS_rate"></canvas> 
   
   -- GET CONTROL ID
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "id") into tID
   
   -- tID used below in GET CSS
   put tID into tCanvas
   replace "_" with space in tCanvas
   -- prefix "canvas" added in export, others added later might not have it
   if word 1 of tCanvas is "canvas" then delete word 1 of tCanvas
   -- USE "CANVAS" as first word of short name of LC button to identify an html canvas element
   if word 1 of tCanvas is not "CANVAS" then put "CANVAS" and space before tCanvas
   
   -- CREATE BUTTON TO REPRESENT HTML CANVAS
   create button
   set the name of it to tCanvas
   -- below are special properties for the button
   set the style of button tCanvas to rectangle
   set the showBorder of button tCanvas to true
   set the borderWidth of button tCanvas to 2
   set the backColor of button tCanvas to 0,255,0
     
   -- GET CSS & SET CONTROL PROPERTIES
   
   put the long name of button tCanvas into tControlLongName -- NOTE button tCanvas
   get fGetSetControlProps(tID, tControlLongName, pCssFileData, tGrpLocList)
   
   -- update tSkipChar before returning
   put offset("</canvas>",pHtmlFileData,tSkipChar) into tEndChar
   add tEndChar to tSkipChar
   put offset(">",pHtmlFileData,tSkipChar) into tEndChar
   add tEndChar to tSkipChar
   return tSkipChar
end fImportCANVAS

----------------------------- 

function fImportLabelTag tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList
   if kReporter is "true" then put LF & "enter fImportLabelTag" & LF after msg
   -- tSkipChar points to < of <label
   -- need to return updated tSkipChar
   -- THERE ARE TWO TYPES
   -- need to look for <input inside of <label and </label>
   -- two input types: checkbox, radio button
   -- <label followed by <input followed by <span
   -- EXAMPLE OF CHECKBOX
   --    <label id="checkbox_Check1_1046_LABEL">
   --      <input type="checkbox" id="checkbox_Check1_1046">
   --      <span id="checkbox_Check1_1046_SPAN">Check1</span>
   --    </label>
   -- EXAMPLE OF RADIO BUTTONS - ALL INSIDE A DIV HANDLED BY fImportGroupStart and ...End
   -- HERE JUST IMPORT ONE OF THE RADIO BUTTONS -- THAT IS, ONE LABEL TAG
   --    <label id="radio_Radio2_1043_LABEL" name="radio_of_group_RADIO_group">
   --       <input type="radio" id="radio_Radio2_1043" name="radio_of_group_RADIO_group">
   --       <span id="radio_Radio2_1043_SPAN">Radio2</span>
   --    </label>
   --    <label id="radio_Radio1_1044_LABEL" name="radio_of_group_RADIO_group">
   --       <input type="radio" id="radio_Radio1_1044" name="radio_of_group_RADIO_group" checked>
   --       <span id="radio_Radio1_1044_SPAN">Radio1</span>
   --    </label>
   put offset("</label>",pHtmlFileData,tSkipChar) into tEndChar
   put offset("type=",pHtmlFileData,tSkipChar) into tTypeChar
   put empty into tType
   if (tTypeChar < tEndChar) then
      add tSkipChar to tTypeChar
      add 6 to tTypeChar -- just inside " of type="
      put offset(quote,pHtmlFileData,tTypeChar) into tQuoteChar
      subtract 1 from tQuoteChar
      add tTypeChar to tQuoteChar
      put char tTypeChar to tQuoteChar of pHtmlFileData into tType
   end if
   
   -- radiobutton is LC button style property for radio buttons
   if tType is "radio" then put "radiobutton" into tType 
   
   get fImportCheckOrRadioButton(tSkipChar, tType, pHtmlFileData, pCssFileData, tGrpLocList)
   
   if kReporter is "true" then put LF & "exit fImportLabelTag" & LF after msg
   
   -- update tSkipChar here before returning
   put offset("</label>",pHtmlFileData,tSkipChar) into tEndChar
   add tEndChar to tSkipChar
   put offset(">",pHtmlFileData,tSkipChar) into tEndChar
   add tEndChar to tSkipChar
   return tSkipChar
end fImportLabelTag

-----------------------------  

function fGetHtmlAttribute tSkipChar, pFileData, pTargetName
   -- ASSUMES no spaces outside of quotes in, e.g., pTargetName="target value"
   -- ASSUMES tSkipChar points to < of <parentTag
   
   -- previously had trouble for this:  target=""
   -- so revised original script to a more complex script below
   
   -- get end of parent tag to make sure this attribute inside this tag
   put offset(">", pFileData, tSkipChar) into tTagEndChar
   add tSkipChar to tTagEndChar
   -- search below only in this tag
   put char tSkipChar to tTagEndChar of pFileData into tTagData
   
   if kReporter is "TEST" then put LF & "fGetHtmlAttribute, pTargetName = " & pTargetName after msg -- development field
   
   if kReporter is "TEST" then put LF & "fGetHtmlAttribute, tTagData = " & tTagData after msg -- development field
   
   -- ASSUME no space between pTargetName and ="
   put offset(pTargetName & "=" & quote, tTagData) into tTargetStartChar
   if tTargetStartChar = 0 then
      put empty into tTargetValue
      if kReporter is "TEST" then 
         put LF & "fGetHtmlAttribute, tTargetStartChar = 0" after msg -- development field
      end if
   else
      put the number of chars of pTargetName into tNum
      add 2 to tNum -- + 2 to step inside ="
      add tNum to tTargetStartChar -- move inside first quote
      put offset(quote, tTagData, tTargetStartChar) into tTargetEndChar
      if tTargetEndChar = 0 then
         if kReporter is "TEST" then 
            put LF & "fGetHtmlAttribute, tTargetEndChar = 0" after msg -- development field
         end if
         -- can get this for target="" looking from inside first quote
         put empty into tTargetValue
      else
         subtract 1 from tTargetEndChar -- step back before second quote
         add tTargetStartChar to tTargetEndChar
         put char tTargetStartChar to tTargetEndChar of tTagData into tTargetValue 
      end if
   end if
   
   if kReporter is "TEST" then put LF & "fGetHtmlAttribute, tTargetValue to RETURN = " & tTargetValue & LF after msg -- development field
   
   return tTargetValue
end fGetHtmlAttribute

-----------------------------

function fGetReporter tSkipChar, pHtmlFileData
   put char tSkipChar-20 to tSkipChar+20 of pHtmlFileData into tReport
   -- replace <> because some LC answer and text editors treat as HTML and/or colorize
   replace "<" with "*" in tReport -- use one char so don't throw off count in report text
   replace ">" with "*" in tReport -- use one char so don't throw off count in report text
   put LF & "+/- 20 of (tSkipChar = " & tSkipChar & ") is: " after msg
   put LF & "---||" & tReport & "||---" & LF after msg
end fGetReporter

----------------------------- 

function fGetStripOuterSpace tText
   -- used to strip junk from both ends of text in <p> tag
   -- need to use compound conditions because can be in any order, e.g., space LF tab space
   repeat while char 1 of tText is space OR char 1 of tText is LF OR char 1 of tText is tab
      delete char 1 of tText
   end repeat
   repeat while the last char of tText is space OR the last char of tText is LF OR the last char of tText is tab
      delete the last char of tText
   end repeat
   return tText
end fGetStripOuterSpace

-----------------------------

function fGetSetControlProps pID, pControlLongName, pCssFileData, tGrpLocList, pSpanFlag
   
   -- returns true if css has a transform property
   -- which will be the case for vertical sliders (scales, ranges)
   
   -- xxx problems if "#" & tID mentioned in a comment in CSS file
   
   put offset(space & "of",pControlLongName) into tMarkChar
   put char 1 to tMarkChar-1 of pControlLongName into tControlName
   -- tControlName is first words of long name of control before first "of"
   -- for example, tControlName = button "radio 2"
   -- the long name does not work, at least when control is inside a group
   
   if kReporter is "true" then put LF & LF & "enter function fGetSetControlProps, tControlName = " & LF & tControlName & LF after msg
   if kReporter is "true" then put LF & LF & "enter function fGetSetControlProps, pID = " & LF & pID & LF after msg
   
   put empty into tCssData
   if pCssFileData is not empty then
      
      -- check complete CSS line matches because, e.g., 
      -- may have "button_1" 1st in file and "button" 2nd in file
      -- and don't want to find "button_1" with simple search for "button"
      
      put 0 into tLineSkip
      repeat
         put lineoffset("#" & pID, pCssFileData, tLineSkip) into tLineNum
         if tLineNum = 0 then exit repeat
         add tLineNum to tLineSkip
         put tLineSkip into tLineNum
         put line tLineNum of pCssFileData into tLineDataOrig
         put tLineDataOrig into tLineDataStripped
         replace space with empty in tLineDataStripped
         replace "{" with empty in tLineDataStripped
         replace "#" with empty in tLineDataStripped
         replace LF with empty in tLineDataStripped
         if tLineDataStripped = pID then
            -- got a hit, need char offset
            put offset(tLineDataOrig, pCssFileData) into tStartChar
            exit repeat
         end if
      end repeat
      
      put offset("}",pCssFileData,tStartChar) into tEndChar
      add tStartChar to tEndChar
      put char tStartChar to tEndChar of pCssFileData into tCssData
      
      if kReporter is "true" then 
         put LF & tCssData & LF after msg
      end if
      
   end if
   
   put 0,0 into tTopLeft
   put "false" into tTransformFlag
   
   if tCssData is not empty then
      -- assume top and bottom lines don't have data but the other lines do
      
      set the itemDelimiter to colon
      
      repeat for each line n in tCssData
         if n contains "#" then next repeat
         if n contains "}" then exit repeat
         put word 1 of item 1 of n into tProp -- so don't get spaces
         put item 2 of n into tValue
         put fGetStripOuterSpace(tValue) into tValue
         
         -- watch out for a calc(), which I've used in earlier development for quick fix
         -- EXAMPLE:    :root {--shift: 50px;}
         -- USED IN ELEMENT PROP:   top: calc(var(--shift) + 700px);
         if tValue contains "calc" then
            put offset("+",tValue) into tPlusChar -- assume a space after plus
            put offset("px",tValue) into tPXChar
            put char tPlusChar + 2 to tPXChar -1 of tValue into tValue
            -- see top of this file for constant value
            add kCssTopShift to tValue
         else
            -- NEED TO DO THIS IF THERE IS NO CALC
            delete the last char of tValue -- delete ;
            replace "px" with empty in tValue -- if any, delete px
         end if
         
         -- only want to set font-size/textSize in  _SPAN for radio buttons and checkboxes
         if pSpanFlag is "true" then
            if tProp is not "font-size" then 
               next repeat
            end if
         end if
         
         switch tProp
            case "width"
               put tValue into tWidth
               break
            case "height"
               put tValue into tHeight
               break
            case "left"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tValue into item 1 of tTopLeft -- save, don't set topLeft yet
               -- save, need to add container group left & setting height & width changes topLeft
               set the itemDelimiter to colon
               break
            case "top"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tValue into item 2 of tTopLeft -- save, don't set topLeft yet
               -- save, need to add container group left & setting height & width first changes topLeft
               set the itemDelimiter to colon
               break
            case "font-size"
               subtract kTextFontExportAdd from tValue -- xxx better check if this is <p>
               set the textSize of tControlName to tValue
               break
            case "text-align"
               set the textAlign of tControlName to tValue
               break
            case "opacity"
               put 100*(1 - tValue) into ttemp
               set the blendLevel of tControlName to ttemp
               if tValue > 0 then
                  set the opaque of tControlName to true
               end if
               break
            case "visibility"
               -- EXAMPLE:  visibility: visible; 
               if kReporter is "true" then put LF & "VISIBILITY tValue = " & tValue & LF after msg
               if tValue is "hidden" then 
                  set the visible of tControlName to false
               else
                  set the visible of tControlName to true
               end if
               break
            case "border-style"
               -- css border styles include: none, hidden, dotted, dashed, solid, double, groove, ridge, inset, outset
               -- EXPORT has a checkbox to add CSS dotted when LC showBorder false
               -- EXPORT otherwise saves LC showBorder true as css outset
               if tValue is "none" or tValue is "hidden" or tValue is "dotted" then
                  set the showBorder of tControlName to false
               else
                  set the showBorder of tControlName to true
               end if
               if tValue is "solid" then
                  set the threeD of tControlName to false
               end if
               break
            case "border-width"
               set the borderWidth of tControlName to tValue
               break
            case "background-color"
               -- EXAMPLE:  background-color: rgb(102,255,255);
               replace "rgb(" with empty in tValue
               delete the last char of tValue -- delete ) where ; already deleted from tValue
               set the backColor of tControlName to tValue
               break
            case "transform"
               -- used when rotate horizontal range to vertical in CSS
               if kReporter is "true" then put LF & "SCROLLBAR TRANSFORM DETECTED" after msg
               put "true" into tTransformFlag
               if kReporter is "true" then put LF & "in case transform, tTransformFlag = " & tTransformFlag after msg
               break
            case "LCvScrollbar"
               -- this is for vScrollbar property of scrolling groups, not for scrollbar controls
               -- special property added on export - not a standard CSS property
               -- usually used for scrolling parent groups used in making long web pages
               -- xxx for unknown reason, at least in LC 9(dp6), setting the vScrollbar property of a group
               -- xxx in fGetSetControlProps changed in some unknown way the left value
               -- xxx that was set in the topLeft of one of the groups inside the group with the vScrollbar
               -- xxx saving the vScrollbar property value in fGetSetControlProps and then
               -- xxx setting at the end of fMakeLiveCodeCard works
               put tControlName & "$" & tValue & LF after oScrollbarList  -- need delimiter that does not appear in a file name
               -- xxx set the vScrollbar of tControlName to tValue
               break
         end switch
      end repeat
   end if
   
   -- only want to set font-size/textSize in  _SPAN for radio buttons and checkboxes
   if pSpanFlag is "true" then exit fGetSetControlProps
   
   set the itemDelimiter to comma
   
   if kReporter is "true" then put LF & "---||" & tGrpLocList & "||---" after msg
   
   if tGrpLocList is not empty then
      put the last line of tGrpLocList into tLast
      if kReporter is "true" then 
         put LF & "tLast = last line of tGrpLocList = " & tLast after msg
      end if
      add item 1 of tLast to item 1 of tTopLeft
      add item 2 of tLast to item 2 of tTopLeft
   end if
   
   if tTransformFlag is "true" then
      -- CSS/HTML range started out as horiz then transformed by rotation 90 deg about center
      if kReporter is "true" then 
         put LF & "in IF swapping width and height, tTransformFlag is true" after msg
      end if
      -- swap width and height
      put tWidth into tOldWidth
      put tHeight into tOldHeight
      put tOldWidth into tHeight
      put tOldHeight into tWidth
      -- modify topLeft for rotation about center
      put item 1 of tTopLeft into tOldLeft
      put item 2 of tTopLeft into tOldTop
      put tOldLeft + tOldWidth/2 - tOldHeight/4 into item 1 of tTopLeft
      put tOldTop + tOldHeight/2 - tOldWidth/2 into item 2 of tTopLeft
   end if
   
   if kReporter is "true" then put LF & "JUST BEFORE set the width of tControlName to tWidth" after msg
   if kReporter is "true" then put LF & "tControlName = " & tControlName && ";" && "tWidth = " & tWidth after msg
   if kReporter is "true" then put LF & "JUST BEFORE set the height of tControlName to tHeight = " & tHeight after msg
   if kReporter is "true" then put LF & "tControlName = " & tControlName && ";" && "tHeight = " & tHeight after msg
   
   -- _LABEL in CSS for checkbox and radio buttons may not have width and height values
   if tWidth > 0 then set the width of tControlName to tWidth
   if tHeight > 0 then set the height of tControlName to tHeight
   
   -- set topLeft AFTER set width and height
   
   if kReporter is "true" then put LF & "JUST BEFORE set the topLeft of tControlName to tTopLeft" after msg
   if kReporter is "true" then put LF & "tControlName = " & tControlName && ";" && "tTopLeft = " & tTopLeft after msg
   
   set the topLeft of tControlName to tTopLeft
   
   if kReporter is "true" then put LF & "JUST AFTER set the topLeft of tControlName to tTopLeft" after msg
   if kReporter is "true" then put LF & "tControlName = " & tControlName && ";" && "topLeft = " & the topLeft of tControlName after msg
   
   if kReporter is "true" then put LF & "just before end fGetSetControlProps, return tTransformFlag = " & tTransformFlag after msg
   return tTransformFlag
end fGetSetControlProps

-----------------------------  

function fImportCheckOrRadioButton tSkipChar, pStyle, pHtmlFileData, pCssFileData, tGrpLocList
   if kReporter is "true" then put LF & "enter fImportCheckOrRadioButton" & LF after msg
   -- fImportCheckOrRadioButton is called by fImportLabelTag
   -- tSkipChar points to < of <label inside which the button is contained
   -- pStyle is "radiobutton" or "checkbox" ***** NOTE pStyle AND NOT tStyle HERE in case merge functions *******
   -- EXAMPLE OF CHECKBOX
   --    <label id="checkbox_Check1_1046_LABEL">
   --      <input type="checkbox" id="checkbox_Check1_1046">
   --      <span id="checkbox_Check1_1046_SPAN">Check1</span>
   --    </label>
   -- EXPORT only writes CSS for <label and <span, not <input
   -- but modified HTML may have a checked attribute in <input when
   -- when the hilite of the LC checkbox is true
   -- and also will have an onchange in <input so need to save to custom prop and
   -- add on export   
   -- on export, the short name of the LC control is written to the <span
   -- xxx or should it use the LC label?
   
   -- GET CONTROL ID
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "id") into tID
   
   -- ASSUME id of label has _LABEL after same id as input
   -- ASSUME id of span has _SPAN after same id as input
   
   put tID into tID_LABEL
   put tID into tIDname
   replace "_" with space in tIDname   
   delete the last word of tIDname -- delete _LABEL
   put tIDname into tID_SPAN
   put space & "SPAN" after tID_SPAN
   replace space with "_" in tID_SPAN
   
   delete the first word of tIDname -- delete the type (checkbox or radio) 
   put tIDname into tButton -- use this as short name of the button, label set by span tag
   
   -- NOW HAVE: tID_LABEL, tIDname, tID_SPAN
   -- UNDER ASSUMED NAMING CONVENTION
   
   -- GET WHETHER OR NOT INPUT HAS CHECKED ATTRIBUTE
   -- AND SAVE AS CUSTOM PROP OF LC CONTROL
   -- NOTE CHECKED ATTRIBUTE IS IN INPUT UNDER THIS LABEL: <LABEL <INPUT
   put offset("<input",pHtmlFileData,tSkipChar) into tInputTagStart 
   add tSkipChar to tInputTagStart
   put offset(">",pHtmlFileData,tInputTagStart) into tInputTagEnd
   -- do NOT add tSkipChar to tInputTagEnd because check for tCheckedChar > 0
   put offset(space & "checked",pHtmlFileData,tInputTagStart) into tCheckedChar -- no space at end in case checked>
   if tCheckedChar > 0 and tCheckedChar < tInputTagEnd then 
      put "true" into tCheckedFlag
   else
      put "false" into tCheckedFlag
   end if
   -- BELOW, set the hilited of the control to tCheckedFlag
   
   -- GET WHETHER OR NOT INPUT HAS ONCHANGE ATTRIBUTE
   -- AND SAVE AS CUSTOM PROP OF LC CONTROL
   -- NOTE ONCHANGE ATTRIBUTE IS IN INPUT UNDER THIS LABEL: <LABEL <INPUT
   put offset("<input",pHtmlFileData,tSkipChar) into tInputTagStart 
   add tSkipChar to tInputTagStart
   put fGetHtmlAttribute(tInputTagStart, pHtmlFileData, "onchange") into tOnchange 
   
   -- GET TEXT BETWEEN <span AND </span>
   -- AND SET AS LABEL OF THE LC CONTROL
   -- ASSUME THERE IS A SPAN TAG WITH TEXT INSIDE LABEL TAG
   put offset("<span",pHtmlFileData,tSkipChar) into tSpanTagStart
   add tSkipChar to tSpanTagStart
   put offset(">",pHtmlFileData,tSpanTagStart) into tSpanTagTemp
   add tSpanTagTemp to tSpanTagStart
   put offset("</span>",pHtmlFileData,tSkipChar) into tSpanTagEnd
   add tSkipChar to tSpanTagEnd
   add 1 to tSpanTagStart
   subtract 1 from tSpanTagEnd
   put char tSpanTagStart to tSpanTagEnd of pHtmlFileData into tButtonLabel -- tButton used below in CSS
   -- BELOW set the label of the LC control to tButtonLabel
   
   -- CREATE LC CONTROL
   create button
   set the name of it to tButton
   set the label of button tButton to tButtonLabel
   set the style of button tButton to pStyle -- pStyle is input argument to this function
   -- was getting the hiliteBorder set to true when export original had it false,
   -- causes border to show when selected, property in icons panel of LC control properties 
   set the hiliteBorder of button tButton to false 
   if tOnchange is not empty then
      set the cOnchange of button tButton to tOnchange
   end if
   set the hilited of button tButton to tCheckedFlag
   
   -- GET CSS & SET CONTROL PROPERTIES
   
   -- THIS IS DIFFERENT BECAUSE CSS HAS tID_LABEL &  tID_SPAN
   -- CSS for tID_LABEL has left and top for LC topLeft (left,top)
   -- CSS for tID_SPAN has info for text label
   -- EXAMPLE
   --    #checkbox_Check1_1046_LABEL {
   --    left: 180px;
   --    top: 113px;
   --    }
   
   --    #checkbox_Check1_1046_SPAN {
   --     margin-left: 22px;
   --     line-height: 18px;
   --     font-size: 15px;
   --    }
   
   -- FOR NOW, ONLY GET _LABEL FOR BUTTON LOCATION
   
   put the long name of button tButton into tControlLongName -- NOTE button tButton   
   get fGetSetControlProps(tID_LABEL, tControlLongName, pCssFileData, tGrpLocList) -- NOTE tID_LABEL
   
   -- BUT _SPAN HAS FONT SIZE SO USE SPECIAL FLAG TO CHECK AND SET IT
   put "true" into pSpanFlag
   get fGetSetControlProps(tID_SPAN, tControlLongName, pCssFileData, tGrpLocList, pSpanFlag) -- NOTE tID_SPAN
   
   if kReporter is "true" then put LF & "exit fImportCheckOrRadioButton" & LF after msg
   -- do not return tSkipChar here
end fImportCheckOrRadioButton

----------------------------- 

-- VARIABLES USED IN *EXPORT* OF GROUPS
-- tGrpList 
-- tGrpCurrent 
-- tGrpLocList =  list of left,top coordinates of active groups
-- tFlagEndGrp
--
-- in tGrpList, groups without given names. e.g., = of group id 3333 
-- in tGrpList, groups with a given name, e.g., = of group "myGroup" 
-- div id's will have id number at end in both cases

function fImportGroupStart tSkipChar, pHtmlFileData, pCssFileData, tGrpList, tGrpLocList
   if kReporter is "true" then put LF & "enter fImportGroupStart" & LF after msg
   -- <div> = group
   -- tSkipChar points to < of <div
   -- need to return updated tSkipChar
   -- need to return updated tGrpList and tGrpLocList
   
   if kReporter is "true" then get fGetReporter(tSkipChar, pHtmlFileData) -- development
   
   -- THIS NEEDS TO
   --   input list of groups and group topLefts
   --   add to these lists
   --   create a new empty group if possible
   --   return the updated list of groups and group topLefts
   
   -- GET CONTROL ID
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "id") into tID
   
   -- tID example:  div_simulation_frame
   put tID into tGroup -- will use both tID and tGroup below
   replace "_" with space in tGroup
   -- "div" added in export, others added later might not have it
   if word 1 of tGroup is "div" then delete word 1 of tGroup -- delete div
   
   -- UPDATE tGrpList
   put the number of lines of tGrpList into tLines
   add 1 to tLines
   put tGroup into line tLines of tGrpList
   
   if kReporter is "true" then put LF & "JUST BEFORE create group " & tIDname after msg
   create group
   set the name of it to tGroup
   if kReporter is "true" then put LF & "JUST AFTER create group " & tGroup after msg
   
   -- GET CSS & SET CONTROL PROPERTIES
   
   put the long name of group tGroup into tControlLongName -- NOTE group tGroup
   get fGetSetControlProps(tID, tControlLongName, pCssFileData, tGrpLocList)
   
   -- UPDATE tGrpLocList
   put the number of lines of tGrpLocList into tLines
   add 1 to tLines
   put the topLeft of group tGroup into line tLines of tGrpLocList
   
   set the lockLoc of group tGroup to true -- otherwise will "shrink to fit" contents, which are none at this point
   
   -- set the showBorder of group tGroup to true -- xxx so can see it in development
   -- xxx setting showBorder here for all to true will cause difference in css when export > import > export
   
   if kReporter is "true" then put LF & "JUST BEFORE start editing group" && tGroup after msg
   
   start editing group tGroup
   
   if kReporter is "true" then put LF & "JUST AFTER start editing group" && tGroup & LF after msg
   
   -- RETURN RESULTS
   put tSkipChar into tResult["SkipChar"]
   put tGrpList into tResult["GrpList"]
   put tGrpLocList into tResult["GrpLocList"]
   return tResult
end fImportGroupStart

-----------------------------

function fImportGroupEnd tSkipChar, tGrpList, tGrpLocList
   if kReporter is "true" then put LF & "enter fImportGroupEnd" & LF after msg
   -- input argument tSkipChar points to < of </div>
   -- need to return updated tSkipChar
   -- char which can occur after </div> is space or < or LF
   
   -- THIS NEEDS TO
   --   input list of groups and group topLefts
   --   delete last group from these lists
   --   return the updated list of groups and group topLefts
   
   --  xxx  -- get rid of any empty lines due to LF at end
   --    if the last line of tGrpList is empty then delete the last line of tGrpList -- in case of LF and empty line
   --    if the last line of tGrpLocList is empty then delete the last line of tGrpLocList -- in case of LF and empty line
   
   -- get name of the last group
   put the last line of tGrpList into tGrpName
   
   if kReporter is "true" then put LF & "Before delete last line, tGrpName = " & tGrpName after msg
   
   if kReporter is "true" then put LF & "Before delete last line, tGrpList = " & LF & tGrpList after msg
   
   if kReporter is "true" then put LF & "Before delete last line, tGrpLocList = " & LF & tGrpLocList after msg
   
   -- UPDATE GROUP LIST AND GROUP LOC LIST
      
   delete the last line of tGrpList
   delete the last line of tGrpLocList
    
   -- I found, at least with LC 9 (dp6), that I had to use background and not group in this next line
   if kReporter is "true" then put LF & "JUST BEFORE STOP EDITING, the name of this background = " & the name of this background & LF after msg
     
   stop editing -- stop editing current group just has same effect as stop editing all
   
   if kReporter is "true" then put LF & "JUST AFTER stop editing" & LF after msg
      
   -- if this group was nested inside a parent group, then go back to editing that parent group
   -- this has been tested for groups nested 3 deep: grandparent > parent > child
   if tGrpList is not empty then 
      put the last line of tGrpList into tGrpName
      start editing group tGrpName
      if kReporter is "true" then 
         put LF & "start editing group" && tGrpName & LF after msg
      end if
   end if
   
   -- get tSkipChar off this </div>
   add 1 to tSkipChar
   
   if kReporter is "true" then put LF & "return tSkipChar = " & tSkipChar after msg
   if kReporter is "true" then put LF & "just before end fImportGroupEnd" & LF after msg
   
   -- RETURN RESULT
   put tSkipChar into tResult["SkipChar"]
   put tGrpList into tResult["GrpList"]
   put tGrpLocList into tResult["GrpLocList"]
   return tResult
end fImportGroupEnd

-----------------------------

function fImportMenuButton tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList
   if kReporter is "true" then put LF & "enter fImportMenuButton" & LF after msg
   -- tSkipChar points to < of <select
   -- need to return updated tSkipChar
   
   --    EXAMPLE: 
   --    <select id="select_Option_Menu_1105" value="Choice 2">
   --       <option value="Choice 1">Choice 1</option>
   --       <option value="Choice 2">Choice 2</option>
   --       <option value="Choice 3">Choice 3</option>
   --    </select>
   
   -- LC menu buttons are buttons with property style set to menu
   -- there is also a menuMode property for menu buttons: option, pulldown, and others
   -- see LC docs
   -- will have to do some work on both EXPORT script and this IMPORT script
   
   -- GET CONTROL ID
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "id") into tID
   
   put tID into tButton -- will use both tID and tButton below
   replace "_" with space in tButton
   -- "select" added in export, others added later might not have it
   if word 1 of tButton is "select" then delete word 1 of tButton 
   if kReporter is "true" then put LF & "JUST BEFORE CREATE button tButton  = " & tButton after msg
   
   create button tButton
   set the style of button tButton to "menu"
   set the menuMode of button tButton to "option"
   
   if kReporter is "true" then put LF & "JUST AFTER CREATE button tButton  = " & tButton after msg
   
   -- GET VALUE
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "value") into tValue
     
   if kReporter is "true" then put LF & "tValue = " & tValue after msg -- development field
   
   -- GET OPTION(S)
   --    EXAMPLE: 
   --    <select id="select_Option_Menu_1105" value="Choice 2">
   --       <option value="Choice 1">Choice 1</option>
   --       <option value="Choice 2">Choice 2</option>
   --       <option value="Choice 3">Choice 3</option>
   --    </select>
   put offset(">",pHtmlFileData,tSkipChar) into tEndChar
   add tEndChar to tSkipChar
   put offset("</select>",pHtmlFileData,tSkipChar) into tEndSelectTagChar
   add tSkipChar to tEndSelectTagChar
   put 0 into tCounter
   put empty into tButtonText
   repeat
      get offset("<option",pHtmlFileData,tSkipChar)
      if it is empty or it is 0 then exit repeat -- no more option in file
      put it into tOptionChar
      add tSkipChar to tOptionChar
      if tOptionChar > tEndSelectTagChar then exit repeat -- option in another tag
      put tOptionChar into tSkipChar
      put offset("value",pHtmlFileData,tSkipChar) into tStartChar
      add 7 to tStartChar -- move to just inside start "
      add tSkipChar to tStartChar
      put tStartChar into tSkipChar
      put offset(">",pHtmlFileData,tSkipChar) into tEndChar
      subtract 2 from tEndChar -- move to just inside end "
      add tSkipChar to tEndChar
      put char tStartChar to tEndChar of pHtmlFileData into tOptionVal
      add 1 to tCounter
      put tOptionVal into line tCounter of tButtonText
      -- xxx at least for now, ignore TEXT between <option>TEXT</option>
      -- xxx set to be same as option value in EXPORT script
   end repeat
   set the text of button tButton to tButtonText
   if tCounter < 6 then
      set the menuLines of button tButton to tCounter 
   else
      set the menuLines of button tButton to 6
   end if
   
   -- GET CSS & SET CONTROL PROPERTIES
   
   put the long name of button tButton into tControlLongName -- NOTE button tButton
   get fGetSetControlProps(tID, tControlLongName, pCssFileData, tGrpLocList)
   
   if kReporter is "true" then put LF & "just before end fImportMenuButton" & LF after msg 
   -- update tSkipChar
   put offset("</select>",pHtmlFileData,tSkipChar) into tEndSelectTagChar
   add tEndSelectTagChar to tSkipChar
   put offset(">",pHtmlFileData,tSkipChar) into tEndSelectTagChar
   add tEndSelectTagChar to tSkipChar
   return tSkipChar
end fImportMenuButton

-----------------------------

function fImportImage tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList
   if kReporter is "true" then put LF & "enter fImportImage" & LF after msg
   -- EXAMPLE: <img id="image_robo_99_png_1059" src="images/robo 99.png"> 
   -- tSkipChar points to < of <img
   -- need to return updated tSkipChar
   
   -- GET CONTROL ID
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "id") into tID
   
   put tID into tImage -- will use both tID and tImage below
   replace "_" with space in tImage
   -- "image" added in export, others added later might not have it
   if word 1 of tImage is "image" then delete word 1 of tImage 
   if kReporter is "true" then put LF & "JUST BEFORE CREATE IMAGE tImage = " & tImage after msg
   create image tImage
   -- set the showBorder of image tImage to true -- during development if need to see rect
   if kReporter is "true" then put LF & "JUST AFTER CREATE IMAGE tImage = " & tImage after msg
   
   -- GET SRC ATTRIBUTE 
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "src") into tSRC
     
   if kReporter is "true" then put LF & "tSRC = " & tSRC after msg -- development field
   
   set the cFilename of image tImage to tSRC -- xxx may want to use this on export
   
   -- for files in images folder, put copy of images folder with this image
   -- at level of the maker stack
   set the filename of image tImage to tSRC
   
   -- GET CSS & SET CONTROL PROPERTIES
   
   put the long name of image tImage into tControlLongName -- NOTE image tImage
   get fGetSetControlProps(tID, tControlLongName, pCssFileData, tGrpLocList)
   
   -- update and return tSkipChar
   put offset(">",pHtmlFileData,tSkipChar) into tTagEndChar
   add tTagEndChar to tSkipChar
   return tSkipChar
end fImportImage

-----------------------------

function fImportLockedField tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList
   if kReporter is "true" then put LF & "enter fImportLockedField" & LF after msg
   -- <p> tag = locked field
   -- tSkipChar points to < of <p
   -- need to return updated tSkipChar
   
   -- GET CONTROL ID
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "id") into tID
   
   put tID into tField
   replace "_" with space in tField
   -- "field" added in export, others added later might not have it
   if word 1 of tField is "field" then delete word 1 of tField 
   if kReporter is "true" then put LF & "JUST BEFORE CREATE FIELD tField = " & tField after msg
   
   create field tField
   
   if kReporter is "true" then put LF & "JUST AFTER CREATE FIELD tField = " & tField after msg
   
   set the lockText of field tField to true
   set the showFocusBorder of field tField to false
   set the showBorder of field tField to false -- default for locked fields - can be changed by fGetSetControlProps
   set the textAlign of field tField to left -- xxx may be set in p { } in css
   -- setting textHeight and fixedLineHeight does not work here - set below
   
   -- get <p> tag (locked field) contents
   put offset(">",pHtmlFileData,tSkipChar) into tPendChar
   add tSkipChar to tPendChar
   put offset("</p",pHtmlFileData,tSkipChar) into tPendTagChar
   add tSkipChar to tPendTagChar
   put tPendTagChar into tSkipChar
   put char tPendChar+1 to tPendTagChar-1 of pHtmlFileData into tPcontents
   
   put fGetStripOuterSpace(tPcontents) into tPcontents -- e.g., strip spaces
   
   set the htmlText of field tField to tPcontents
   -- Note: this preserves links <a> tags but won't appear in LC with same color, etc., as in web browser
    
   -- GET CSS & SET CONTROL PROPERTIES
   
   put the long name of field tField into tControlLongName -- NOTE field tField
   get fGetSetControlProps(tID, tControlLongName, pCssFileData, tGrpLocList)
   
   -- for locked fields only, EXPORT subtracts a constant kFieldShift from top  
   --      before writing <p> to CSS
   --      reverse here
   put the topLeft of field tField into tTopLeft
   add kFieldShift to item 2 of tTopLeft
   set the topLeft of field tField to tTopLeft 
   
   -- did not work to set these above
   -- set them here to try to get better correspondence
   set the textHeight of field tField to 16
   set the fixedLineHeight of field tField to true
      
   if kReporter is "true" then put LF & "just before end of fImportLockedField" & LF after msg
   
   -- return updated tSkipChar
   -- which was updated above in fImportLockedField
   return tSkipChar
end fImportLockedField

--------------------------------- 

function fImportInputTag tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList
   if kReporter is "true" then put LF & "enter fImportInputTag" & LF after msg
   if kReporter is "true" then  get fGetReporter(tSkipChar, pHtmlFileData)
   -- tSkipChar points to < of <input
   -- imports <input that is not inside <label tags
   -- uses 3 functions: fImportUnlockedField, fImportStandardButton, fImportScrollbar
   
   -- get type attribute if any - if no type then input for unlocked field
   -- attributes can be in any order
   put offset("type",pHtmlFileData,tSkipChar) into tTypeChar
   if kReporter is "true" then put LF & "offset gives tTypeChar before add skip = " & tTypeChar after msg
   add tSkipChar to tTypeChar
   put offset(">",pHtmlFileData,tSkipChar) into tEndChar
   if kReporter is "true" then put LF & "offset gives tEndChar before add skip = " & tEndChar after msg
   add tSkipChar to tEndChar -- tEndChar put into tSkipChar at end this function
   if kReporter is "true" then put LF & "tTypeChar = " & tTypeChar && "tEndChar = " & tEndChar after msg
   if tTypeChar > tEndChar or tTypeChar = tSkipChar then -- tTypeChar = 0 if no more types in file
      if kReporter is "true" then 
         put LF & "(tTypeChar > tEndChar or tTypeChar = tSkipChar) so no type" after msg
      end if
      -- input tag does not have a type attribute
      -- so input tag is for an unlocked field
      get fImportUnlockedField(tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList)
      -- don't do anything with return, update tSkipChar below
   else
      if kReporter is "true" then 
         put LF & "(tTypeChar NOT > tEndChar AND tTypeChar NOT = tSkipChar) so there IS a type" after msg
      end if
      -- input tag has a type attribute
      -- check what type attribute is
      -- xxx ASSUME type="typename" FOLLOWED BY SPACE OR >
      -- xxx was having problems using offset to find quote
      put offset(space,pHtmlFileData,tTypeChar) into tSpaceChar
      if kReporter is "true" then 
         put LF & "tSpaceChar before add tTypeChar = " & tSpaceChar after msg
      end if
      add tTypeChar to tSpaceChar
      put offset(">",pHtmlFileData,tTypeChar) into tEndChar -- tEndChar changed from that above
      if kReporter is "true" then 
         put LF & "tEndChar before add tTypeChar = " & tEndChar after msg
      end if
      add tTypeChar to tEndChar
      if tSpaceChar < tEndChar then
         -- assume have type="typename" immediately followed by space
         if kReporter is "true" then 
            put LF & "tSpaceChar = " & tSpaceChar & " < tEndChar = " & tEndChar after msg
         end if
         put char tTypeChar+6 to tSpaceChar-2 of pHtmlFileData into tType
      else
         -- assume have type="typename" immediately followed by >
         if kReporter is "true" then 
            put LF & "tSpaceChar = " & tSpaceChar & " > tEndChar = " & tEndChar after msg
         end if
         put char tTypeChar+6 to tEndChar-2 of pHtmlFileData into tType
      end if
      if kReporter is "true" then put LF & "tType = " & tType after msg
      switch tType
         case "button"
            get fImportStandardButton(tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList)
            -- don't do anything with return, update tSkipChar below
            break
         case "range"
            get fImportScrollbar(tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList)
            -- don't do anything with return, update tSkipChar below
            break
         default
            if kReporter is "true" then put LF & "at parent input tag but no known type found" & LF after msg
      end switch
   end if
   
   if kReporter is "true" then put LF & "just before end fImportInputTag" & LF after msg
   
   -- return updated tSkipChar
   put tEndChar into tSkipChar -- tEndChar for > found above
   return tSkipChar
end fImportInputTag

-------------------------------

function fImportUnlockedField tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList
   if kReporter is "true" then put LF & "enter fImportUnlockedField" & LF after msg
   -- tSkipChar points to < of parent <input, no need to return, updated at end fImportInputTag
   -- called by function fImportInputTag
   -- LC unlocked fields are for HTML input tag with no type attribute for input fields
   -- EXAMPLE:  <input id="input_field_enterKflow_1203" value="0.04" onchange="puCatalystLayer.updateUIparams()"></input>
   
   -- GET CONTROL ID
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "id") into tID
   
   -- GET VALUE
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "value") into tValue
   
   if kReporter is "true" then put LF & "tValue= " & tValue after msg
   
   -- GET ONCHANGE, IF ANY
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "onchange") into tOnchange
   
   if kReporter is "true" then put LF & "tOnchange= " & tOnchange after msg
   
   put tID into tField -- will use both tID and tField below
   replace "_" with space in tField
   -- "input_field" added in export of unlocked field, others added later might not have it
   if word 1 of tField is "input" then delete word 1 of tField 
   if word 1 of tField is "field" then delete word 1 of tField
   if kReporter is "true" then put LF & "JUST BEFORE CREATE FIELD tField = " & tField after msg
   
   create field tField
   
   if kReporter is "true" then put LF & "JUST AFTER CREATE FIELD tField = " & tField after msg
   
   set the showBorder of field tField to true -- default for unlocked fields for input - can be changed by fGetSetControlProps
   set the showFocusBorder of field tField to false   
   set the textAlign of field tField to "center" -- default for unlocked fields for input - can be changed by fGetSetControlProps
   set the lockText of field tField to false
   
   set the text of field tField to tValue
   
   if tOnchange is not empty then
      set the cOnchange of field tField to tOnchange
   end if
   
   -- GET CSS & SET CONTROL PROPERTIES
   
   put the long name of field tField into tControlLongName -- NOTE field tField
   get fGetSetControlProps(tID, tControlLongName, pCssFileData, tGrpLocList)
   
   if kReporter is "true" then put LF & "just before end of fImportUnlockedField" & LF after msg
   return empty -- no need to return tSkipChar
end fImportUnlockedField

-------------------------------

function fImportStandardButton tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList
   if kReporter is "true" then put LF & "enter fImportStandardButton" & LF after msg
   -- tSkipChar points to < of parent <input, no need to return, updated at end fImportInputTag
   -- called by function fImportInputTag
   -- EXAMPLE: <input type="button" id="button_resetButton_1177" value="Reset" onclick="resetThisLab()"></input>
   
   -- GET CONTROL ID
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "id") into tID
   
   -- tID used below in GET CSS
   put tID into tButton
   replace "_" with space in tButton
   -- "button" added in export, others added later might not have it
   if word 1 of tButton is "button" then delete word 1 of tButton
   
   -- GET VALUE
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "value") into tValue
   
   if kReporter is "true" then put LF & "tValue= " & tValue after msg
   
   -- GET ONCLICK
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "onclick") into tOnclick
   
   if kReporter is "true" then put LF & "tOnclick= " & tOnclick after msg
   
   -- CREATE BUTTON
   create button
   set the name of it to tButton
   if tValue is not empty then
      set the label of button tButton to tValue
   end if
   if tOnclick is not empty then
      set the cOnclick of button tButton to tOnclick
   end if
   
   -- GET CSS & SET CONTROL PROPERTIES
   
   put the long name of button tButton into tControlLongName -- NOTE button tButton
   get fGetSetControlProps(tID, tControlLongName, pCssFileData, tGrpLocList)
   
   if kReporter is "true" then put LF & "just before end fImportStandardButton" & LF after msg
   return empty -- no need to return tSkipChar
end fImportStandardButton

------------------------------- 

function fImportScrollbar tSkipChar, pHtmlFileData, pCssFileData, tGrpLocList
   if kReporter is "true" then put LF & "enter fImportScrollbar" & LF after msg
   -- tSkipChar points to < of parent <input, no need to return, updated at end fImportInputTag
   -- called by function fImportInputTag
   -- EXAMPLE: <input type="range" id="range_setCmax_slider_1200" min="0" max="1" step="0.01" value="1"
   --                          oninput="puCatalystLayer.updateUIparams()"></input>
   
   -- GET CONTROL ID
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "id") into tID
   
   -- tID used below in GET CSS
   put tID into tScrollbar
   replace "_" with space in tScrollbar
   -- "range" added in export, others added later might not have it
   if word 1 of tScrollbar is "range" then delete word 1 of tScrollbar
   
   -- GET VALUE, IF ANY
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "value") into tValue
   if tValue is empty then put 50 into tValue
   
   if kReporter is "true" then put LF & "tValue= " & tValue after msg
   
   -- GET MIN, IF ANY
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "min") into tMin
   if tMin is empty then put 0 into tMin
   
   if kReporter is "TEST" then put LF & "fImportScrollbar, tMin = " & tMin after msg
   
   -- GET MAX, IF ANY
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "max") into tMax
   if tMin is empty then put 100 into tMin
   
   if kReporter is "TEST" then put LF & "fImportScrollbar, tMax = " & tMax after msg
   
   -- GET STEP, IF ANY
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "step") into tStep
   if tStep is empty then put 1 into tStep
   
   if kReporter is "true" then put LF & "tStep = " & tStep after msg
   
   -- GET ONINPUT, IF ANY
   put fGetHtmlAttribute(tSkipChar, pHtmlFileData, "oninput") into tOninput 
   
   if kReporter is "true" then put LF & "tOninput= " & tOninput after msg
   
   create scrollbar tScrollbar
   set the style of scrollbar tScrollbar to scale
   
   --- GET CSS & SET CONTROL PROPERTIES
   
   put the long name of scrollbar tScrollbar into tControlLongName -- NOTE scrollbar tScrollbar   
   get fGetSetControlProps(tID, tControlLongName, pCssFileData, tGrpLocList) 
   
   put it into tTransformFlag -- returned true if control has a transform flag
   
   if kReporter is "true" then put LF & "in fImportScrollbar, after return from fGetSet... tTransformFlag = " & tTransformFlag after msg 
   
   if tTransformFlag is true then
      if kReporter is "true" then 
         put LF & "tTransformFlag is TRUE" after msg
      end if
      -- vertical scrollbar
      -- startValue in LC vertical scrollbar is at top
      -- ASSUME LC scrollbar has larger # at top so LC startValue at top is > LC endValue at btm
      -- CSS/HTML rotated a horiz range to get vertical
      -- CSS/HTML horiz range rotated 270 deg to vertical range has min at bottom, max at top
      set the startValue of scrollbar tScrollbar to tMax
      set the endValue of scrollbar tScrollbar to tMin
   else
      -- horizontal scrollbar
      set the startValue of scrollbar tScrollbar to tMin
      set the endValue of scrollbar tScrollbar to tMax
   end if
   
   -- finish up scrollbar
   set the pageInc of scrollbar tScrollbar to tStep
   set the thumbPosition of scrollbar tScrollbar to tValue
   if tOninput is not empty then
      set the cOninput of scrollbar tScrollbar to tOninput
   end if
   
   if kReporter is "true" then put LF & "just before end fImportScrollbar" & LF after msg
   return empty -- no need to return tSkipChar
end fImportScrollbar

-------------------------------

script "maker-script"
/*
Design, text, images and code by Richard K. Herz, 2017 
Copyrights held by Richard K. Herz
Licensed for use under the GNU General Public License v3.0 
https://www.gnu.org/licenses/gpl-3.0.en.html
*/ 

local oHtmlFileData
local oCssFileData 
local oGrpList
local oGrpLocList

constant kKillWord = "lcCardLayoutToWeb" -- controls with this in name aren't written to html
constant kCommentStart = "<!--"
constant kCommentEnd = "-->"
constant kTagEndStart = "</"

-----------------------------
/*
TAGS DONE 
div = group 
p = locked field 
img = image 
select = menu button
input with no type = unlocked field
input with type="button" = button
input with type="range" = scrollbar
TAGS TO DO
canvas 
label > input type="checkbox" > span = checkbox
label > input type="radio" > span = radio button (will be several inside one div/group)
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

on importWebPage
   
   -- uses local variables oHtmlFileData & oCssFileData 
   -- uses command makeLiveCodeCard
   
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
      put url tHtmlFile into oHtmlFileData
   else
      exit to top
   end if
   
   if tCssFile is not empty then
      put "file:" before tCssFile
      put url tCssFile into oCssFileData
   else
      exit to top
   end if
   
   makeLiveCodeCard
   
end importWebPage

-----------------------------

on makeLiveCodeCard
   
   -- uses local variables oHtmlFileData & oCssFileData 
   -- uses constant kKillWord
   -- is called by command importWebPage
   
   -- MUST USE MESSAGE BOX FOR DEVELOPMENT RECORD - NOT FIELD
   -- BECAUSE CAN'T ACCESS FIELD WHEN EDITING A GROUP easily at least
   put empty into msg
   
   put empty into oGrpList
   put empty into oGrpLocList
   
   -- get all data above <body>
   
   put offset("<body>",oHtmlFileData) into tBodyStartChar
   put char 1 to tBodyStartChar-1 of oHtmlFileData into tHeaderData
   put LF & tHeaderData after msg
   put "header" && kKillWord into tNewControl
   create button tNewControl
   set the label of button tNewControl to "header"
   set the topLeft of button tNewControl to "0,16"
   set the cHtmlData of button tNewControl to tHeaderData 
   
   put tBodyStartChar into tSkipChar
   add 5 to tSkipChar -- set to end <body>
   
   repeat
      put offset("<",oHtmlFileData,tSkipChar) into tNextTagStart
      if tNextTagStart is 0 then exit repeat
      add tNextTagStart to tSkipChar
      put tSkipChar into tNextTagStart
      if offset("!--",oHtmlFileData,tSkipChar) = 1 then 
         -- tSkipChar points to < of <!-- comment
         put LF & "comment found" & LF after msg
         -- want to skip to end comment in case have commented out some controls
         put offset("-->",oHtmlFileData,tSkipChar) into tEndComment
         add tEndComment to tSkipChar
         next repeat
      end if
      if offset("/div>",oHtmlFileData,tSkipChar) = 1 then 
         -- tSkipChar points to < of </div>
         put LF & "just before call fImportGroupEnd" & LF after msg
         put fImportGroupEnd(tSkipChar) into tSkipChar
         next repeat
      end if
      if offset("/",oHtmlFileData,tSkipChar) = 1 then 
         -- tSkipChar points to < of </tag
         -- these are usually handled in tag functions but get for </body> and </html>
         add 1 to tSkipChar -- get off this
         next repeat
      end if
      put offset(space,oHtmlFileData,tSkipChar) into tNextSpaceChar
      -- but could be <tag> and space down the line...
      -- make sure it's not past end this tag
      put offset(">",oHtmlFileData,tSkipChar) into tNextEndChar
      if tNextEndChar < tNextSpaceChar then
         -- not a tag with an attribute such as type or id
         put LF & "tNextEndChar < tNextSpaceChar so not a tag with attribute such as type or id" & LF after msg
      else
         add tSkipChar to tNextSpaceChar
         put char tNextTagStart + 1 to tNextSpaceChar - 1 of oHtmlFileData into tTagName
         put LF & "before switch in makeLiveCodeCard, tTagName = " & tTagName & LF after msg
         switch tTagName
            case "div"
               -- import div = group
               put fImportGroupStart(tSkipChar) into tSkipChar
               break
            case "p"
               -- import p = locked field
               put fImportLockedField(tSkipChar) into tSkipChar
               break
            case "img"
               -- import img = image
               put fImportImage(tSkipChar) into tSkipChar
               break
            case "select"
               -- import select = menu button
               put fImportMenuButton(tSkipChar) into tSkipChar
               break
            case "input"
               -- import input that are not inside <label tags
               -- 3 types: none = unlocked field, button = button, range = slider
               put fImportInputTag(tSkipChar) into tSkipChar
               break
            case "label"
               -- import label
               -- need to look for <input inside
               -- two input types: checkbox, radio button
               -- <label <input followed by <span
               put fImportLabelTag(tSkipChar) into tSkipChar
               break
            case "canvas"
               -- import ?? maybe use a div?
               put fImportCanvas(tSkipChar) into tSkipChar
               break
            default
               -- ignore
         end switch
      end if
   end repeat
   
end makeLiveCodeCard

----------------------------- 

function fImportCanvas tSkipChar
   -- need to return updated tSkipChar
   -- EXAMPLE: <canvas id="canvas_rate"></canvas> 
   -- used for generating images on HTML canvas by Javascript
   
   
   -- update tSkipChar before returning
   put offset("</canvas>",oHtmlFileData,tSkipChar) into tEndChar
   add tEndChar to tSkipChar
   put offset(">",oHtmlFileData,tSkipChar) into tEndChar
   add tEndChar to tSkipChar
   return tSkipChar
end fImportCanvas

----------------------------- 

function fImportLabelTag tSkipChar
   put LF & "enter fImportLabelTag" & LF after msg
   -- tSkipChar points to < of <label
   -- need to return updated tSkipChar
   -- THERE ARE TWO TYPES
   -- need to look for <input inside of <label and </label>
   -- two input types: checkbox, radio button
   -- <label <input followed by <span
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
   put offset("</label>",oHtmlFileData,tSkipChar) into tEndChar
   put offset("type=",oHtmlFileData,tSkipChar) into tTypeChar
   put empty into tType
   if (tTypeChar < tEndChar) then
      add tSkipChar to tTypeChar
      add 6 to tTypeChar -- just inside " of type="
      put offset(quote,oHtmlFileData,tTypeChar) into tQuoteChar
      subtract 1 from tQuoteChar
      add tTypeChar to tQuoteChar
      put char tTypeChar to tQuoteChar of oHtmlFileData into tType
   end if
   switch tType
      case "radio"
         get fImportRadioButton(tSkipChar)
         -- do not update tSkipChar here
         break
      case "checkbox"
         get fImportCheckBox(tSkipChar)
         -- do not update tSkipChar here
         break
      default
         -- no type?
         -- xxx need error message
   end switch
   
   put LF & "exit fImportLabelTag" & LF after msg
   
   -- update tSkipChar here before returning
   put offset("</label>",oHtmlFileData,tSkipChar) into tEndChar
   add tEndChar to tSkipChar
   put offset(">",oHtmlFileData,tSkipChar) into tEndChar
   add tEndChar to tSkipChar
   return tSkipChar
end fImportLabelTag

-----------------------------  

function fImportCheckBox tSkipChar
   put LF & "enter fImportCheckBox" & LF after msg
   -- tSkipChar points to < of <label inside which the checkbox is contained
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
   
   -- GET ID FOR LABEL
   -- GET ID - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   put offset("id=",oHtmlFileData,tSkipChar) into tIDstartChar
   add tSkipChar to tIDstartChar -- char at i of id=
   add 4 to tIDstartChar -- char just inside " of id="
   put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
   subtract 1 from tIDendChar -- step back before quote
   add tIDstartChar to tIDendChar
   put char tIDstartChar to tIDendChar of oHtmlFileData into tID   
   put LF & "tID = " & tID after msg -- development field
   
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
   
   -- NOW HAVE: tID_LABEL, tIDname, tID_SPAN
   -- UNDER ASSUMED NAMING CONVENTION
   
   -- GET WHETHER OR NOT INPUT HAS CHECKED ATTRIBUTE
   -- AND SAVE AS CUSTOM PROP OF LC CONTROL
   -- xxx and add on EXPORT
   put offset("<input",oHtmlFileData,tSkipChar) into tInputTagStart 
   add tSkipChar to tInputTagStart
   put offset(">",oHtmlFileData,tSkipChar) into tInputTagEnd
   add tSkipChar to tInputTagEnd
   put offset(space & "checked",oHtmlFileData,tSkipChar) into tCheckedChar -- no space at end for checked>
   if tCheckedChar > 0 and tCheckedChar < tInputTagEnd then
      put "true" into tCheckedFlag 
      
      -- later, set the hilite of the control to true
      
   else
      put "false" into tCheckedFlag 
   end if
   
   -- GET WHETHER OR NOT INPUT HAS ONCHANGE ATTRIBUTE
   -- AND SAVE AS CUSTOM PROP OF LC CONTROL
   -- xxx and add on EXPORT
   put offset("<input",oHtmlFileData,tSkipChar) into tInputTagStart 
   put offset(">",oHtmlFileData,tSkipChar) into tInputTagEnd
   put offset("onchange=",oHtmlFileData,tSkipChar) into tChangedChar
   if tChangedChar > tInputTagStart and tChangedChar < tInputTagEnd then
      put "true" into tChangedFlag
   else
      put "false" into tChangedFlag
   end if
   if tChangedFlag is "true" then
      add tSkipChar to tChangedStart
      add 10 to tChangedStart -- move from o to inside " of onchange="
      put offset(quote,oHtmlFileData,tChangedChar) into tChangedEnd
      subtract 1 from tChangedEnd
      put char tChangedStart to tChangedEnd of oHtmlFileData into tOnchange
      
      -- later set the cOnchange of the control to tOnchange
      
   end if
   
   -- GET TEXT BETWEEN <span AND </span>
   -- AND SET AS SHORT NAME OF THE LC CONTROL
   -- ASSUME THERE IS A SPAN TAG WITH TEXT INSIDE LABEL TAG
   put offset("<span",oHtmlFileData,tSkipChar) into tSpanTagStart
   add tSkipChar to tSpanTagStart
   put offset(">",oHtmlFileData,tSpanTagStart) into tSpanTagTemp
   add tSpanTagTemp to tSpanTagStart
   put offset("</span>",oHtmlFileData,tSkipChar) into tSpanTagEnd
   add tSkipChar to tSpanTagEnd
   add 1 to tSpanTagStart
   subtract 1 from tSpanTagEnd
   put char tSpanTagStart to tSpanTagEnd of oHtmlFileData into tButton -- tButton used below in CSS
   
   -- later set the short name of the LC control to tSpanTagText
   
   -- CREATE LC CONTROL
   create button
   set the name of it to tButton
   set the style of button tButton to "checkbox"
   set the cOnchange of button tButton to tOnchange
   if tCheckedFlag is "true" then set the hilite of button tButton to "true"
   
   -- GET CSS
   -- GET CSS INFO - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   -- xxx problems if "#" & tID mentioned in a comment!
   -- DO NOT USE tSkipChar for CSS
   
   -- THIS IS DIFFERENT BECAUSE CSS HAS tID_LABEL &  tID_SPAN
   -- CSS for tID_LABEL has left and top for LC topLeft (left,top)
   -- CSS for tID_SPAN has info for text label
   -- EXAMPLE
   --    #checkbox_Check1_1046_LABEL {
   --    left: 180px;
   --    top: 113px;
   --    }
   
   --    #checkbox_Check1_1046_SPAN {
   --    margin-left: 22px;
   --    line-height: 18px;
   --    }
   
   -- FOR NOW, ONLY GET _LABEL FOR BUTTON LOCATION
   put tID_LABEL into tID -- use tID below
   
   put empty into tCssData
   if oCssFileData is not empty then
      put offset("#" & tID,oCssFileData) into tStartChar
      put offset("}",oCssFileData,tStartChar) into tEndChar
      add tStartChar to tEndChar
      put char tStartChar to tEndChar of oCssFileData into tCssData
      put LF & tCssData & LF after msg -- development field
   end if
   
   if tCssData is not empty then
      -- assume top and bottom lines don't have data but the other lines do
      
      set the itemDelimiter to colon
      repeat for each line n in tCssData
         if n contains "#" then next repeat
         if n contains "}" then exit repeat
         put word 1 of item 1 of n into tProp -- so don't get spaces
         put item 2 of n into tPix
         
         -- watch out for a calc();
         if tPix contains "calc" then
            put offset("+",tPix) into tPlusChar -- assume a space after plus
            put offset("px",tPix) into tPXChar
            put char tPlusChar + 2 to tPXChar -1 of tPix into tPix
            put 50 into tShift -- xxx what I'm using in development
            add tShift to tPix
         else
            repeat 3 times -- delete px;
               delete the last char of tPix
            end repeat
         end if
         
         --          -- xxx NEED TO DO THIS IF DO NOT CHECK FOR CALC()
         --          repeat 3 times -- delete px;
         --             delete the last char of tPix
         --          end repeat
         
         -- xxx NEED TO CHECK FOR OTHER PROPS SUCH AS FONT SIZE 
         
         switch tProp
            case "width"
               set the width of button tButton to tPix
               break
            case "height"
               set the height of button tButton to tPix
               break
            case "left"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tPix into item 1 of tTopLeft -- save, don't set topLeft yet
               -- save, need to add container group left & setting height & width changes topLeft
               set the itemDelimiter to colon
               break
            case "top"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tPix into item 2 of tTopLeft -- save, don't set topLeft yet
               -- save, need to add container group left & setting height & width first changes topLeft
               set the itemDelimiter to colon
               break
            case "font-size"
               set the textSize of button tButton to tPix
               break
         end switch
      end repeat
   end if
   -- do this after setting width and height since setting those changes topLeft
   -- first get topLeft of group relative to LC card topLeft
   if the last line of oGrpLocList is empty then delete the last line of oGrpLocList -- in case of LF and empty line
   if the last line of oGrpLocList is not empty then
      put the last line of oGrpLocList into tLast
      put LF & "tLast = last line of oGrpLocList = " & tLast after msg
      set the itemDelimiter to comma
      add item 1 of tLast to item 1 of tTopLeft
      add item 2 of tLast to item 2 of tTopLeft
   end if
   
   put LF & "JUST BEFORE set the topLeft of button tButton to tTopLeft" after msg
   put LF & "tButton = " & tButton && ";" && "tTopLeft = " & tTopLeft after msg
   
   set the topLeft of button tButton to tTopLeft
   
   put LF & "exit fImportCheckBox" & LF after msg
   -- do not return tSkipChar here
end fImportCheckBox

----------------------------- 

function fImportRadioButton tSkipChar
   put LF & "enter fImportRadioButton" & LF after msg
   -- tSkipChar points to < of <label inside which the radio button is contained
   -- HERE JUST IMPORT ONE RADIO BUTTON -- THAT IS, ONE LABEL TAG
   -- EXAMPLE:
   --    <label id="radio_Radio2_1043_LABEL" name="radio_of_group_RADIO_group">
   --       <input type="radio" id="radio_Radio2_1043" name="radio_of_group_RADIO_group">
   --       <span id="radio_Radio2_1043_SPAN">Radio2</span>
   --    </label>
   -- EXPORT only writes CSS for <label and <span, not <input
   -- but modified HTML may have a checked attribute in <input 
   -- and also will have an onchange in <input so need to save to custom prop and
   -- add on export
   
   put LF & "exit fImportRadioButton" & LF after msg
   -- do not return tSkipChar here
end fImportRadioButton

----------------------------- 

function fStripOuterSpace tText
   -- used to strip junk from both ends of text in <p> tag
   -- need to use compound conditions because can be in any order, e.g., space LF tab space
   repeat while char 1 of tText is space OR char 1 of tText is LF OR char 1 of tText is tab
      delete char 1 of tText
   end repeat
   repeat while the last char of tText is space OR the last char of tText is LF OR the last char of tText is tab
      delete the last char of tText
   end repeat
   return tText
end fStripOuterSpace

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

function fImportGroupStart tSkipChar
   put LF & "enter fImportGroupStart" & LF after msg
   -- <div> = group
   -- tSkipChar points to < of <div
   -- need to return updated tSkipChar
   
   -- get fReporter(tSkipChar) -- development
   
   -- THIS NEEDS TO
   --   input list of groups and group topLefts
   --   add to these lists
   --   create a new empty group if possible
   --   return the updated list of groups and group topLefts
   
   -- Naming for example
   -- group "simulation frame" ends up as <div id="div_simulation_frame_1128">
   -- may want to keep original _1128 by revising export rather than use a new id if can't set
   -- so that orig javascript still works
   
   -- GET ID - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   put offset(">",oHtmlFileData,tSkipChar) into tPendChar
   add tSkipChar to tPendChar 
   put offset("id=",oHtmlFileData,tSkipChar) into tIDstartChar
   add tSkipChar to tIDstartChar -- char at i of id=
   add 4 to tIDstartChar -- char just inside " of id="
   put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
   subtract 1 from tIDendChar -- step back before quote
   add tIDstartChar to tIDendChar
   put char tIDstartChar to tIDendChar of oHtmlFileData into tID
   put LF & tID after msg
   
   -- tID example is div_simulation_frame_1128
   put tID into tIDname -- tIDname will have spaces, keep tID for CSS
   replace "_" with space in tIDname
   -- "div" added in export, others added later might not have it
   if word 1 of tIDname is "div" then delete word 1 of tIDname -- delete div
   put tIDname & LF after oGrpList
   -- get topLeft of group below for oGrpLocList
   
   put LF & "JUST BEFORE create group " & tIDname after msg
   create group
   set the name of it to tIDname
   put LF & "JUST AFTER create group " & tIDname after msg
   
   -- GET CSS INFO - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   -- xxx problems if "#" & tID mentioned in a comment!
   -- DO NOT USE tSkipChar for CSS
   put empty into tCssData
   if oCssFileData is not empty then
      put offset("#" & tID,oCssFileData) into tStartChar
      put offset("}",oCssFileData,tStartChar) into tEndChar
      add tStartChar to tEndChar
      put char tStartChar to tEndChar of oCssFileData into tCssData
      put LF & tCssData & LF after msg -- development field
   end if
   
   if tCssData is not empty then
      -- assume top and bottom lines don't have data but the other lines do
      
      set the itemDelimiter to colon
      repeat for each line n in tCssData
         if n contains "#" then next repeat
         if n contains "}" then exit repeat
         put word 1 of item 1 of n into tProp -- so don't get spaces
         put item 2 of n into tPix
         
         -- watch out for a calc();
         if tPix contains "calc" then
            put offset("+",tPix) into tPlusChar -- assume a space after plus
            put offset("px",tPix) into tPXChar
            put char tPlusChar + 2 to tPXChar -1 of tPix into tPix
            put 50 into tShift -- xxx what I'm using in development
            add tShift to tPix
         else
            repeat 3 times -- delete px;
               delete the last char of tPix
            end repeat
         end if
         
         --          -- xxx NEED TO DO THIS IF DO NOT CHECK FOR CALC()
         --          repeat 3 times -- delete px;
         --             delete the last char of tPix
         --          end repeat
         
         switch tProp
            case "width"
               set the width of group tIDname to tPix
               break
            case "height"
               set the height of group tIDname to tPix
               break
            case "left"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tPix into item 1 of tTopLeft -- save, don't set topLeft yet
               -- save, need to add container group left & setting height & width changes topLeft
               set the itemDelimiter to colon
               break
            case "top"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tPix into item 2 of tTopLeft -- save, don't set topLeft yet
               -- save, need to add container group left & setting height & width first changes topLeft
               set the itemDelimiter to colon
               break
         end switch
      end repeat
   end if   
   
   -- STORE CUMMULATIVE locations in oGrpLocList
   -- add these locs to locs from line above, if any
   -- then a new control just has to get locs from last line in group list
   if the last line of oGrpLocList is empty then delete the last line of oGrpLocList -- in case of LF and empty line
   if the last line of oGrpLocList is not empty then
      put the last line of oGrpLocList into tLast
      put LF &"tLast = last line of oGrpLocList = " & the last line of oGrpLocList after msg
      set the itemDelimiter to comma
      add item 1 of tLast to item 1 of tTopLeft
      add item 2 of tLast to item 2 of tTopLeft
   end if
   put tTopLeft & LF after oGrpLocList
   put LF & "oGrpLocList = " & LF & oGrpLocList after msg
   -- do this after setting width and height since setting those change topLeft
   put LF & "JUST BEFORE set the topLeft of group tIDname to tTopLeft" after msg
   put LF & "group tIDname = " & tIDname after msg
   put LF & "tTopLeft = " & tTopLeft after msg
   set the topLeft of group tIDname to tTopLeft
   set the lockLoc of group tIDname to true -- otherwise will "shrink to fit" contents, which are none at this point
   set the showBorder of group tIDname to true -- xxx so can see it in development
   
   put LF & "JUST BEFORE start editing group" && tIDname after msg
   start editing group tIDname
   put LF & "JUST AFTER start editing group" && tIDname & LF after msg
   
   return tSkipChar
end fImportGroupStart

----------------------------- 

function fReporter tSkipChar
   put char tSkipChar-20 to tSkipChar+20 of oHtmlFileData into tReport
   -- replace <> because some LC answer and text editors treat as HTML and/or colorize
   replace "<" with "*" in tReport -- use one char so don't throw off count in report text
   replace ">" with "*" in tReport -- use one char so don't throw off count in report text
   put LF & "+/- 20 of (tSkipChar = " & tSkipChar & ") is: " after msg
   put LF & "|||" & tReport & "|||" & LF after msg
end fReporter
-----------------------------

function fImportGroupEnd tSkipChar
   put LF & "enter fImportGroupEnd" & LF after msg
   -- input argument tSkipChar points to < of </div>
   -- need to return updated tSkipChar
   -- char which can occur after </div> is space or < or LF 
   
   -- get fReporter(tSkipChar) -- development
   
   -- THIS NEEDS TO
   --   input list of groups and group topLefts
   --   delete last group from these lists
   --   return the updated list of groups and group topLefts
   
   -- get rid of any empty lines due to LF at end
   if the last line of oGrpList is empty then delete the last line of oGrpList -- in case of LF and empty line
   if the last line of oGrpLocList is empty then delete the last line of oGrpLocList -- in case of LF and empty line
   -- get name of the last group
   put the last line of oGrpList into tGrpName
   
   put LF & "Before delete last line, tGrpName = " & tGrpName after msg
   
   put LF & "Before delete last line, oGrpList = " & LF & oGrpList after msg
   
   -- delete the last line with info about group
   if oGrpList is not empty then delete the last line of oGrpList
   if oGrpLocList is not empty then delete the last line of oGrpLocList
   
   -- FOUND I MUST USE "BACKGROUND" HERE AND NOT "GROUP"
   -- xxx is this a bug in this LC version = 9 dp 6 ??? 
   -- xxx group works above when start editing
   put LF & "the name of this background = " & the name of this background & LF after msg
   
   if oGrpList is empty then
      -- ending top level group
      -- when not in a group in a group, can't use group name when stopping
      put LF & "JUST BEFORE stop editing" & LF after msg
      stop editing
      put LF & "stop editing" & LF after msg
   else
      -- FOUND I MUST USE "BACKGROUND" HERE WHEN STOPPING EDIT OF GROUP AND NOT "GROUP"
      -- xxx is this a bug in this LC version = 9 dp 6 ??? 
      -- xxx group works above when start editing
      
      --       put LF & "JUST BEFORE stop editing background" && tGrpName after msg
      --       stop editing background tGrpName
      --       put LF & "stop editing background" && tGrpName after msg
      
      -- xxx BUT THIS ALSO STOPS EDITING OF THE GROUP IN WHICH THIS GROUP IS LOCATED !!!! 
      -- xxx WHICH IN THIS CASE IS THE SIMULATION FRAME GROUP
      -- xxx SINCE DO NOT HAVE 3rd LEVEL NESTING IN HTML EXAMPLE USED HERE...
      
      -- xxx SO HAD SAME EFFECT AS "STOP EDITING"
      
      stop editing
      put LF & "stop editing" & LF after msg
      
      -- if this group was nested inside a parent group, then go back to editing that parent group
      -- this has been tested for groups nested 3 deep: grandparent > parent > child
      if oGrpList is not empty then 
         put the last line of oGrpList into tGrpName
         start editing group tGrpName
      end if
      
   end if
   
   -- get tSkipChar off this </div>
   add 1 to tSkipChar
   
   put LF & "return tSkipChar = " & tSkipChar after msg
   put LF & "just before end fImportGroupEnd" & LF after msg
   return tSkipChar
end fImportGroupEnd

-----------------------------

function fImportMenuButton tSkipChar
   put LF & "enter fImportMenuButton" & LF after msg
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
   
   -- GET ID - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   put offset("id=",oHtmlFileData,tSkipChar) into tIDstartChar
   add tSkipChar to tIDstartChar -- char at i of id=
   add 4 to tIDstartChar -- char just inside " of id="
   put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
   subtract 1 from tIDendChar -- step back before quote
   add tIDstartChar to tIDendChar
   put char tIDstartChar to tIDendChar of oHtmlFileData into tID
   put LF & "tID = " & tID after msg -- development field
   
   put tID into tMenuBtn -- will use both tID and tMenuBtn below
   replace "_" with space in tMenuBtn
   -- "select" added in export, others added later might not have it
   if word 1 of tMenuBtn is "select" then delete word 1 of tMenuBtn 
   put LF & "JUST BEFORE CREATE button tMenuBtn  = " & tMenuBtn after msg
   
   create button tMenuBtn
   set the style of button tMenuBtn to "menu"
   set the menuMode of button tMenuBtn to "option"
   
   put LF & "JUST AFTER CREATE button tMenuBtn  = " & tMenuBtn after msg
   
   -- GET VALUE - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   put offset("value=",oHtmlFileData,tSkipChar) into tIDstartChar
   add tSkipChar to tIDstartChar -- char at i of id=
   add 7 to tIDstartChar -- char just inside " of value=" -- was 4 for id="
   put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
   subtract 1 from tIDendChar -- step back before quote
   add tIDstartChar to tIDendChar
   put char tIDstartChar to tIDendChar of oHtmlFileData into tValue
   put LF & "tValue = " & tValue after msg -- development field
   
   -- GET OPTION(S)
   --    EXAMPLE: 
   --    <select id="select_Option_Menu_1105" value="Choice 2">
   --       <option value="Choice 1">Choice 1</option>
   --       <option value="Choice 2">Choice 2</option>
   --       <option value="Choice 3">Choice 3</option>
   --    </select>
   put offset(">",oHtmlFileData,tSkipChar) into tEndChar
   add tEndChar to tSkipChar
   put offset("</select>",oHtmlFileData,tSkipChar) into tEndSelectTagChar
   add tSkipChar to tEndSelectTagChar
   put 0 into tCounter
   put empty into tMenuBtnText
   repeat
      get offset("<option",oHtmlFileData,tSkipChar)
      if it is empty or it is 0 then exit repeat -- no more option in file
      put it into tOptionChar
      add tSkipChar to tOptionChar
      if tOptionChar > tEndSelectTagChar then exit repeat -- option in another tag
      put tOptionChar into tSkipChar
      put offset("value",oHtmlFileData,tSkipChar) into tStartChar
      add 7 to tStartChar -- move to just inside start "
      add tSkipChar to tStartChar
      put tStartChar into tSkipChar
      put offset(">",oHtmlFileData,tSkipChar) into tEndChar
      subtract 2 from tEndChar -- move to just inside end "
      add tSkipChar to tEndChar
      put char tStartChar to tEndChar of oHtmlFileData into tOptionVal
      add 1 to tCounter
      put tOptionVal into line tCounter of tMenuBtnText
      -- xxx at least for now, ignore TEXT between <option>TEXT</option>
      -- xxx set to be same as option value in EXPORT script
   end repeat
   set the text of button tMenuBtn to tMenuBtnText
   if tCounter < 6 then
      set the menuLines of button tMenuBtn to tCounter 
   else
      set the menuLines of button tMenuBtn to 6
   end if
   
   -- GET CSS INFO - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   -- xxx problems if "#" & tID mentioned in a comment!
   -- DO NOT USE tSkipChar for CSS
   put empty into tCssData
   if oCssFileData is not empty then
      put offset("#" & tID,oCssFileData) into tStartChar
      put offset("}",oCssFileData,tStartChar) into tEndChar
      add tStartChar to tEndChar
      put char tStartChar to tEndChar of oCssFileData into tCssData
      put LF & tCssData & LF after msg -- development field
   end if
   
   if tCssData is not empty then
      -- assume top and bottom lines don't have data but the other lines do
      
      set the itemDelimiter to colon
      repeat for each line n in tCssData
         if n contains "#" then next repeat
         if n contains "}" then exit repeat
         put word 1 of item 1 of n into tProp -- so don't get spaces
         put item 2 of n into tPix
         
         -- watch out for a calc();
         if tPix contains "calc" then
            put offset("+",tPix) into tPlusChar -- assume a space after plus
            put offset("px",tPix) into tPXChar
            put char tPlusChar + 2 to tPXChar -1 of tPix into tPix
            put 50 into tShift -- xxx what I'm using in development
            add tShift to tPix
         else
            repeat 3 times -- delete px;
               delete the last char of tPix
            end repeat
         end if
         
         --          -- xxx NEED TO DO THIS IF DO NOT CHECK FOR CALC()
         --          repeat 3 times -- delete px;
         --             delete the last char of tPix
         --          end repeat
         
         switch tProp
            case "width"
               set the width of button tMenuBtn to tPix
               break
            case "height"
               set the height of button tMenuBtn to tPix
               break
            case "left"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tPix into item 1 of tTopLeft -- save, don't set topLeft yet
               -- save, setting height & width changes topLeft
               set the itemDelimiter to colon
               break
            case "top"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tPix into item 2 of tTopLeft -- save, don't set topLeft yet
               -- save, setting height & width first changes topLeft
               set the itemDelimiter to colon
               break
            case "font-size"
               set the textSize of button tMenuBtn to tPix
               break
         end switch
      end repeat
   end if
   -- do this after setting width and height since setting those changes topLeft
   -- first get topLeft of group relative to LC card topLeft
   if the last line of oGrpLocList is empty then delete the last line of oGrpLocList -- in case of LF and empty line
   if the last line of oGrpLocList is not empty then
      put the last line of oGrpLocList into tLast
      put LF & "tLast = last line of oGrpLocList = " & tLast after msg
      set the itemDelimiter to comma
      add item 1 of tLast to item 1 of tTopLeft
      add item 2 of tLast to item 2 of tTopLeft
   end if
   
   put LF & "just before set the topLeft of button tMenuBtn to tTopLeft" after msg
   put LF & "tMenuBtn = " & tMenuBtn && ";" && "tTopLeft = " & tTopLeft & LF after msg
   
   set the topLeft of button tMenuBtn to tTopLeft
   
   put LF & "just before end fImportMenuButton" & LF after msg 
   -- update tSkipChar
   put offset("</select>",oHtmlFileData,tSkipChar) into tEndSelectTagChar
   add tEndSelectTagChar to tSkipChar
   put offset(">",oHtmlFileData,tSkipChar) into tEndSelectTagChar
   add tEndSelectTagChar to tSkipChar
   return tSkipChar
end fImportMenuButton

-----------------------------

function fImportImage tSkipChar
   put LF & "enter fImportImage" & LF after msg
   -- EXAMPLE: <img id="image_robo_99_png_1059" src="images/robo 99.png"> 
   -- tSkipChar points to < of <img
   -- need to return updated tSkipChar
   
   -- GET ID - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   put offset("id=",oHtmlFileData,tSkipChar) into tIDstartChar
   add tSkipChar to tIDstartChar -- char at i of id=
   add 4 to tIDstartChar -- char just inside " of id="
   put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
   subtract 1 from tIDendChar -- step back before quote
   add tIDstartChar to tIDendChar
   put char tIDstartChar to tIDendChar of oHtmlFileData into tID
   put LF & "tID = " & tID after msg -- development field
   
   put tID into tImage -- will use both tID and tImage below
   replace "_" with space in tImage
   -- "image" added in export, others added later might not have it
   if word 1 of tImage is "image" then delete word 1 of tImage 
   put LF & "JUST BEFORE CREATE IMAGE tImage = " & tImage after msg
   create image tImage
   -- set the showBorder of image tImage to true -- during development if need to see rect
   put LF & "JUST AFTER CREATE IMAGE tImage = " & tImage after msg
   
   -- GET SRC ATTRIBUTE - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   put offset("src=",oHtmlFileData,tSkipChar) into tIDstartChar
   add tSkipChar to tIDstartChar -- char at i of src=
   add 5 to tIDstartChar -- char just inside " of src=" -- was 4 for id="
   put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
   subtract 1 from tIDendChar -- step back before quote
   add tIDstartChar to tIDendChar
   put char tIDstartChar to tIDendChar of oHtmlFileData into tSRC
   put LF & "tSRC = " & tSRC after msg -- development field
   
   set the cFilename of image tImage to tSRC -- xxx may want to use this on export
   
   -- for files in images folder, put copy of images folder with this image
   -- at level of the maker stack
   set the filename of image tImage to tSRC
   
   -- GET CSS INFO - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   -- xxx problems if "#" & tID mentioned in a comment!
   -- DO NOT USE tSkipChar for CSS
   put empty into tCssData
   if oCssFileData is not empty then
      put offset("#" & tID,oCssFileData) into tStartChar
      put offset("}",oCssFileData,tStartChar) into tEndChar
      add tStartChar to tEndChar
      put char tStartChar to tEndChar of oCssFileData into tCssData
      put LF & tCssData & LF after msg -- development field
   end if
   
   if tCssData is not empty then
      -- assume top and bottom lines don't have data but the other lines do
      
      set the itemDelimiter to colon
      repeat for each line n in tCssData
         if n contains "#" then next repeat
         if n contains "}" then exit repeat
         put word 1 of item 1 of n into tProp -- so don't get spaces
         put item 2 of n into tPix
         
         -- watch out for a calc();
         if tPix contains "calc" then
            put offset("+",tPix) into tPlusChar -- assume a space after plus
            put offset("px",tPix) into tPXChar
            put char tPlusChar + 2 to tPXChar -1 of tPix into tPix
            put 50 into tShift -- xxx what I'm using in development
            add tShift to tPix
         else
            repeat 3 times -- delete px;
               delete the last char of tPix
            end repeat
         end if
         
         --          -- xxx NEED TO DO THIS IF DO NOT CHECK FOR CALC()
         --          repeat 3 times -- delete px;
         --             delete the last char of tPix
         --          end repeat
         
         switch tProp
            case "width"
               set the width of image tImage to tPix
               break
            case "height"
               set the height of image tImage to tPix
               break
            case "left"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tPix into item 1 of tTopLeft -- save, don't set topLeft yet
               -- save, setting height & width changes topLeft
               set the itemDelimiter to colon
               break
            case "top"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tPix into item 2 of tTopLeft -- save, don't set topLeft yet
               -- save, setting height & width first changes topLeft
               set the itemDelimiter to colon
               break
            case "font-size"
               set the textSize of image tImage to tPix
               break
         end switch
      end repeat
   end if
   -- do this after setting width and height since setting those changes topLeft
   -- first get topLeft of group relative to LC card topLeft
   if the last line of oGrpLocList is empty then delete the last line of oGrpLocList -- in case of LF and empty line
   if the last line of oGrpLocList is not empty then
      put the last line of oGrpLocList into tLast
      put LF & "tLast = last line of oGrpLocList = " & tLast after msg
      set the itemDelimiter to comma
      add item 1 of tLast to item 1 of tTopLeft
      add item 2 of tLast to item 2 of tTopLeft
   end if
   
   put LF & "just before set the topLeft of image tImage to tTopLeft" after msg
   put LF & "tImage = " & tImage && ";" && "tTopLeft = " & tTopLeft & LF after msg
   
   set the topLeft of image tImage to tTopLeft
   
   -- update and return tSkipChar
   put offset(">",oHtmlFileData,tSkipChar) into tTagEndChar
   add tTagEndChar to tSkipChar
   return tSkipChar
end fImportImage

-----------------------------

function fImportLockedField tSkipChar
   put LF & "enter fImportLockedField" & LF after msg
   -- <p> tag = locked field
   -- tSkipChar points to < of <p
   -- need to return updated tSkipChar
   
   -- GET ID - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   put offset(">",oHtmlFileData,tSkipChar) into tPendChar
   add tSkipChar to tPendChar 
   put offset("id=",oHtmlFileData,tSkipChar) into tIDstartChar
   add tSkipChar to tIDstartChar -- char at i of id=
   add 4 to tIDstartChar -- char just inside " of id="
   put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
   subtract 1 from tIDendChar -- step back before quote
   add tIDstartChar to tIDendChar
   put char tIDstartChar to tIDendChar of oHtmlFileData into tID
   put LF & tID after msg -- development field
   
   put tID into tField -- will use both tID and tField below
   replace "_" with space in tField
   -- "field" added in export, others added later might not have it
   if word 1 of tField is "field" then delete word 1 of tField 
   put LF & "JUST BEFORE CREATE FIELD tField = " & tField after msg
   create field tField
   put LF & "JUST AFTER CREATE FIELD tField = " & tField after msg
   
   set the textAlign of field tField to left -- xxx may be set in p {} in css, also include in switch below
   set the lockText of field tField to true
   
   -- get <p> tag (locked field) contents
   put offset("</p",oHtmlFileData,tSkipChar) into tPendTagChar
   add tSkipChar to tPendTagChar
   put tPendTagChar into tSkipChar
   put char tPendChar+1 to tPendTagChar-1 of oHtmlFileData into tPcontents
   
   put fStripOuterSpace(tPcontents) into tPcontents -- e.g., strip spaces
   
   set the htmlText of field tField to tPcontents
   -- xxx BUT WHAT WILL HAPPEN WITH LINKS WHEN EXPORTED?
   
   -- GET CSS INFO - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   -- xxx problems if "#" & tID mentioned in a comment!
   -- DO NOT USE tSkipChar for CSS
   put empty into tCssData
   if oCssFileData is not empty then
      put offset("#" & tID,oCssFileData) into tStartChar
      put offset("}",oCssFileData,tStartChar) into tEndChar
      add tStartChar to tEndChar
      put char tStartChar to tEndChar of oCssFileData into tCssData
      put LF & tCssData & LF after msg -- development field
   end if
   
   if tCssData is not empty then
      -- assume top and bottom lines don't have data but the other lines do
      
      set the itemDelimiter to colon
      repeat for each line n in tCssData
         if n contains "#" then next repeat
         if n contains "}" then exit repeat
         put word 1 of item 1 of n into tProp -- so don't get spaces
         put item 2 of n into tPix
         
         -- watch out for a calc();
         if tPix contains "calc" then
            put offset("+",tPix) into tPlusChar -- assume a space after plus
            put offset("px",tPix) into tPXChar
            put char tPlusChar + 2 to tPXChar -1 of tPix into tPix
            put 50 into tShift -- xxx what I'm using in development
            add tShift to tPix
         else
            repeat 3 times -- delete px;
               delete the last char of tPix
            end repeat
         end if
         
         --          -- xxx NEED TO DO THIS IF DO NOT CHECK FOR CALC()
         --          repeat 3 times -- delete px;
         --             delete the last char of tPix
         --          end repeat
         
         -- xxx NEED TO CHECK FOR OTHER PROPS SUCH AS FONT SIZE 
         
         switch tProp
            case "width"
               set the width of field tField to tPix
               break
            case "height"
               set the height of field tField to tPix
               break
            case "left"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tPix into item 1 of tTopLeft -- save, don't set topLeft yet
               -- save, need to add container group left & setting height & width changes topLeft
               set the itemDelimiter to colon
               break
            case "top"
               -- xxx for locked fields only, EXPORT subtracts a constant (16) from top before 
               -- xxx      writing <p> to CSS, reverse here
               add 16 to tPix -- xxx add a variable so a change in EXPORT appears here in IMPORT
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tPix into item 2 of tTopLeft -- save, don't set topLeft yet
               -- save, need to add container group left & setting height & width first changes topLeft
               set the itemDelimiter to colon
               break
            case "font-size"
               set the textSize of field tField to tPix
               break
         end switch
      end repeat
   end if
   -- do this after setting width and height since setting those changes topLeft
   -- first get topLeft of group relative to LC card topLeft
   if the last line of oGrpLocList is empty then delete the last line of oGrpLocList -- in case of LF and empty line
   if the last line of oGrpLocList is not empty then
      put the last line of oGrpLocList into tLast
      put LF & "tLast = last line of oGrpLocList = " & tLast after msg
      set the itemDelimiter to comma
      add item 1 of tLast to item 1 of tTopLeft
      add item 2 of tLast to item 2 of tTopLeft
   end if
   
   put LF & "just before set the topLeft of field tField to tTopLeft" after msg
   put LF & "tField = " & tField && ";" && "tTopLeft = " & tTopLeft after msg
   
   set the topLeft of field tField to tTopLeft
   
   put LF & "just before end of fImportLockedField" & LF after msg
   
   -- return updated tSkipChar
   -- which was updated above in fImportLockedField
   return tSkipChar
end fImportLockedField

---------------------------------

function fImportInputTag tSkipChar
   put LF & "enter fImportInputTag" & LF after msg
   get fReporter(tSkipChar)
   -- tSkipChar points to < of <input
   -- imports <input that is not inside <label tags
   -- uses 3 functions: fImportUnlockedField, fImportButton, fImportScrollbar
   
   -- get type attribute if any - if no type then input for unlocked field
   -- attributes can be in any order
   put offset("type",oHtmlFileData,tSkipChar) into tTypeChar
   put LF & "offset gives tTypeChar before add skip = " & tTypeChar after msg
   add tSkipChar to tTypeChar
   put offset(">",oHtmlFileData,tSkipChar) into tEndChar
   put LF & "offset gives tEndChar before add skip = " & tEndChar after msg
   add tSkipChar to tEndChar -- tEndChar put into tSkipChar at end this function
   put LF & "tTypeChar = " & tTypeChar && "tEndChar = " & tEndChar after msg
   if tTypeChar > tEndChar or tTypeChar = tSkipChar then -- tTypeChar = 0 if no more types in file
      put LF & "(tTypeChar > tEndChar or tTypeChar = tSkipChar) so no type" after msg
      -- input tag does not have a type attribute
      -- so input tag is for an unlocked field
      get fImportUnlockedField(tSkipChar)
      -- don't do anything with return, update tSkipChar below
   else
      put LF & "(tTypeChar NOT > tEndChar AND tTypeChar NOT = tSkipChar) so there IS a type" after msg
      -- input tag has a type attribute
      -- check what type attribute is
      -- xxx ASSUME type="typename" FOLLOWED BY SPACE OR >
      -- xxx was having problems using offset to find quote
      put offset(space,oHtmlFileData,tTypeChar) into tSpaceChar
      put LF & "tSpaceChar before add tTypeChar = " & tSpaceChar after msg
      add tTypeChar to tSpaceChar
      put offset(">",oHtmlFileData,tTypeChar) into tEndChar -- tEndChar changed from that above
      put LF & "tEndChar before add tTypeChar = " & tEndChar after msg
      add tTypeChar to tEndChar
      if tSpaceChar < tEndChar then
         -- assume have type="typename" immediately followed by space
         put LF & "tSpaceChar = " & tSpaceChar & " < tEndChar = " & tEndChar after msg
         put char tTypeChar+6 to tSpaceChar-2 of oHtmlFileData into tType
      else
         -- assume have type="typename" immediately followed by >
         put LF & "tSpaceChar = " & tSpaceChar & " > tEndChar = " & tEndChar after msg
         put char tTypeChar+6 to tEndChar-2 of oHtmlFileData into tType
      end if
      put LF & "tType = " & tType after msg
      switch tType
         case "button"
            get fImportButton(tSkipChar)
            -- don't do anything with return, update tSkipChar below
            break
         case "range"
            get fImportScrollbar(tSkipChar)
            -- don't do anything with return, update tSkipChar below
            break
         default
            -- put LF & "at parent input tag but no known type found" & LF after msg
      end switch
   end if
   
   put LF & "just before end fImportInputTag" & LF after msg
   
   -- return updated tSkipChar
   put tEndChar into tSkipChar -- tEndChar for > found above
   return tSkipChar
end fImportInputTag

-------------------------------

function fImportUnlockedField tSkipChar
   put LF & "enter fImportUnlockedField" & LF after msg
   -- tSkipChar points to < of parent <input, no need to return, updated at end fImportInputTag
   -- called by function fImportInputTag
   -- LC unlocked fields are for HTML input tag with no type attribute for input fields
   -- EXAMPLE:  <input id="input_field_enterKflow_1203" value="0.04" onchange="puCatalystLayer.updateUIparams()"></input>
   
   -- GET ID - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   put offset(">",oHtmlFileData,tSkipChar) into tPendChar
   add tSkipChar to tPendChar 
   put offset("id=",oHtmlFileData,tSkipChar) into tIDstartChar
   add tSkipChar to tIDstartChar -- char at i of id=
   add 4 to tIDstartChar -- char just inside " of id="
   put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
   subtract 1 from tIDendChar -- step back before quote
   add tIDstartChar to tIDendChar
   put char tIDstartChar to tIDendChar of oHtmlFileData into tID
   put LF & "tID = " & tID after msg -- development field
   
   -- GET VALUE
   put offset("value=",oHtmlFileData,tSkipChar) into tIDstartChar
   add tSkipChar to tIDstartChar -- char at v of "value="
   add 7 to tIDstartChar -- char just inside "value="
   put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
   subtract 1 from tIDendChar -- step back before quote
   add tIDstartChar to tIDendChar
   put char tIDstartChar to tIDendChar of oHtmlFileData into tValue
   put LF & "tValue= " & tValue after msg
   -- GET ONCHANGE
   put offset("onchange=",oHtmlFileData,tSkipChar) into tIDstartChar
   if tIDstartChar > 1 then
      add tSkipChar to tIDstartChar -- char at o of "onchange="
      add 10 to tIDstartChar -- char just inside "onchange=" -- xxx for onclick in button, add 9 
      put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
      subtract 1 from tIDendChar -- step back before quote
      add tIDstartChar to tIDendChar
      put char tIDstartChar to tIDendChar of oHtmlFileData into tOnchange
      put LF & "tOnchange= " & tOnchange after msg
   else
      put LF & "NO onchange found" after msg
   end if
   
   put tID into tField -- will use both tID and tField below
   replace "_" with space in tField
   -- "input" added in export of unlocked field, others added later might not have it
   if word 1 of tField is "input" then delete word 1 of tField 
   put LF & "JUST BEFORE CREATE FIELD tField = " & tField after msg
   create field tField
   put LF & "JUST AFTER CREATE FIELD tField = " & tField after msg
   
   set the textAlign of field tField to left -- xxx may be set in p {} in css, also include in switch below
   set the lockText of field tField to false
   
   set the text of field tField to tValue
   set the cOnchange of field tField to tOnchange -- xxx need to add this to EXPORT script
   
   -- GET CSS INFO - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   -- xxx problems if "#" & tID mentioned in a comment!
   -- DO NOT USE tSkipChar for CSS
   put empty into tCssData
   if oCssFileData is not empty then
      put offset("#" & tID,oCssFileData) into tStartChar
      put offset("}",oCssFileData,tStartChar) into tEndChar
      add tStartChar to tEndChar
      put char tStartChar to tEndChar of oCssFileData into tCssData
      put LF & tCssData & LF after msg -- development field
   end if
   
   if tCssData is not empty then
      -- assume top and bottom lines don't have data but the other lines do
      
      set the itemDelimiter to colon
      repeat for each line n in tCssData
         if n contains "#" then next repeat
         if n contains "}" then exit repeat
         put word 1 of item 1 of n into tProp -- so don't get spaces
         put item 2 of n into tPix
         
         -- watch out for a calc();
         if tPix contains "calc" then
            put offset("+",tPix) into tPlusChar -- assume a space after plus
            put offset("px",tPix) into tPXChar
            put char tPlusChar + 2 to tPXChar -1 of tPix into tPix
            put 50 into tShift -- xxx what I'm using in development
            add tShift to tPix
         else
            repeat 3 times -- delete px;
               delete the last char of tPix
            end repeat
         end if
         
         --          -- xxx NEED TO DO THIS IF DO NOT CHECK FOR CALC()
         --          repeat 3 times -- delete px;
         --             delete the last char of tPix
         --          end repeat
         
         -- xxx NEED TO CHECK FOR OTHER PROPS SUCH AS FONT SIZE 
         
         switch tProp
            case "width"
               set the width of field tField to tPix
               break
            case "height"
               set the height of field tField to tPix
               break
            case "left"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tPix into item 1 of tTopLeft -- save, don't set topLeft yet
               -- save, need to add container group left & setting height & width changes topLeft
               set the itemDelimiter to colon
               break
            case "top"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tPix into item 2 of tTopLeft -- save, don't set topLeft yet
               -- save, need to add container group left & setting height & width first changes topLeft
               set the itemDelimiter to colon
               break
            case "font-size"
               set the textSize of field tField to tPix
               break
         end switch
      end repeat
   end if
   -- do this after setting width and height since setting those changes topLeft
   -- first get topLeft of group relative to LC card topLeft
   if the last line of oGrpLocList is empty then delete the last line of oGrpLocList -- in case of LF and empty line
   if the last line of oGrpLocList is not empty then
      put the last line of oGrpLocList into tLast
      put LF & "tLast = last line of oGrpLocList = " & tLast after msg
      set the itemDelimiter to comma
      add item 1 of tLast to item 1 of tTopLeft
      add item 2 of tLast to item 2 of tTopLeft
   end if
   
   put LF & "just before set the topLeft of field tField to tTopLeft" after msg
   put LF & "tField = " & tField && ";" && "tTopLeft = " & tTopLeft after msg
   
   set the topLeft of field tField to tTopLeft
   
   put LF & "just before end of fImportUnlockedField" & LF after msg
   return empty -- no need to return tSkipChar
end fImportUnlockedField

-------------------------------

function fImportButton tSkipChar
   put LF & "enter fImportButton" & LF after msg
   -- tSkipChar points to < of parent <input, no need to return, updated at end fImportInputTag
   -- called by function fImportInputTag
   -- EXAMPLE: <input type="button" id="button_resetButton_1177" value="Reset" onclick="resetThisLab()"></input>
   -- GET ID - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   put offset("id=",oHtmlFileData,tSkipChar) into tIDstartChar
   add tSkipChar to tIDstartChar -- char at i of id=
   add 4 to tIDstartChar -- char just inside " of id="
   put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
   subtract 1 from tIDendChar -- step back before quote
   add tIDstartChar to tIDendChar
   put char tIDstartChar to tIDendChar of oHtmlFileData into tID 
   put LF & "tID = " & tID after msg
   -- tID used below in GET CSS
   put tID into tButton
   replace "_" with space in tButton
   -- "button" added in export, others added later might not have it
   if word 1 of tButton is "button" then delete word 1 of tButton
   -- xxx for now keep the original id number
   -- GET VALUE
   put offset("value=",oHtmlFileData,tSkipChar) into tIDstartChar
   add tSkipChar to tIDstartChar -- char at v of "value="
   add 7 to tIDstartChar -- char just inside "value="
   put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
   subtract 1 from tIDendChar -- step back before quote
   add tIDstartChar to tIDendChar
   put char tIDstartChar to tIDendChar of oHtmlFileData into tValue
   put LF & "tValue= " & tValue after msg
   -- GET ONCLICK
   put offset("onclick=",oHtmlFileData,tSkipChar) into tIDstartChar
   if tIDstartChar > 1 then
      add tSkipChar to tIDstartChar -- char at o of "onclick="
      add 9 to tIDstartChar -- char just inside "onclick="  -- for onchange in unlocked input field, add 10
      put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
      subtract 1 from tIDendChar -- step back before quote
      add tIDstartChar to tIDendChar
      put char tIDstartChar to tIDendChar of oHtmlFileData into tOnclick
      put LF & "tOnclick= " & tOnclick after msg
   else
      put LF & "NO onclick found" after msg
   end if
   
   -- CREATE BUTTON
   create button
   set the name of it to tButton
   set the label of button tButton to tValue
   set the cOnclick of button tButton to tOnclick -- xxx add this to EXPORT
   
   -- GET CSS INFO - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   -- xxx problems if "#" & tID mentioned in a comment!
   -- DO NOT USE tSkipChar for CSS
   put empty into tCssData
   if oCssFileData is not empty then
      put offset("#" & tID,oCssFileData) into tStartChar
      put offset("}",oCssFileData,tStartChar) into tEndChar
      add tStartChar to tEndChar
      put char tStartChar to tEndChar of oCssFileData into tCssData
      put LF & tCssData & LF after msg -- development field
   end if
   
   if tCssData is not empty then
      -- assume top and bottom lines don't have data but the other lines do
      
      set the itemDelimiter to colon
      repeat for each line n in tCssData
         if n contains "#" then next repeat
         if n contains "}" then exit repeat
         put word 1 of item 1 of n into tProp -- so don't get spaces
         put item 2 of n into tPix
         
         -- watch out for a calc();
         if tPix contains "calc" then
            put offset("+",tPix) into tPlusChar -- assume a space after plus
            put offset("px",tPix) into tPXChar
            put char tPlusChar + 2 to tPXChar -1 of tPix into tPix
            put 50 into tShift -- xxx what I'm using in development
            add tShift to tPix
         else
            repeat 3 times -- delete px;
               delete the last char of tPix
            end repeat
         end if
         
         --          -- xxx NEED TO DO THIS IF DO NOT CHECK FOR CALC()
         --          repeat 3 times -- delete px;
         --             delete the last char of tPix
         --          end repeat
         
         -- xxx NEED TO CHECK FOR OTHER PROPS SUCH AS FONT SIZE 
         
         switch tProp
            case "width"
               set the width of button tButton to tPix
               break
            case "height"
               set the height of button tButton to tPix
               break
            case "left"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tPix into item 1 of tTopLeft -- save, don't set topLeft yet
               -- save, need to add container group left & setting height & width changes topLeft
               set the itemDelimiter to colon
               break
            case "top"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tPix into item 2 of tTopLeft -- save, don't set topLeft yet
               -- save, need to add container group left & setting height & width first changes topLeft
               set the itemDelimiter to colon
               break
            case "font-size"
               set the textSize of button tButton to tPix
               break
         end switch
      end repeat
   end if
   -- do this after setting width and height since setting those changes topLeft
   -- first get topLeft of group relative to LC card topLeft
   if the last line of oGrpLocList is empty then delete the last line of oGrpLocList -- in case of LF and empty line
   if the last line of oGrpLocList is not empty then
      put the last line of oGrpLocList into tLast
      put LF & "tLast = last line of oGrpLocList = " & tLast after msg
      set the itemDelimiter to comma
      add item 1 of tLast to item 1 of tTopLeft
      add item 2 of tLast to item 2 of tTopLeft
   end if
   
   put LF & "JUST BEFORE set the topLeft of button tButton to tTopLeft" after msg
   put LF & "tButton = " & tButton && ";" && "tTopLeft = " & tTopLeft after msg
   
   set the topLeft of button tButton to tTopLeft
   
   put LF & "just before end fImportButton" & LF after msg
   return empty -- no need to return tSkipChar
end fImportButton

------------------------------- 

function fImportScrollbar tSkipChar
   put LF & "enter fImportScrollbar" & LF after msg
   -- tSkipChar points to < of parent <input, no need to return, updated at end fImportInputTag
   -- called by function fImportInputTag
   -- EXAMPLE: <input type="range" id="range_setCmax_slider_1200" min="0" max="1" step="0.01" value="1"
   --                          oninput = "puCatalystLayer.updateUIparams()"></input>
   
   -- GET ID - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   put offset(">",oHtmlFileData,tSkipChar) into tPendChar
   add tSkipChar to tPendChar 
   put offset("id=",oHtmlFileData,tSkipChar) into tIDstartChar
   add tSkipChar to tIDstartChar -- char at i of id=
   add 4 to tIDstartChar -- char just inside " of id="
   put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
   subtract 1 from tIDendChar -- step back before quote
   add tIDstartChar to tIDendChar
   put char tIDstartChar to tIDendChar of oHtmlFileData into tID
   put LF & "tID = " & tID after msg -- development field
   
   -- tID used below in GET CSS
   put tID into tScrollbar
   replace "_" with space in tScrollbar
   -- "range" added in export, others added later might not have it
   if word 1 of tScrollbar is "range" then delete word 1 of tScrollbar
   -- xxx for now keep the original id number
   
   -- GET VALUE
   put offset("value=",oHtmlFileData,tSkipChar) into tIDstartChar
   add tSkipChar to tIDstartChar -- char at v of "value="
   add 7 to tIDstartChar -- char just inside "value="
   put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
   subtract 1 from tIDendChar -- step back before quote
   add tIDstartChar to tIDendChar
   put char tIDstartChar to tIDendChar of oHtmlFileData into tValue
   put LF & "tValue= " & tValue after msg
   
   -- GET ONINPUT
   put offset("oninput=",oHtmlFileData,tSkipChar) into tIDstartChar
   if tIDstartChar > 1 then
      add tSkipChar to tIDstartChar -- char at o of "oninput="
      add 9 to tIDstartChar -- char just inside "oninput=" -- xxx for onclick in button, add 9 
      put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
      subtract 1 from tIDendChar -- step back before quote
      add tIDstartChar to tIDendChar
      put char tIDstartChar to tIDendChar of oHtmlFileData into tOninput
      put LF & "tOninput= " & tOninput after msg
   else
      put LF & "NO tOninput found" after msg
   end if
   
   -- GET MIN
   put offset("min=",oHtmlFileData,tSkipChar) into tIDstartChar
   if tIDstartChar > 1 then
      add tSkipChar to tIDstartChar -- char at m of "min="
      add 5 to tIDstartChar -- char just inside "min=" -- for onclick in button, add 9 
      put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
      subtract 1 from tIDendChar -- step back before quote
      add tIDstartChar to tIDendChar
      put char tIDstartChar to tIDendChar of oHtmlFileData into tMin
      put LF & "tMin= " & tMin after msg
   else
      put LF & "NO tMin found" after msg
   end if
   
   -- GET MIN
   put offset("max=",oHtmlFileData,tSkipChar) into tIDstartChar
   if tIDstartChar > 1 then
      add tSkipChar to tIDstartChar -- char at m of "max="
      add 5 to tIDstartChar -- char just inside "max=" -- for onclick in button, add 9 
      put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
      subtract 1 from tIDendChar -- step back before quote
      add tIDstartChar to tIDendChar
      put char tIDstartChar to tIDendChar of oHtmlFileData into tMax
      put LF & "tMax= " & tMax after msg
   else
      put LF & "NO tMax found" after msg
   end if
   
   -- GET STEP
   put offset("step=",oHtmlFileData,tSkipChar) into tIDstartChar
   if tIDstartChar > 1 then
      add tSkipChar to tIDstartChar -- char at s of "step="
      add 6 to tIDstartChar -- char just inside "step=" -- for onclick in button, add 9 
      put offset(quote,oHtmlFileData,tIDstartChar) into tIDendChar
      subtract 1 from tIDendChar -- step back before quote
      add tIDstartChar to tIDendChar
      put char tIDstartChar to tIDendChar of oHtmlFileData into tStep
      put LF & "tStep= " & tStep after msg
   else
      put LF & "NO tStep found" after msg
   end if
   
   create scrollbar tScrollbar
   set the style of scrollbar tScrollbar to scale
   
   -- GET CSS INFO - SEE SIMILAR IN OTHER SECTIONS - MAKE INTO FUNCTION
   -- xxx problems if "#" & tID mentioned in a comment!
   -- DO NOT USE tSkipChar for CSS
   put empty into tCssData
   if oCssFileData is not empty then
      put offset("#" & tID,oCssFileData) into tStartChar
      put offset("}",oCssFileData,tStartChar) into tEndChar
      add tStartChar to tEndChar
      put char tStartChar to tEndChar of oCssFileData into tCssData
      put LF & tCssData & LF after msg -- development field
   end if
   
   if tCssData is not empty then
      -- assume top and bottom lines don't have data but the other lines do
      
      set the itemDelimiter to colon
      put false into tTransformFlag -- used to check if range is rotated in CSS
      repeat for each line n in tCssData
         if n contains "#" then next repeat
         if n contains "}" then exit repeat
         put word 1 of item 1 of n into tProp -- so don't get spaces
         put item 2 of n into tPix
         
         -- watch out for a calc();
         if tPix contains "calc" then
            put offset("+",tPix) into tPlusChar -- assume a space after plus
            put offset("px",tPix) into tPXChar
            put char tPlusChar + 2 to tPXChar -1 of tPix into tPix
            put 50 into tShift -- xxx what I'm using in development
            add tShift to tPix
         else
            repeat 3 times -- delete px;
               delete the last char of tPix
            end repeat
         end if
         
         --          -- xxx NEED TO DO THIS IF DO NOT CHECK FOR CALC()
         --          repeat 3 times -- delete px;
         --             delete the last char of tPix
         --          end repeat
         
         -- xxx NEED TO CHECK FOR OTHER PROPS SUCH AS FONT SIZE 
         
         switch tProp
            case "width"
               -- xxx set the width of button tButton to tPix
               -- xxx special for scrollbar, save for below, may change for vertical orientation
               put tPix into tWidth
               break
            case "height"
               -- xxx set the height of button tButton to tPix
               -- xxx special for scrollbar, save for below, may change for vertical orientation
               put tPix into tHeight
               break
            case "left"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tPix into item 1 of tTopLeft -- save, don't set topLeft yet
               -- save, need to add container group left & setting height & width changes topLeft
               set the itemDelimiter to colon
               break
            case "top"
               set the itemDelimiter to comma
               -- order in LC topLeft is left,top!
               put tPix into item 2 of tTopLeft -- save, don't set topLeft yet
               -- save, need to add container group left & setting height & width first changes topLeft
               set the itemDelimiter to colon
               break
            case "font-size"
               set the textSize of button tButton to tPix
               break
            case "transform"
               -- used when rotate horizontal range to vertical in CSS
               put LF & "SCROLLBAR TRANSFORM DETECTED" after msg
               put true into tTransformFlag
               break
         end switch
      end repeat
   end if
   -- TOPLEFT WILL HAVE TO BE MODIFIED IF CSS ROTATES RANGE & tTransformFlag is true
   -- do this after setting width and height since setting those changes topLeft
   -- get topLeft of group relative to LC card topLeft
   if the last line of oGrpLocList is empty then delete the last line of oGrpLocList -- in case of LF and empty line
   if the last line of oGrpLocList is not empty then
      put the last line of oGrpLocList into tLast
      put LF & "tLast = last line of oGrpLocList = " & tLast after msg
      set the itemDelimiter to comma
      add item 1 of tLast to item 1 of tTopLeft
      add item 2 of tLast to item 2 of tTopLeft
   end if
   
   if tTransformFlag is true then
      -- CSS/HTML range started out as horiz then transformed by rotation 90 deg about center
      put LF & "tTransformFlag is true" after msg
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
   
   set the width of scrollbar tScrollbar to tWidth
   set the height of scrollbar tScrollbar to tHeight
   set the topLeft of scrollbar tScrollbar to tTopLeft
   
   if tTransformFlag is true then
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
   set the cOninput of scrollbar tScrollbar to tOninput
   
   put LF & "just before end fImportScrollbar" & LF after msg
   return empty -- no need to return tSkipChar
end fImportScrollbar

-------------------------------

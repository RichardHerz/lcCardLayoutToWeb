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
APPROACH
work on one type of control at a time
write function that generates the LC control and sets its properties
SAVE FOR WRITE AT OUTPUT 
all text in html file before <body>
where to save, maybe in custom prop of a button whose name includes the save to web kill word?
then write </body></html> at end of output
TAGS TO HANDLE 
div = group 
img = image
p = locked field 
select = menu button
input with no type = unlocked field
input with type="button" = button
input with type="range" = slider
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
   answer file "select HTML file"
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
      answer file "select CSS file"
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
   
   -- xxx problems occur when, inside comments in html or css,
   -- xxx tags and id's are mentioned
   -- xxx maybe set a flag when start of comment detected and
   -- xxx ignore all until end of comment detected...
   -- xxx may need to read all css file in at once and reject comments
   -- xxx when getting properties
   -- xxx and probably should save comments somehow?
   
   repeat
      put offset("<",oHtmlFileData,tSkipChar) into tNextTagStart
      if tNextTagStart is 0 then exit repeat
      add tNextTagStart to tSkipChar
      put tSkipChar into tNextTagStart
      -- char which can occur after <tag is ">" or space & "id="
      -- char which can occur after </tagName> is space or < or LF 
      -- am I only interested in tags with this:  <tagName id="...
      put offset(space & "id=",oHtmlFileData,tSkipChar) into tNextIDchar
      -- but could be <tag id= down the line...
      -- make sure it's not past end this tag
      put offset(">",oHtmlFileData,tSkipChar) into tNextEndChar
      if tNextEndChar < tNextIDchar then
         -- not a tag with id
         -- check for </div>
         if offset("/div>",oHtmlFileData,tSkipChar) = 1 then -- tSkipChar points to < of </div>
            put fImportGroupEnd(tSkipChar) into tSkipChar
         end if
      else
         -- tag with id
         add tNextIDchar to tSkipChar -- points to space of space & id=
         put tSkipChar into tNextIDchar
         put char tNextTagStart + 1 to tNextIDchar - 1 of oHtmlFileData into tTagName
         switch tTagName
            case "div"
               -- import div = group
               put fImportGroupStart(tSkipChar) into tSkipChar
               break
            case "img"
               -- import img = image
               break
            case "p"
               -- import p = locked field
               put fImportLockedField(tSkipChar) into tSkipChar
               break
            case "select"
               -- import select = menu button
               break
            case "input"
               -- import input that are not inside <label tags
               -- 3 types: none = unlocked field, button = button, range = slider
               break
            case "label"
               -- import label
               -- need to look for <input inside
               -- two input types: checkbox, radio button
               -- <label <input followed by <span
               break
            default
               -- ignore
         end switch
      end if
   end repeat
   
end makeLiveCodeCard

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
   -- input argument tSkipChar points to space char after <div
   -- need to return updated tSkipChar
   
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
   
   put LF & "JUST BEFORE create group " & tIDname & LF after msg
   create group
   set the name of it to tIDname
   put LF & "JUST AFTER create group " & tIDname & LF after msg
   
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
               -- xxx need to account for relative position if inside a div = group!
               set the itemDelimiter to comma
               put tPix into item 1 of tTopLeft -- save, don't set field topLeft yet
               set the itemDelimiter to colon
               break
            case "top"
               -- xxx need to account for relative position if inside a div = group!
               set the itemDelimiter to comma
               put tPix into item 2 of tTopLeft -- save, don't set field topLeft yet
               set the itemDelimiter to colon
               break
         end switch
      end repeat
   end if
   -- do this after setting width and height since setting those changes topLeft
   put LF & "JUST BEFORE set the topLeft of group tIDname to tTopLeft" & LF after msg
   put "group tIDname = " & tIDname & LF after msg
   put "tTopLeft = " & tTopLeft & LF after msg
   set the topLeft of group tIDname to tTopLeft
   set the lockLoc of group tIDname to true -- otherwise will "shrink to fit" contents, which are none at this point
   
   set the showBorder of group tIDname to true -- xxx so can see it in development
   
   -- STORE CUMMULATIVE locations in oGrpLocList
   -- add these locs to locs from line above, if any
   -- then a new control just has to get locs from last line in group list
   if the last line of oGrpLocList is empty then delete the last line of oGrpLocList -- in case of LF and empty line
   if the last line of oGrpLocList is not empty then
      put the last line of oGrpLocList into tLast
      put "tLast = last line of oGrpLocList = " & the last line of oGrpLocList & LF after msg
      set the itemDelimiter to comma
      add item 1 of tLast to item 1 of tTopLeft
      add item 2 of tLast to item 2 of tTopLeft
   end if
   put tTopLeft & LF after oGrpLocList
   put LF & "oGrpLocList = " & LF & oGrpLocList & LF after msg
   
   put LF & "JUST BEFORE start editing group" && tIDname & LF after msg
   start editing group tIDname
   put LF & "JUST AFTER start editing group" && tIDname & LF after msg
   
   return tSkipChar
end fImportGroupStart

----------------------------- 

function fImportGroupEnd tSkipChar
   put LF & "enter fImportGroupEnd" & LF after msg
   -- input argument tSkipChar points to < of </div>
   -- need to return updated tSkipChar
   -- char which can occur after </div> is space or < or LF 
   
   -- THIS NEEDS TO
   --   input list of groups and group topLefts
   --   delete last group from these lists
   --   return the updated list of groups and group topLefts
   
   -- get rid of any empty lines due to LF at end
   if the last line of oGrpList is empty then delete the last line of oGrpList -- in case of LF and empty line
   if the last line of oGrpLocList is empty then delete the last line of oGrpLocList -- in case of LF and empty line
   -- get name of the last group
   put the last line of oGrpList into tGrpName
   
   put LF & "Before delete last line, tGrpName = " & LF & tGrpName & LF after msg
   
   put LF & "Before delete last line, oGrpList = " & LF & oGrpList & LF after msg
   
   -- delete the last line with info about group
   if oGrpList is not empty then delete the last line of oGrpList
   if oGrpLocList is not empty then delete the last line of oGrpLocList
   
   -- MUST USE "BACKGROUND" HERE AND NOT "GROUP"
   put LF & "the name of this background = " & the name of this background & LF after msg
   
   if oGrpList is empty then
      -- ending top level group
      -- when not in a group in a group, can't use group name when stopping
      put LF & "JUST BEFORE stop editing" & LF after msg
      stop editing
      put LF & "stop editing" & LF after msg
   else
      -- MUST USE "BACKGROUND" HERE WHEN STOPPING EDIT OF GROUP AND NOT "GROUP"
      put LF & "JUST BEFORE stop editing background" && tGrpName & LF after msg
      stop editing background tGrpName
      put LF & "stop editing background" && tGrpName & LF after msg
   end if
   
   -- get tSkipChar off this </div>
   add 5 to tSkipChar
   
   return tSkipChar
end fImportGroupEnd

-----------------------------

function fImportLockedField tSkipChar
   put LF & "enter fImportLockedField" & LF after msg
   -- <p> tag = locked field
   -- input argument tSkipChar points to space char after <p
   -- need to return updated tSkipChar
   
   -- THIS NEEDS TO
   --   input topLeft coordinates of the divs/groups 
   --   in which this <p> resides
   --   and also the list in order of the names of the divs in which it resides
   
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
   put LF & "JUST BEFORE CREATE FIELD tField = " & tField & LF after msg
   create field tField
   put LF & "JUST AFTER CREATE FIELD tField = " & tField & LF after msg
   
   -- get <p> tag (locked field) contents
   put offset("</p",oHtmlFileData,tSkipChar) into tPendTagChar
   add tSkipChar to tPendTagChar
   put tPendTagChar into tSkipChar
   put char tPendChar+1 to tPendTagChar-1 of oHtmlFileData into tPcontents
   set the htmlText of field tField to tPcontents
   
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
               set the width of field tField to tPix
               break
            case "height"
               set the height of field tField to tPix
               break
            case "left"
               -- xxx need to account for relative position if inside a div = group!
               set the itemDelimiter to comma
               put tPix into item 1 of tTopLeft -- save, don't set field topLeft yet
               set the itemDelimiter to colon
               break
            case "top"
               -- xxx need to account for relative position if inside a div = group!
               set the itemDelimiter to comma
               put tPix into item 2 of tTopLeft -- save, don't set field topLeft yet
               set the itemDelimiter to colon
               break
         end switch
      end repeat
   end if
   -- do this after setting width and height since setting those changes topLeft
   -- first get topLeft of group relative to LC card topLeft
   if the last line of oGrpLocList is empty then delete the last line of oGrpLocList -- in case of LF and empty line
   if the last line of oGrpLocList is not empty then
      put the last line of oGrpLocList into tLast
      put LF & "tLast = last line of oGrpLocList = " & tLast after msg -- xxx
      set the itemDelimiter to comma
      add item 1 of tLast to item 1 of tTopLeft
      add item 2 of tLast to item 2 of tTopLeft
   end if
   
   put LF & "JUST BEFORE set the topLeft of field tField to tTopLeft" & LF after msg
   put "tField = " & tField && ";" && "tTopLeft = " & tTopLeft & LF after msg
   
   set the topLeft of field tField to tTopLeft
   return tSkipChar
end fImportLockedField

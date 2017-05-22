script "maker-script"
/*
Design, text, images and code by Richard K. Herz, 2017 
Copyrights held by Richard K. Herz
Licensed for use under the GNU General Public License v3.0 
https://www.gnu.org/licenses/gpl-3.0.en.html
*/ 

local oHtmlFileData
local oCssFileData 

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
input with no type = unlocked field
select = menu button
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
   end if
   
   if tCssFile is not empty then
      put "file:" before tCssFile
      put url tCssFile into oCssFileData
   end if
      
   makeLiveCodeCard
   
end importWebPage

-----------------------------

on makeLiveCodeCard
   
   -- uses local variables oHtmlFileData & oCssFileData 
   -- is called by command importWebPage
   
   -- get list of all tags in html data
   put "!" into tEscapeChar
   put 0 into tSkipChar
   put empty into tTagList
   put empty into tNextCharList
   -- WARNING: answer command will format as HTML if include <> in output!
   repeat
      put offset("<",oHtmlFileData,tSkipChar) into tNextTagStart
      if tNextTagStart is 0 then exit repeat
      add tNextTagStart to tSkipChar
      put tSkipChar into tNextTagStart
      put char tNextTagStart + 1 of oHtmlFileData into tNextChar
      put offset(">",oHtmlFileData,tSkipChar) into tNextTagEnd
      add tNextTagEnd to tSkipChar
      put tSkipChar into tNextTagEnd
      if tNextChar is tEscapeChar or tNextChar is "/" then 
         -- ignore this tag
         put "ignore: " &  tNextChar & LF after tTagList
         put "ignore: " & tNextChar & LF after tNextCharList
      else
         put char tNextTagStart+1 to tSkipChar-1 of oHtmlFileData into tNextTagText
         put tNextTagText & LF after tTagList
         put tNextChar & LF after tNextCharList
      end if -- end if tNextChar is "!" or tNextChar is "/"  
   end repeat
   -- WARNING: answer command will format as HTML if include <> in output!
   answer "tTagList = " & LF & tTagList & LF & the number of lines of tTagList
   answer "tNextCharList = " & LF & tNextCharList
   
end makeLiveCodeCard

----------------------------- 

function fGetNextTag startChar
   
   return "huh?"
end fGetNextTag

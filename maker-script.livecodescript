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
   put empty into tEscapeChar
   put 0 into tSkipChar
   put empty into tTagList
   put empty into tNextCharList
   put 0 into tCounter
   repeat while tCounter < 100
      add 1 to tCounter
      put offset("<",oHtmlFileData,tSkipChar) into tNextTagChar
      if tNextTagChar is empty then exit repeat
      add tNextTagChar to tSkipChar
      -- xxx HAVING TROUBLE WITH <!-- NOT FINDING THE !
      put char tSkipChar + 1 of oHtmlFileData into tNextChar
      if tEscapeChar is empty then put tNextChar into tEscapeChar -- assume first is !
      put tNextChar & LF after tNextCharList
      if tNextChar is tEscapeChar or tNextChar is "/" then 
         -- ignore this tag
      else
         put tSkipChar into tNextTagChar
         put offset(space,oHtmlFileData,tSkipChar) into tNextSpaceChar
         add tNextSpaceChar to tSkipChar
         put tSkipChar into tNextSpaceChar
         put char tNextTagChar to tNextSpaceChar of oHtmlFileData into tNextTag
         put tNextTag & LF after tTagList
      end if -- end if tNextChar is "!" or tNextChar is "/"  
   end repeat
   answer tTagList && the number of lines of tTagList
   answer "tNextCharList = " & LF & tNextCharList
   
end makeLiveCodeCard

----------------------------- 

function fGetNextTag startChar
   
   return "huh?"
end fGetNextTag

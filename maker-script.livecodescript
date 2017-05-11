script "maker-script"
on importWebPage
   -- answer file only allows one file to be selected
   -- answer files allows more than one file to be selected and returns paths on separate lines
   answer files "select html and css files"
   if the result is empty then
      put it into tFiles
      answer tFiles
   end if
   
   
end importWebPage

function fGetNextTag startChar
   
   return "huh?"
end fGetNextTag

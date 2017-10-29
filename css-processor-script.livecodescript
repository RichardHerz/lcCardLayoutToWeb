script "css-processor-script"
on expandWidth
   -- uses fields wfac, input, output
   -- uses function fStripOuterSpace
   
   if field "wfac" is empty then 
      put 1.0 into field wfac
      exit expandWidth
   end if
   put field "wfac" into wfac
   put empty into field "output"
   put field "input" into tInput
   put the number of lines of tInput into tLines
   
   repeat with k = 1 to tLines
      put line k of tInput into tOneLine
      put 0 into tSkipChar
      put offset("width:", tOneLine,tSkipChar) into tHitChar
      if tHitChar = 0 then
         put tOneLine & LF after field "output"
         next repeat
      end if
      put offset("/*", tOneline,tSkipChar) into tComChar
      if tComChar > 0 and tHitChar > 0 and tComChar < tHitChar then
         -- skip comment line
         put tOneline & LF after field "output"
         next repeat
      end if
      
      add tHitChar to tSkipChar
      if char tSkipChar -1 of tOneLine is "-" then
         -- skip border-width, etc.
         put tOneline & LF after field "output"
         next repeat
      end if
      
      add 5 to tSkipChar -- 5 FOR EXPAND WIDTH
      put offset("px;",tOneLine,tSkipChar) into tHitChar
      add tSkipChar to tHitChar
      put char tSkipChar+1 to tHitChar-1 of tOneLine into tWidpx
      put the number of characters of tOneLine into tNumC
      put char tHitChar to tNumC of tOneLine into tEndString
      put fStripOuterSpace(tWidpx) into tWidpx
      put wfac * tWidpx into tWidpx
      put round(tWidpx) into tWidpx
      put space & "width:" & space before tWidpx
      put tEndString after tWidpx
      put tWidpx & LF after field "output"
   end repeat
   
end expandWidth

on expandLeft
   -- uses fields wfac, input, output
   -- uses function fStripOuterSpace
   
   if field "wfac" is empty then 
      put 1.0 into field wfac
      exit expandLeft
   end if
   put field "wfac" into wfac
   put empty into field "output"
   put field "input" into tInput
   put the number of lines of tInput into tLines
   
   repeat with k = 1 to tLines
      put line k of tInput into tOneLine
      put 0 into tSkipChar
      put offset("left:", tOneLine,tSkipChar) into tHitChar
      if tHitChar = 0 then
         put tOneLine & LF after field "output"
         next repeat
      end if
      put offset("/*", tOneline,tSkipChar) into tComChar
      if tComChar > 0 and tHitChar > 0 and tComChar < tHitChar then
         -- skip comment line
         put tOneline & LF after field "output"
         next repeat
      end if
      
      add tHitChar to tSkipChar
      
      if char tSkipChar -1 of tOneLine is "-" then
         -- handle margin-left
         -- xxx but are there other CSS -left ??
         put space & "margin-left:" & space into tPreFix
      else
         put space & "left:" & space into tPreFix
      end if
      
      add 4  to tSkipChar -- 4 for EXPAND LEFT
      put offset("px;",tOneLine,tSkipChar) into tHitChar
      add tSkipChar to tHitChar
      put char tSkipChar+1 to tHitChar-1 of tOneLine into tWidpx
      put the number of characters of tOneLine into tNumC
      put char tHitChar to tNumC of tOneLine into tEndString
      put fStripOuterSpace(tWidpx) into tWidpx
      put wfac * tWidpx into tWidpx
      put round(tWidpx) into tWidpx
      put tPreFix before tWidpx
      put tEndString after tWidpx
      put tWidpx & LF after field "output"
   end repeat
   
end expandLeft

function fStripOuterSpace tText
   repeat while the last char of tText is space
      delete the last char of tText
   end repeat
   repeat while the first char of tText is space
      delete the first char of tText
   end repeat
   return tText
end fStripOuterSpace


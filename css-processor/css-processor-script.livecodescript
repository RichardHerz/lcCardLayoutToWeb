script "css-processor-script"
-- R.K. Herz, www.reactorlab.net, 2017-2018

on scaleWidth
   -- uses fields wfac, input, output
   -- uses function fStripOuterSpace
   
   if field "wfac" is empty then 
      put 1.0 into field wfac
      answer "double-check scale factor - was empty"
      exit to top
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
      
      -- tSkipChar points to w of width:
      add 5 to tSkipChar -- add 5 to move forward to : of width:
      put offset("px;",tOneLine,tSkipChar) into tHitChar
      add tSkipChar to tHitChar
      put char tSkipChar+1 to tHitChar-1 of tOneLine into tWidpx
      put the number of characters of tOneLine into tNumC
      put char tHitChar to tNumC of tOneLine into tEndString
      put fStripOuterSpace(tWidpx) into tWidpx
      put wfac * tWidpx into tWidpx
      put round(tWidpx) into tWidpx
      put space & space & "width:" & space before tWidpx
      put tEndString after tWidpx
      put tWidpx & LF after field "output"
   end repeat
   
end scaleWidth

on scaleLeft
   -- uses fields wfac, input, output
   -- uses function fStripOuterSpace
   
   if field "wfac" is empty then 
      put 1.0 into field wfac
      answer "double-check scale factor - was empty"
      exit to top
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
         put space & space & "margin-left:" & space into tPreFix
      else
         put space & space & "left:" & space into tPreFix
      end if
      
      -- tSkipChar points to l of left:
      add 4 to tSkipChar -- add 4 to move forward to : of left:
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
   
end scaleLeft

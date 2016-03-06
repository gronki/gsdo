FUNCTION gsdo_sec2str, elaps

  if elaps ge 59 then begin
    str_tm = string(elaps/60.,f='(D0.1)') + ' min'
  endif else begin
    str_tm = string(elaps,f='(I0)') + ' sec'
  endelse
  
  return, str_tm

end
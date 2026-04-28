function gsdo_fix, x, fixval
  CHECKVAR, fixval, 0
  ix = where(finite(x) eq 0, cnt)
  if cnt ne 0 then begin 
    y = x
    y[ix] = fixval
    return, y
  endif  
  return, x
end
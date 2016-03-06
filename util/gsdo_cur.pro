pro gsdo_cur, x, y, arr

  cursor,x,y & WAIT, .2
  oplot, [x], [y], ps=6
  
  str = '  ' + string(x) + '!C  ' + string(y)
  
  if n_elements(arr) ne 0 then        $
    str = str + '!C->' + string(arr[round(x),round(y)])
  
  xyouts, x, y, str
  
end
function gsdo_coord_arr, index, img,    $
    RADIUS=_r,    $
    X=_x,     $
    Y=_y

  sz = size(img)
  out = fltarr(sz[1],sz[2],sz[3])
 
  for x = 0, sz[1]-1 do begin
    for y = 0, sz[2]-1 do begin
      crd = gsdo_coords(index,x,y)
      case 1 of
        keyword_set(_x): aa = crd[0,*]
        keyword_set(_y): aa = crd[1,*]
        else: aa = sqrt(total(crd^2,1))
      endcase
      out[x,y,*] = aa
    endfor
  endfor
  
  return,out
  
end
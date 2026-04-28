function gsdo_disk_margins, index, data, radius

  checkvar, radius, 1150.
  
  radius = radius*1.d
  
  rad = gsdo_coord_arr(index,data,/RAD)
  
  sz = size(data,/Dim)
  msk = make_array(Dimension=sz, /Byte) + 1b
  
  idx = where(rad gt radius, cnt)
  
  if cnt ne 0 then msk[idx] = 0b
  
;  FOR x = 0, sz[0]-1 DO BEGIN     
;    FOR y = 0, sz[1]-1 DO BEGIN
;      crd = GSDO_COORDS( index, x, y )
;      rad = crd[0,*]^2 + crd[1,*]^2
;      ix = WHERE( rad GT radius^2, cnt )
;      IF cnt NE 0 THEN BEGIN
;        msk[x,y,ix] = 0
;      ENDIF
;    ENDFOR
;  ENDFOR 
  
  return, msk
  
end
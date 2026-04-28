PRO GSDO_QANIM, img, _EXTRA=_extra
  WINDOW, 7, XS=500, YS=500
  !P.MULTI = 0 & LOADCT, 0
  
  sz = size(img)
  
  XINTERANIMATE2, SET=[500,500,sz[3]]
  
  FOR i = 0, sz[3]-1 DO BEGIN
    PLOT_IMAGE, reform(img[*,*,i]), _EXTRA=_extra
    XINTERANIMATE2, FRAME=i, WINDOW=7
  ENDFOR
  WDELETE, 7
  XINTERANIMATE2, 0.5
END
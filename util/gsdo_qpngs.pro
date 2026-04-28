PRO GSDO_QPNGS, fn_gen, cube, TITLE=title, CAPTION=caption, MIN=min, MAX=max, XS=xs, YS=ys

  sz = SIZE(cube)

;  WINDOW, XS=sz[1], YS=sz[2], TITLE='GSDO_QPNGS'

;  !P.MULTI = 0
  
  k = STRING(CEIL(ALOG10(sz[3]))>0, F='(I0)')
  suff = STRING(LINDGEN(sz[3])+1L , F='(I0'+k+')' )
  fn = fn_gen + '_' + suff + '.png'
  
  marg = 12
  
  for i = 0, sz[3]-1 do begin
;    TV, BYTSCL(REFORM(cube[*,*,i]),MIN=min,MAX=max)
;    if N_ELEMENTS(title) ne 0 then begin
;      XYOUTS, marg, sz[2]-marg-30, /DEVICE, title,   $
;          CHARSIZE=3, CHARTHICK=4
;    endif
;    if N_ELEMENTS(caption) ne 0 then begin
;      XYOUTS, marg, marg, /DEVICE, caption,   $
;          CHARSIZE=2, CHARTHICK=2
;    endif
    WRITE_PNG, fn[i], BYTSCL(REFORM(cube[*,*,i]),MIN=min,MAX=max)
  endfor

END

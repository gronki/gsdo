pro GSDO_DERIV_IMG, index0, img00, index, img,   $
    DIFF_T=diff_t,  $
    DIFF2_t=diff2_t,   $
    DIFF_X=diff_x,   $
    DIFF_Y=diff_y,   $
    CLIPFIRST=clipfirst,   $
    NOCONV=noconv,  $
    CLIPLAST=cliplast

  CHECKVAR, clipfirst, 1
  CHECKVAR, cliplast, 1

  img0 = FLOAT(img00)
  sz = size(img0)
  N = sz[3]
  
  idx = (indgen(sz[3]))[clipfirst:sz[3]-1-cliplast]
  
  ;flower = DOUBLE([[1,2,1], [2,4,2], [1,2,1]])
  ;flower3 = REBIN(flower,3,3,3) * REBIN(REFORM([1,4,1],[1,1,3]),3,3,3)
  krn = replicate(1/9., 3,3,3)
  if not keyword_set(noconv)      $
    then img = CONVOL(img0, krn, /NORM, /EDGE_TRUNC)    $
    else img = img0
  img = (FLOAT(TEMPORARY(img)))[*,*,idx]
  
  ;;; time differential
  if arg_present(diff_t) then begin
    ;;; prepare the kernel
    diff_t_krn = REBIN(REFORM( [-0.5,0,0.5] , [1,1,3] ),3,3,3) / 9D
    ;;; convolve
    diff_t = CONVOL(img0,diff_t_krn, /EDGE_TRUNC)
    ;;; delete first and last frames
    diff_t = (FLOAT(TEMPORARY(diff_t)))[*,*,idx]
  endif
  ;;; second differential
  if arg_present(diff2_t) then begin
    ;;; prepare the kernel
    diff2_t_krn = REBIN( REFORM( [1,-2,1] , [1,1,3] ), [3,3,3] ) / 9D
    ;;; convolve
    diff2_t = CONVOL(img0,diff2_t_krn,  /EDGE_TRUNC)
    ;;; delete first and last frames
    diff2_t = (FLOAT(TEMPORARY(diff2_t)))[*,*,idx]
  endif
  
  ;;; spatial gradients (for flow calculation)
  if arg_present(diff_x) then begin
    ;;; prepare the kernel
    diff_x_krn = REBIN(REFORM( [-0.5,0,0.5] , [3,1,1] ),3,3,3) / 9D
    ;;; convolve
    diff_x = CONVOL(img0, diff_x_krn, /EDGE_TRUNC)
    ;;; delete first and last frames
    diff_x = (FLOAT(TEMPORARY(diff_x)))[*,*,idx]
  endif 
  
  if arg_present(diff_y) then begin
    ;;; prepare the kernel
    diff_y_krn = REBIN(REFORM( [-0.5,0,0.5] , [1,3,1] ),3,3,3) / 9D
    ;;; convolve
    diff_y = CONVOL(img0, diff_y_krn, /EDGE_TRUNC)
    ;;; delete first and last frames
    diff_y = (FLOAT(TEMPORARY(diff_y)))[*,*,idx]
  endif
  
  if size(index0,/TNAME) eq 'STRUCT' then begin
    ;;; delete unused headers
    index = index0[idx]
    ;;; we cropped 1px margins, coords must be moved
;    index.crpix1 = index.crpix1 - 1
;    index.crpix2 = index.crpix2 - 1
  endif

end


;  CHECKVAR, _shift, 1
;  
;  shft = abs(round(_shift)) > 1
;  
;  N = (size(img0))[3]
  
;
;  index = index0[idx]
;  img = img0[*,*,idx]
;  diff = img0[*,*,idx+shft]-img0[*,*,idx-shft]
;  diff2 = img0[*,*,idx+shft] + img0[*,*,idx-shft] - 2*img0[*,*,idx]
;  diff_x = img0[*,*,idx]
  
  
;  timestamps = anytim(index0.date_obs) / 60.
;  intvl = timestamps[idx+shft]-timestamps[idx-shft]
;  intvl_l = timestamps[idx]-timestamps[idx-shft]
;  intvl_r = timestamps[idx+shft]-timestamps[idx]
;  intvl2 = 0.5 * ( intvl_l^2 + intvl_r^2 )
;  intvl2_as = (intvl_r - intvl_l)/intvl
;  
;  if not keyword_Set(nonorm) then begin
;    coeff1 = [ 0.0403675, 1.5902712, 1.3373331, 0.4169550 ]
;    intvl_corr = gsdo_func5( intvl, coeff1 ) / gsdo_func5( 1., coeff1 )
;    coeff2 = [ 0.0187074, 1.6898882, 1.2796797, 0.9733095 ]
;    intvl2_corr = gsdo_func5( intvl2, coeff2 ) / gsdo_func5( 1., coeff2 )
;    NN = (size(diff))[3]
;    for i = 0, NN-1 do begin
;      diff__ = diff[*,*,i]
;      diff[*,*,i] = diff[*,*,i] / intvl_corr[i]
;      diff2[*,*,i] = (diff2[*,*,i]) / intvl2_corr[i] ;  - intvl2_as[i] * diff__
;    endfor
;  endif

;  gradx = shift(img0,-1,0,0) - shift(img0,1,0,0)
;  grady = shift(img0,0,-1,0) - shift(img0,0,1,0)
;  
;  radius = gsdo_coord_arr(index0,img0,/R)
;  
;  cosfi = gsdo_coord_arr(index0,img0,/X) / radius
;  sinfi = gsdo_coord_arr(index0,img0,/Y) / radius
;  
;  vrad =  -diff / ( gradx * cosfi + grady * sinfi )
;  
;  for i = 0, (size(vrad))[3]-1 do     $
;    vrad[*,*,i] = fmedian(vrad[*,*,i])

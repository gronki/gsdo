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

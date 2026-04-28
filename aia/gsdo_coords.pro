
FUNCTION GSDO_COORDS, index, x, y, ARCSEC=to_arcsec, PIXEL=to_pixel

  ;;; test if vectors are of equal length
  IF n_elements(x) NE n_elements(y) THEN return, -1

  ;;; test if size of index vector is acceptable:
  ;;; -> one index, any number of points
  ;;; -> N images and N points, each on one image
  ;;; -> N images and one point, the same on each image
  IF      n_elements(index) NE 1                $
      AND n_elements(index) NE n_elements(x)    $   
      AND n_elements(x) NE 1                    $
      THEN return, -1
  
  
  ;;; 2xN array of resulting coordinates
  N = max([ n_elements(x), n_elements(index) ])
  result = fltarr(2,N)
  
  ;;; equations for conversion have been taken from SDO Primer v1.2
  
  ;;; determine the conversion mode
  IF keyword_set(to_pixel) THEN BEGIN
    ;;; arcseconds ---> pixels
    x_p = 1. * (x - index.crval1) / index.cdelt1 + (index.crpix1 - 1)
    y_p = 1. * (y - index.crval2) / index.cdelt2 + (index.crpix2 - 1)
    result[0,*] = x_p & result[1,*] = y_p
  ENDIF ELSE BEGIN
    ;;; pixels ---> arcseconds
    x_a = 1.*(x - (index.crpix1 - 1)) * index.cdelt1 + index.crval1
    y_a = 1.*(y - (index.crpix2 - 1)) * index.cdelt2 + index.crval2
    result[0,*] = x_a & result[1,*] = y_a
  ENDELSE
  
  RETURN, result
  
END
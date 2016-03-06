
PRO GSDO_IXDATA_BIN, index0, data0, index1, data1, BIN_FACTOR=bin_factor

  CHECKVAR, bin_factor, 2
  
  sz = size(data0, /Dim)
  IF size(data0, /N_Dim) eq 2 THEN BEGIN
    sz = intarr(3)+1 & sz[0:1] = size(data0, /Dim)
  ENDIF
  
  ;;; calculate required clipping of the image
  clip = sz mod bin_factor & clip[2] = 0
  ;;; new dimensions
  sz_crp = sz - clip
  ;;; crop the data
  data_crp = data0[ 0:(sz_crp[0]-1),    $
                    0:(sz_crp[1]-1),    $ 
                    0:(sz_crp[2]-1) ] * 1.
  ;;; bin down
  data1 = REBIN( TEMPORARY(data_crp), $
                          sz_crp[0]/bin_factor,   $
                          sz_crp[1]/bin_factor,   $  
                          sz_crp[2])

  ;;; copy header structure
  index1 = index0
  
  ;;; adjust header information
  index1.crpix1 = 1.0 * (index0.crpix1 - 1) / bin_factor + 1
  index1.crpix2 = 1.0 * (index0.crpix2 - 1) / bin_factor + 1
  index1.cdelt1 = index0.cdelt1 * bin_factor
  index1.cdelt2 = index0.cdelt2 * bin_factor
  
  
END
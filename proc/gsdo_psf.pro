;;; Computes n-dimensional gaussian kernel for convoluntion
function gsdo_psf, fwhm, sigma=sigm, dim=dim, DOUBLE=double

  ;;; sigma to wchich gausian is computed
  checkvar, sigm, 2.5
  checkvar, dim, 1

  if n_elements(fwhm) eq 1 and dim ne 1 then begin
    fwhm = intarr(dim) + fwhm
  endif

  ndim = n_elements(fwhm)

  if ndim lt 1 or ndim gt 8 then begin
    message,'Dimension too big or too small'
    stop
  endif

  ;;; standard deviation
  sigma = fwhm / 2.35482
  ;;; fwhm size
  npix = ceil(sigm*fwhm) > 1
  ;;; center point
  cen = (npix-1)/2.

  ;;; too narrow?
  ix_narrow = where(npix le 2, cnt)
  if cnt ne 0 then begin
    print,'PSF narrow in following dimensions; will be flat'
    print, ix_narrow+1
    sigma[ix_narrow] = npix[ix_narrow] * 100000.
  endif

  ; iterate through dimensions and fill
  rr2 = 0.
  for dim=0, ndim-1 do begin
    xx = gsdo_coordgen( npix, AXIS=dim+1, DOUBLE=double ) - cen[dim]
    ;;; add the term of ellipse equation
    rr2 = rr2 + xx^2/sigma[dim]^2
  endfor

  ;;; compute the gaussian
  g = exp( -rr2 )

  ;;; return normalized curve
  return, reform(g/total(g), npix)

end

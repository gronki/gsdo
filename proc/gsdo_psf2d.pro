;;; Computes n-dimensional gaussian kernel for convolution
function gsdo_psf2d, fwhm, sigma=sigm, DOUBLE=double

    ;;; sigma to wchich gausian is computed
    checkvar, sigm, 2.12

    if n_elements(fwhm) eq 1 then begin
        fwhm_ = [fwhm, fwhm]
    endif else begin
        if n_elements(fwhm) ne 2 then message, "psf2d expects scalar of 2-elemnt fWHM"
        fwhm_ = fwhm
    endelse

    ;;; standard deviation
    sigma = fwhm_ / 2.0
    ;;; size in pixels
    npix = ceil(sigm*fwhm_) > 1
    ;;; center point
    cen = (npix-1)/2.

    px = gsdo_coordgen(npix,axis=1,double=double)
    py = gsdo_coordgen(npix,axis=2,double=double)

    ro2 = (px-cen[0])^2 / sigma[0]^2 + (py-cen[1])^2 / sigma[1]^2

    kern = exp( -ro2 )

    return, kern /  total(kern)

end

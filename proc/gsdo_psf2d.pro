;;; Computes n-dimensional gaussian kernel for convoluntion
function gsdo_psf2d, fwhm, error=error, discrete=discrete

    ;;; sigma to wchich gausian is computed
    checkvar, dim, 1
    checkvar, error, 1e-4



    ;;; standard deviation
    sigma = fwhm / 2.35482
    sigma_range = sqrt(-2 * alog(error))
    ;;; size in pixels
    npix = ceil(sigma_range*fwhm) > 1
    ;;; center point
    cen = (npix-1)/2.

    px = gsdo_coordgen(npix*[1,1],axis=1,/double)
    py = gsdo_coordgen(npix*[1,1],axis=2,/double)

    ro2 = ((px-cen) * (px-cen) + (py-cen) * (py-cen)) / ( sigma * sigma )

    kern = exp(-0.5 * ro2)

    norm = 2 * !pi * sigma * sigma

    if keyword_set(discrete) then  norm = total(kern)

    return, kern / norm

end

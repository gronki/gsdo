;;; Computes n-dimensional gaussian kernel for convolution
function gsdo_psf2d, fwhm, sigma=sigm, DOUBLE=double

    ;;; sigma to wchich gausian is computed
    checkvar, sigm, 2.12

    ;;; standard deviation
    sigma = fwhm / 2.0
    ;;; size in pixels
    npix = ceil(sigm*fwhm) > 1
    ;;; center point
    cen = (npix-1)/2.

    px = gsdo_coordgen(npix*[1,1],axis=1,double=double)
    py = gsdo_coordgen(npix*[1,1],axis=2,double=double)

    ro2 = ((px-cen)^2 + (py-cen)^2) / ( sigma^2 )

    kern = exp( -ro2 )

    return, kern /  total(kern)

end

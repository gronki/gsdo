function mono2rgb, im, min=min, max=max
    sz = size(im,/dim)
    if n_elements(min) eq 0 then  min = min(im)
    if n_elements(max) eq 0 then  max = max(im)

    im1 = (im - min - 0.) / (max - min)
    im2 = bytscl(temporary(im1),min=0,max=1)

    return, rebin(reform(temporary(im2),[ 1, sz ]), [ 3, sz ], /samp )
end

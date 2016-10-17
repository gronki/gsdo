pro mono2rgb, im, imrgb
    imrgb = rebin(reform(im,[ 1, size(im,/dim) ]), [ 3, size(im,/dim) ], /samp )
end

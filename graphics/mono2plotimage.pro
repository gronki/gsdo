function mono2plotimage, im, min=min, max=max
    return, rgb2plotimage(mono2rgb(im,min=min,max=max))
end

function rgb, r, g, b
    rgb = ((long(r)>0)<255)*1l  $
        + ((long(g)>0)<255)*256l    $
        + ((long(b)>0)<255) * 256l * 256l
    return, rgb
end

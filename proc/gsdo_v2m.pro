function gsdo_v2m, vec, mx, axis=axis
    checkvar, axis, 3
    
    return, vec[ gsdo_coordgen(size(mx, /dim), axis=axis) ] 
end

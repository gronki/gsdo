; this function causes expansion of 3d blob
function gsdo_grow_3d, mask_

    mask = mask_ ne 0
    
    ; find indices of non-black pixels
    ix = where(mask, cnt)
    
    ; no white pixels -- return unchanged
    if cnt eq 0 then return, mask
    
    ; get coords of white pixels
    crd = array_indices(mask,ix)
    
    ; shifts
    sh_arr = array_indices(intarr(3,3,3),indgen(27))-1
    
    sz = size(mask)
    mask2 = mask
    
    ; iterate thru pixels and expand
    for i = 0l, cnt-1 do begin
        ; get coords to fill
        cr = rebin(crd[*,i], size( sh_arr, /dim )) + sh_arr
        ; clip edges/corners
        cr[0,*] = (((cr[0,*]) > 0) < (sz[1]-1))
        cr[1,*] = (((cr[1,*]) > 0) < (sz[2]-1))
        cr[2,*] = (((cr[2,*]) > 0) < (sz[3]-1))
        ; fill with 1b
        mask2[cr[0,*],cr[1,*],cr[2,*]] = 1b
    endfor
    
    return, mask2
end

function gsdo_findblob, mask_

    mask = mask_ ne 0
    if total(mask) eq 0 then return, -1

    ; find the maximum pixel
    m = max(mask_, ix)
    
    ; mark this point as belonging to the eruption
    mask_er = 0b * mask
    mask_grow = 0b * mask
    mask_grow[ix] = 1b
    
    ; now grow the blob iteratively
    while 1 do begin
        ; this mask contains only pixels that should be added
        mask_grow = (gsdo_grow_3d(mask_grow) and mask and not mask_er)
        ; if no pixels can be added, we're done
        ix = where(mask_grow,cnt)
        if cnt eq 0 then break
        ; grow
        mask_er = temporary(mask_er) or mask_grow
    endwhile
    
    return, mask_er
    
end

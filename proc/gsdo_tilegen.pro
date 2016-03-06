function gsdo_tilegen, max_tiles, min_tiles = min_tiles
	checkvar, min_tiles, 1
	checkvar, max_tiles, 6
    n = max_tiles > 1
    for i = min_tiles,n do begin
        if i ge 4 and i mod 2 eq 0 then begin
            gsdo_append, tiles, transpose([i/2,i])
            gsdo_append, tiles, transpose([i,i/2])
        endif else gsdo_append, tiles, transpose([i,i])
    endfor
    return, transpose(tiles)
end

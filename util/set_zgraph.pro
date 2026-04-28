pro set_zgraph, x, y, clean = clean

	common ___setzgraph___, old_dev	

	checkvar, x, 800
	checkvar, y, 600

	if keyword_set(clean) then begin
		if n_elements(old_dev) ne 0 then $
			set_plot, old_dev 
; ((!version.OS_FAMILY eq 'Windows') ? 'WIN' : 'X')
	endif else begin
		old_dev = !D.NAME
		set_plot, 'Z'
		device, z_buf = 0, decomposed = 0, set_resolution = [x,y], set_pixel_depth = 24
		cleanplot
		loadct, 0, /silent
		!p.charsize = 1.5
	endelse

	
end

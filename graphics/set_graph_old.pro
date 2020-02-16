; 1 lip 2015


pro set_graph_old, x, y, clean = clean, dpi = dpi_, mm = mm, zet = zet, window_id = win, scale = sc, line_width = line_width, noinv=noinv

	common ___setzgraph___, old_dev

	zgraph = keyword_set(zet)


    if keyword_set(mm) then begin
		zgraph_chkvar, x, 110 ; mm
		zgraph_chkvar, y, 90  ; mm
    endif else begin
		zgraph_chkvar, x, 800 ; px
		zgraph_chkvar, y, 600 ; px
    endelse



	if zgraph then zgraph_chkvar, dpi_, 600. else zgraph_chkvar, dpi_, 150

	dpi = dpi_

	sc = 1.         ; no scaling
	lw = 1.         ; line width in pixels
	txt_h = 10      ; text height in pixels


	if keyword_set(mm) then begin
	    sc = dpi / 25.4 ; dpi mode? calc scale [pix/mm]

	    lw = 0.3        ; line width in mm
	    txt_h = 1.9     ; text height in mm
	endif



	if keyword_set(clean) then begin
		if n_elements(old_dev) ne 0 then set_plot, old_dev
		cleanplot
		return
	endif

	if zgraph then begin
	    if !D.NAME ne 'Z' then old_dev = !D.NAME

	    set_plot, 'Z'
	    device, z_buf = 0, decomposed = 0, set_resolution = [x,y]*sc, set_pixel_depth = 24
	endif

	if ~zgraph then begin
	    ; and (!d.name eq 'WIN' or !d.name eq 'X')
	    set_plot,'X'
	    zgraph_chkvar, win, 1
	    window, win, xs = (x*sc), ys = (y*sc)
	endif

	loadct, 0, /silent

	cleanplot

	if ~keyword_set(noinv) then begin
	    !p.background = 255
	    !p.color = 0

	endif

	device, set_character_size = 2*[1,1.4] * txt_h * sc
	!p.charthick = 0.8 * sc * lw
	!p.thick = 1.1 * sc * lw

	xyouts, 0, 0, '!5' & erase


	!x.thick = 0.9 * sc * lw
	!y.thick = 0.9 * sc * lw
	!z.thick = 0.9 * sc * lw

	line_width = sc * lw




end

pro zgraph_chkvar, v, def
	if n_elements(v) eq 0 then v = def
end

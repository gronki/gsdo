
pro zgraph_chkvar, v, def
	if n_elements(v) eq 0 then v = def
end

pro set_graph, x, y,            $
    clean = clean,              $
    dpi = dpi_,                 $
    mm = mm,                    $
    zet = zet,                  $
    window_id = win,            $
    scale = sc,                 $
    line_width = line_width

	common ___setzgraph___, old_dev

	zgraph = keyword_set(zet) or keyword_set(mm)


    if keyword_set(mm) then begin
		zgraph_chkvar, x, 110 ; mm
		zgraph_chkvar, y, 90  ; mm
    endif else begin
		zgraph_chkvar, x, 800 ; px
		zgraph_chkvar, y, 600 ; px
    endelse



	if zgraph then $
	    zgraph_chkvar, dpi_, getenv('GSDO_IMAGES_DPI') $
	    else zgraph_chkvar, dpi_, 90

	dpi = dpi_

	sc = 1.         ; no scaling
	lw = 1.         ; line width in pixels
	txt_h = 10      ; text height in pixels


	if keyword_set(mm) then begin
	    sc = dpi / 25.4 ; dpi mode? calc scale [pix/mm]

	    lw = 0.25       ; line width in mm
	    txt_h = 1.8     ; text height in mm
	endif



	if keyword_set(clean) then begin
		if n_elements(old_dev) ne 0 then set_plot, old_dev
		return
	endif

	if zgraph then begin
	    if !D.NAME ne 'Z' then old_dev = !D.NAME

	    set_plot, 'Z'
	    device, z_buf = 0, $
	            decomposed = 0,  $
	            set_resolution = [x,y]*sc,  $
	            set_pixel_depth = 24
	endif

	if ~zgraph then begin
	    set_plot,'X'
	    zgraph_chkvar, win, 1
	    device, decomposed = 0
	    window, win, xs = (x*sc), ys = (y*sc)
	endif

	loadct, 0, /silent


	!p.background = 255
	!p.color = 0



	device, set_character_size = [1,1.4] * txt_h * sc
	line_width = sc * lw
	!p.charthick = 0.8 * line_width
	!p.thick = 1.2 * line_width

	xyouts, 0, 0, '!5' & erase


	!x.thick = 0.85 * line_width
	!y.thick = 0.85 * line_width
	!z.thick = 0.85 * line_width

	!X.MARGIN=[6.5,3.0]
	!Y.MARGIN=[3.8,3.1]






end

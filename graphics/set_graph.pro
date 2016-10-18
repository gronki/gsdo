
pro setgraph_checkvar, v, def
	if n_elements(v) eq 0 then v = def
end

pro set_graph, x, y,  win,          $
    clean = clean,              $
    dpi = dpi,                 $
    mm = mm,                    $
    zet = zet,                  $
    scale = sc,                 $
    line_width = line_width

	common ___setzgraph___, old_dev

	zgraph = (n_elements(win) eq 0)

	setgraph_checkvar, x, 110 ; mm
	setgraph_checkvar, y, 90  ; mm

	if zgraph then $
	    setgraph_checkvar, dpi, getenv('GSDO_IMAGES_DPI') $
	    else setgraph_checkvar, dpi, 150

    sc = dpi / 25.4 ; calc scale [pix/mm]

    lw = 0.25       ; line width in mm
    txt_h = 1.8     ; text height in mm


	if keyword_set(clean) then begin
		set_plot,'X'
		return
	endif

	if zgraph then begin
		; hidpi mode
	    set_plot, 'Z'
	    device, z_buf = 0, $
	            decomposed = 1,  $
	            set_resolution = [x,y]*sc,  $
	            set_pixel_depth = 24
	endif else begin
		; windowed mode
	    set_plot,'X'
	    device, decomposed = 1
		setgraph_checkvar, win, 1
	    window, win, xs = (x*sc), ys = (y*sc)
	endelse

	!p.background = rgb(250,250,250)
	!p.color = rgb(20,20,20)

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

function gsdo_apriori_map, index, data, f_var,  n_iter = n_iter, w_param = w_param

	checkvar, n_iter, 4
	checkvar, w_param, 8

	common gsdo_apriori_map_IODIFNHDOSFASOH, rectnr

	checkvar, rectnr, 1

    ;;; compress using asinh
    af_var = alog10(f_var)
    l_data = alog10(float(data))

	_w = gsdo_flag('GSDO_EXTRAPLOT')

	if _w then begin
		set_graph, 180, 180, /mm
		!p.multi = [0,2,2]
    endif
    ;;; determine quiet frames
    ix_q = GSDO_QUIET_INDICES(index,f_var,data, w1=w_param, plot=_w)

    b = 3*(3+round(0.6*float(n_elements(data))^(1/4.)))

    ;;; and make histogram of them
    h_q = GSDO_HIST2D(/STRUCT,   $
          af_var[*,*,ix_q], $
          l_data[*,*,ix_q],    $
          MIN_X = -2.0, MAX_X = 0.5, N_X = b,   $
          MIN_Y = 1.0, MAX_Y = 4.5, N_Y = b, /nonorm)

    h_all = gsdo_hist2d(/struct, like = h_q,        $
            af_var, l_data, /nonorm)

    ;;; kernel used to smooth probabilities
    krn_hist =  gsdo_psf2d(4.5)
    ;;; smooth probability distribution for less noise
    ;;; during division
	h_q_conv = h_q
	h_all_conv = h_all
    h_q_conv.hist = convol(double(h_q.hist)/n_elements(ix_q), double(krn_hist), /EDGE_TRUNC)
    h_all_conv.hist = convol(double(h_all.hist)/n_elements(data[0,0,*]), double(krn_hist), /EDGE_TRUNC)

    ;;; compute apriori probability that pixel is not quiet
    h_apr = h_q

    ;;; assume eruption fill factor of 0.1%
    s = 0.001

    sh = fltarr(n_iter)

    for i = 0,n_iter-1 do begin
		;;; calculate a-priori probability
		h_apr.hist = gsdo_fix( ((h_all_conv.hist - (1.-s)*h_q_conv.hist)>0) / h_all_conv.hist,0)
		h_apr.hist = float(h_apr.hist)
		sh[i] = s

		;;; remap it to an image
		imgapr = GSDO_HIST2D_REMAP(af_var, l_data, h_apr)

		;;; recompute eruption fill factor
		s = ( total(float(imgapr gt 0.5)) / n_elements(imgapr) ) < 0.5

    endfor

    if _w then begin
		panel_dir = getenv('GSDO_PANEL_DIR')

		gsdo_plot_hist2d, h_all_conv, /paper, TITLE='ALL PIXELS', $
			xtitle='!7log!d10!n(!16Variability!x)', $
			ytitle='!7log!d10!n(!16Intensity!x)'
		gsdo_plot_hist2d, h_apr, /paper, /linear, TITLE='APRIORI PROBABILITY', $
			xtitle='!7log!d10!n(!16Variability!x)', $
			ytitle='!7log!d10!n(!16Intensity!x)', $
			min=0, max=1
		gsdo_plot_hist2d, h_q_conv, /paper, TITLE='QUIET PIXELS', $
			xtitle='!7log!d10!n(!16Variability!x)', $
			ytitle='!7log!d10!n(!16Intensity!x)'
		write_png, panel_dir+'/histo.png', tvrd(/true)

		if gsdo_flag('GSDO_MAKERECTS') then begin
			for i=0,n_elements(imgapr(0,0,*))-1 do begin
				set_graph, 120, 120
				!p.multi = 0
				plot_rgb, mono2temperature(reform(imgapr(*,*,i)), min=1, max=0), $
						index=index(i), $
						title='APRIORI PROBABILITY'
				write_png, string(panel_dir,'/a',i+1,'.png', format='(A,A,I05,A)'), tvrd(/true)
			endfor
			rectnr = rectnr + 1
		endif
    endif

    return, imgapr
end

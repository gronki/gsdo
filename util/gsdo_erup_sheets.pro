pro gsdo_erup_sheets, erup, index, data, diff, contours

    
    er_dir = gsdo_erupdir(erup)
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    
    set_zgraph, 1200, 900
    !p.multi = [0,3,2]
    
    plot, [0,1], /nodata, xstyle=4, ystyle=4   
    	
    xyouts, 0.05, 0.9, 'Eruption', CharSize = 2
    xyouts, 0.05, 0.75, anytim(erup.t_start, /Yoh, /Date_Only) + '!C  ' 	$
    	+ anytim(erup.t_start, /Yoh, /Time_Only) + '!C  ' + anytim(erup.t_peak, /Yoh, /Time_Only) + '!C  ' + anytim(erup.t_end, /Yoh, /Time_Only) + '!C!C'	$
    	+ 'center (x,y)   ' + string(erup.x_center_m,f='(I0)') + ',  ' + string(erup.y_center_m,f='(I0)') + '!C' 			$
    	+ 'frames:   ' + string(erup.n_points,f='(I0)')
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
   
    
    n = erup.n_points
    
    tile_w_sec = round(max([ 270, 3.6*sqrt(erup.area_x) ]))
    tile_h_sec = round(tile_w_sec*1.2)
    
    ; mini solar disk               
    plot, [0], [0], /NoData, xr=[-1,1]*1200, yr=[-1,1]*1200, /isotr, Title = 'LOCATION'
    x = makex(0,1,1/360.)
    rs = index[0].RSUN_OBS
    oplot, rs*cos(x*2*!PI), rs*sin(x*2*!PI)
    tvbox, [ tile_w_sec, tile_h_sec ], erup.x_center_m, erup.y_center_m
    oplot, erup.x_center[0:n-1], erup.y_center[0:n-1], ps = 3
    
    plot, erup.x_center[0:n-1], erup.y_center[0:n-1], ps=-1, title = 'POSITION'
	oplot, erup.x_start + 50*[0,erup.x_versor], erup.y_start + 50*[0,erup.y_versor], thick = 2 
	
	utplot, erup.times[0:n-1], erup.area[0:n-1], 0, title = 'AREA'
	
	utplot, erup.times[0:n-1], erup.intens[0:n-1], 0, title = 'INTENSITY'
	
	utplot, erup.times[0:n-1], erup.h_front[0:n-1], 0, title = 'HEIGHT'
	outplot, erup.times[0:n-1], erup.h_center[0:n-1], 0, thick = 2
	outplot, erup.times[0:n-1], erup.h_bottom[0:n-1], 0, linestyle=2
	xxx = makex(0,2*(n-1),0.001)
	outplot, erup.times[0] + xxx*60., erup.h_traject_2[0] + xxx * erup.h_traject_2[1] 	$
			+ xxx^2 * erup.h_traject_2[2], 0, color = 200
	outplot, erup.times[0] + xxx*60., erup.h_traject_3[0] + xxx * erup.h_traject_3[1] 	$
			+ xxx^2 * erup.h_traject_3[2] + xxx^3 * erup.h_traject_3[3], 0, color = 100
    
    write_png, er_dir + path_sep() + 'summ.png', tvrd(/true)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    
    
    gsdo_ixdata_crop, index, data, indexc, datac,         $
            /arcsec, center = [erup.x_center_m, erup.y_center_m], dim = [ tile_w_sec, tile_h_sec ]
    m2 = max(datac)
    
    gsdo_ixdata_crop, index, contours, _, contc,         $
            /arcsec, center = [erup.x_center_m, erup.y_center_m], dim = [ tile_w_sec, tile_h_sec ]        
            
    gsdo_ixdata_crop, index, diff, _, diffc,         $
            /arcsec, center = [erup.x_center_m, erup.y_center_m], dim = [ tile_w_sec, tile_h_sec ]  
            
            
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    set_zgraph, 1200, 600
    !p.multi = [0,3,1]
    
    idx = where(erup.mask_seq,nn)
    
    for j = 0, nn-1 do begin
    	i = idx[j]
    	!p.multi = [0,3,1]
    	loadct, 0, /silent
    	plot_image, asinh(reform(datac[*,*,i])), min=asinh(28.), max=asinh(2400.), TITLE = anytim(/yoh, index[i].date_obs)
    	plot_image, asinh(reform(datac[*,*,i])), min=asinh(28.), max=1.5*asinh(2400.), TITLE = anytim(/yoh, index[i].date_obs)
    	contour, reform(contc[*,*,i]), /overplot, c_thick = [2], levels = [0.5]
    	plot_image, reform(diffc[*,*,i]), min = -0.1, max = 0.1
    	
    	write_png, er_dir + path_sep() + 'f' + string(j+1,f='(I03)') + '.png', tvrd(/true)
    endfor
    
    
    
            
    
    ;write_png, er_dir + path_sep() + '.png', tvrd(/true)
    
    set_zgraph, /clean
	
end











function gsdo_erup_sheet, erup, index, data, diff, contours

    ; ---------------------------------------------

    tile_w_scr = 150
    tile_h_scr = 150
    tile_w_sec = max([ 250, 3*sqrt(erup.area_x) ])
    tile_h_sec = tile_w_sec
    tile_ny = erup.n_points
    tile_nx = 6
    hdr_h = 100
    hdr_w = 600
    margin = 25

    
    page_w = 1150
    
    nn = erup.n_points
    idx = where(erup.mask_seq)

    
    dev = !D.NAME
    set_plot, 'Z'
    device, z_buf = 0, decomposed = 0,  set_pixel_depth = 24
    loadct, 0, /Silent
    !p.background = 255 & !p.color = 0
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    hdr_h = 150
    
    device, set_resolution = [page_w, hdr_h] & erase
    
    xyouts, /dev, margin, hdr_h - margin - 12,  charsize = 2,  charthick = 2,       $
        '!6Eruption ' + string(erup.id) + '!C---------------'
    xyouts, /dev, margin, hdr_h - margin - 60,  charsize = 1.6,         $
        '!6' + anytim(erup.t_start,/YOH) + ' - ' + anytim(erup.t_end,/YOH,/time_only) $
        + '!C' + string(erup.area_x,f='(I0)') + ' arcsec!U2!N at ' + anytim(erup.t_peak,/YOH,/time_only)
    xyouts,0,0,'!3'
    
    im1 = tvrd(/true)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    
    device, set_resolution = [page_w, 700] & erase
    
    !p.charsize = 1.5
    
    !P.Multi = [0,3,2]
    
    ; mini solar disk               
    plot, [0], [0], /NoData, xr=[-1,1]*1200, yr=[-1,1]*1200, /isotr, Title = 'LOCATION'
    x = makex(0,1,1/360.)
    rs = index[0].RSUN_OBS
    oplot, rs*cos(x*2*!PI), rs*sin(x*2*!PI)
    tvbox, [ tile_w_sec, tile_h_sec ], erup.x_center_m, erup.y_center_m
    oplot, erup.x_center[0:nn-1], erup.y_center[0:nn-1], ps = 3
    
    ; important plots              
    plot, /isotr, erup.x_center[0:nn-1], erup.y_center[0:nn-1], ps = -1, Title = 'CENTER',  $
            XRan = erup.x_center_m + 50*[-1,1], YRan = erup.y_center_m + 50*[-1,1]
    plot, /isotr, erup.x_flow[0:nn-1], erup.y_flow[0:nn-1], ps = -1, Title = 'FLOW', XRan = [-2,2], YRan = [-2,2]
    utplot, erup.times[0:nn-1], erup.area[0:nn-1], 0, ps = -6, Title = 'AREA'
    utplot, erup.times[0:nn-1], erup.intens[0:nn-1], 0, ps = -6, Title = 'INTENSITY', /YL, YR=[10,10000]
    plot, erup.f_var[0:nn-1], erup.intens[0:nn-1], ps = -1, Title = 'INT-VAR',          $
        /XLog, /YLog, XR = [1e-2,1], YR = [10,10000]
    
    im2 = tvrd(/true)
    
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
    
    gsdo_ixdata_crop, index, data_raw, indexc, datac,         $
            /arcsec, center = [erup.x_center_m, erup.y_center_m], dim = [ tile_w_sec, tile_h_sec ]
    m2 = max(datac)
    
    gsdo_ixdata_crop, index, apr, _, aprc,         $
            /arcsec, center = [erup.x_center_m, erup.y_center_m], dim = [ tile_w_sec, tile_h_sec ]        
            
    gsdo_ixdata_crop, index, n_diff_t, _, n_diff_tc,         $
            /arcsec, center = [erup.x_center_m, erup.y_center_m], dim = [ tile_w_sec, tile_h_sec ]  
            
    gsdo_ixdata_crop, index, flow_x, _, flow_xc,         $
            /arcsec, center = [erup.x_center_m, erup.y_center_m], dim = [ tile_w_sec, tile_h_sec ]              
    gsdo_ixdata_crop, index, flow_y, _, flow_yc,         $
            /arcsec, center = [erup.x_center_m, erup.y_center_m], dim = [ tile_w_sec, tile_h_sec ]           
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    
    device, set_resolution = [page_w, 185*tile_ny] & erase
    
    !p.charsize = 1
    
    gr_x = 0
    gr_y = 0
    
    
    
    !p.multi = [0,7,tile_ny]
    
    for gr_y = 0, tile_ny-1 do begin
        j = gr_y & i = idx[j]
        
        loadct,0,/silent
        ; frame time
        plot, [0], [0], /nodata, xstyle=4, ystyle=4, xr=[0,10], yr=[0,10]
        xyouts,0,4,'!6'+anytim(erup.times[j],/yoh,/time_only)+'!3', charsize=1.6, charthick=2

        ; various frames
        plot_image, reform(sqrt(datac[*,*,i])), min=0.05*sqrt(m2), max=0.9*sqrt(m2)
        ; ---------------------------------------------
        plot_image, reform(sqrt(datac[*,*,i])), min=0.05*sqrt(m2), max=0.9*sqrt(m2)
        loadct,39,/silent
        contour, /overplot, reform(aprc[*,*,i]), levels=prob_thr*[0.5,1,2], color=235
        cen = gsdo_coords(/pix, indexc, erup.x_center[j], erup.y_center[j])
        oplot, [cen[0]], [cen[1]], ps=1, symsize=2, color=205
        ; ---------------------------------------------
        ;loadct,39,/silent
        plot_image, reform(n_diff_tc[*,*,i]), min=-0.2, max=0.2,  Title = 'DIFF'
        plot_image, reform(flow_xc[*,*,i]), min=-0.5, max=0.5,  Title = 'FLOW X'
        plot_image, reform(flow_yc[*,*,i]), min=-0.5, max=0.5, Title = 'FLOW Y'
        loadct,0,/silent
        plot_image, reform(aprc[*,*,i]), min=0, max=1,  Title = 'APRIORI'
  

    endfor
    
    im3 = tvrd(/true)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    sz1 = size(im1, /Dim)
    sz2 = size(im2, /Dim)
    sz3 = size(im3, /Dim)
    
    szall = [ sz1[0], sz1[1], sz1[2]+sz2[2]+sz3[2]]
    imm = bytarr(szall)
    imm[*,*,0:sz3[2]-1] = temporary(im3)
    imm[*,*,sz3[2]:sz3[2]+sz2[2]-1] = temporary(im2)
    imm[*,*,sz3[2]+sz2[2]:sz1[2]+sz2[2]+sz3[2]-1] = temporary(im1)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    set_plot, dev
    return, imm

end

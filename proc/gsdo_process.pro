

function gsdo_process, fn_list,          $
        transform_param = a_param,        $
        prob_threshold = prob_threshold,    $
        erupt_movement_threshold = erupt_movement_threshold,		$
        prob_smooth = prob_smooth,          $
        area_threshold = erupt_area_threshold,      $
        erupt_intensity_threshold = erupt_intensity_threshold,			$
        w_param = w_param, blur_fwhm = blur_fwhm,		$
        verbose = verbose, n_found = n_found,    n_points_min = n_points_min,   $
        savestruct = savestruct, savegraph = savegraph, windowed = windowed

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    checkvar, prob_threshold, 0.3
    checkvar, prob_smooth, 4
	checkvar, n_points_min, 8
    checkvar, erupt_area_threshold, 200
    checkvar, erupt_movement_threshold, 25
    checkvar, erupt_intensity_threshold, 30
    checkvar, w_param, 8
    checkvar, blur_fwhm, 3.0

    _v = keyword_set(verbose)
    _w = keyword_set(windowed)


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    if _v then help, /MEMORY

    if _v then gsdo_tic
    if _v then box_message, 'Reading images...'

    ;pushd, getenv('GSDO_DATA') + path_sep() + 'fits'
    ;fn = GSDO_FNLIST(T_RAN=[interv_start,interv_end], WAVE=wave)
    read_sdo, fn_list, index0, data0n, 4, 4, 1016, 1016, /UNCOMP_DELETE, /NOSHELL
   ; popd

   	if n_elements(data0n) eq 0 then begin
   		n_found = 0
   		return, -1
   	endif


    sz = size(data0n)
    ;;; normalize for exposure and add small number to
    ;;; compensate darkframe overcorrection by adding constant
    exx = ((index0.exptime)[rebin(findgen(1, 1, sz[3]),sz[1],sz[2],sz[3])])
    data_corr =  0.17
    data0 = (float(temporary(data0n)) + float(data_corr)) / temporary(exx)

    if _v then print, '    DONE ' + GSDO_TOC()

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    sz = size(data0)

    ix_dark = where( total(total(data0,1),1)/(sz[1]*sz[2]) lt 10, cn_dark )
    if cn_dark gt 0 then data0[*,*,ix_dark] = !values.f_nan
    ix_broken = where( ~finite(data0), cn_broken )
    if cn_broken gt 0 then begin
    	if _v then print, 'DATA NEEDS FIXING!!!!!!!!!'
    	data_fix = convol( data0, gsdo_psf([0,0,4]), /normalize, /nan )
    	data0[ix_broken] = data_fix[ix_broken]
    	undefine, data_fix
    	if _v then print, '     fixed pixels:', cn_broken
    endif


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    if _v then gsdo_tic
    if _v then box_message, 'Computing diff imgs...'

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    wave = index0[0].wavelnth

    case wave of
        171: a_def = 8.
        304: a_def = 2.5
        211: a_def = 3.
        else: a_def = 5.
    endcase

    checkvar, a_param, a_def, 1.

    if _v then print, 'Transformation parameter: ', a_param

    psf_smooth = gsdo_psf(blur_fwhm*[1,1,0])
    n_clip = 3
    idx = findgen((size(data0))[3]-2*n_clip) + n_clip

    ;;; reject first and last frames of index
    index = index0[idx]

    ;;; raw copy
    data_raw = gsdo_fix(data0[*,*,idx],0)

    ;;; smooth
    data0 = convol( temporary(data0), psf_smooth, /normalize, /nan )

    data = data0[*,*,idx]

    diff_t = (gsdo_deriv( data0, axis=3, order=1 ))[*,*,idx]

    ;;; normalized differentials -- computed from transformed fucntion
    n_data = gsdo_fix(alog(data0+a_param)-alog(float(a_param)),0)
    n_diff_t = (gsdo_deriv( n_data, axis=3, order=1 ))[*,*,idx]
    n_diff2_t = (gsdo_deriv( n_data, axis=3, order=2 ))[*,*,idx]


    ;;; compute variability index
    f_var = sqrt( (n_diff_t)^2 + 0.25*(n_diff2_t)^2 )


    if _w then begin
    	window, 0, xs = 1200, ys = 1000
    	loadct,0
    	for i = 0, (size(data_raw))[3]-1 do begin
    		!p.multi = [0,2,2]
    		;wait, 0.08
    		plot_image, asinh(reform(data_raw[*,*,i])*0.2), min=0.2, max=6
    		plot_image, reform(n_diff_t[*,*,i]), min=-0.1, max=0.1
    		plot_image, reform(n_diff2_t[*,*,i]), min=-0.1, max=0.1
    		plot_image, reform(f_var[*,*,i]), min=0, max=0.1
    		gsdo_shot
    	endfor
    endif

	undefine, n_data
	undefine, data0
	undefine, n_diff2_t

    if _v then print, '   -->  differentials OK'
    if _v then print, '    DONE ' + GSDO_TOC()



; stop
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    if _v then gsdo_tic
    if _v then box_message, 'Generating activity map...'

    imgapr_master = gsdo_activity_map(index, data, f_var, max_tiles=14, w_param=w_param, windowed = windowed)

    if _v then print, 'Generating apriori done!'
    if _v then print, ' ----- OK ' + gsdo_toc()


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    if _v then gsdo_tic
    if _v then box_message, 'Convoluntion of probability map'


    if _v then print, '   threshold:', prob_threshold

    imgapr_master_bl = convol(temporary(imgapr_master),    $
          gsdo_psf(prob_smooth*[1,1,0]),/EDGE_TRUNC)
    imgapr_master_mask = imgapr_master_bl ge prob_threshold

    if _v then print, ' ----- OK ' + gsdo_toc()

    if _w then begin
    	window, 0, xs = 1400, ys = 800
    	loadct,0
    	for i = 0, (size(data_raw))[3]-1 do begin
    		;wait, 0.08
    		!p.multi = [0,2,1]
    		plot_image, asinh(reform(data_raw[*,*,i])*0.2), min=0.1, max=6
    		contour, /overplot, reform(imgapr_master_bl[*,*,i]), levels=[0.5]
    		plot_image, reform(imgapr_master_bl[*,*,i]), min=0, max=1
    		gsdo_shot
    	endfor


    endif

   ; stop
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    if _v then gsdo_tic
    if _v then print, 'Initializing stuff...'

    interv_start = index[0].t_obs
    interv_end = index[n_elements(index)-1].t_obs


    ; define the structure
    maxlen = 360
    _ = { __gsdo_eruption_ext__,            $
        id:         -1l,                $
        t_start:    0.d,                $
        t_end:      0.d,                $
        t_peak:      0.d,               $
        duration:   0.,                 $
        wave:       wave,               $
        n_points:   0l,                 $
        mask:       bytarr(maxlen),     $
        mask_seq:   bytarr(maxlen),     $
        times:      dblarr(maxlen),     $
        x_center:   fltarr(maxlen),     $
        x_center_m: 0.,                 $
        x_start:   0.,     $
        y_center:   fltarr(maxlen),     $
        y_center_m: 0.,                 $
        y_start:   0.,     $
        is_eruption: 0,		$
		h_front:	fltarr(maxlen),     $
		h_center:	fltarr(maxlen),     $
		h_bottom:	fltarr(maxlen),     $
		h_traject_2:fltarr(3),			$
		h_traject_3:fltarr(4),			$
		x_versor:   0., y_versor: 0.,	$
        area:       fltarr(maxlen),     $
        area_m:     0.,                 $
        area_x:     0.,                 $
        intens:     fltarr(maxlen),     $
        intens_m:   0.,                 $
        intens_x:   0.,                 $
        diff_t:     fltarr(maxlen),     $
        n_diff_t:   fltarr(maxlen),     $
        f_var:      fltarr(maxlen),     $
        f_var_m:    0.,                 $
	nothing: 0 }

    n = (size(imgapr_master_bl))[3]

    x_arr = gsdo_coord_arr(index, data, /X)
    y_arr = gsdo_coord_arr(index, data, /Y)



    if _v then print, ' ----- OK ' + gsdo_toc()

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    k = 1
    kk = 1

    if _v then gsdo_tic
    if _v then box_message, 'LOOKING FOR ERUPTIONS'



    while total(abs(imgapr_master_mask)) gt 0 do begin

        if _v then print, 'Candidate ' + string(kk, f='(I0)') + '...'
        if _v then print, '  (found ' + string(k-1, f='(I0)') + ')'

        kk = kk + 1

        ; --------- do some preparation

        ; byte mask for this eruption
        mask = gsdo_findblob(imgapr_master_mask)
        ; subtract the eruption from remaining mask
        imgapr_master_mask = imgapr_master_mask and not mask



        m1 = total(total(float(mask),1),1) gt 0
        idx = where(m1, n_points)
        if n_points gt maxlen then begin
        	idx = idx[0:maxlen-1]
        	n_points = maxlen
        endif

        if n_points lt n_points_min then continue

        ; ------- write to structure
        ; create temporary array
        tmp = {__gsdo_eruption_ext__}
        tmp.id = k
        tmp.n_points = n_points
        if _v then print, '  points:', tmp.n_points

        tmp.mask = findgen(maxlen) lt tmp.n_points
        nn4 = min([ maxlen, n_elements(m1) ])
        tmp.mask_seq[0:nn4-1] = m1[0:nn4-1]

        tmp.times = anytim((index.t_obs)[idx])
        tmp.t_start = anytim((index.t_obs)[idx[0]])
        tmp.t_end = anytim((index.t_obs)[idx[n_points-1]])

        ; area
        area0 = total(total(float(mask[*,*,idx]),1),1) * (index[0].cdelt1)^2

        tmp.area = area0
        tmp.area_m = mean(area0)
        tmp.area_x = max(area0,imax)
        tmp.t_peak = anytim((index.t_obs)[idx[imax]])

        if (tmp.area_x lt erupt_area_threshold) then continue

        if _v then print, '  area', tmp.area_x

        ; probability mask for weighted averages
        wts_glob = float(mask[*,*,idx]) * imgapr_master_bl[*,*,idx]
        wts_glob = wts_glob / total(wts_glob)
        wts_t = total(total(wts_glob,1),1)
        wts_loc = wts_glob / gsdo_v2m(wts_t, wts_glob, axis=3)

        ; intesities, differences
        tmp.intens = total(total(wts_loc * data_raw[*,*,idx],1),1)
        tmp.intens_x = max(tmp.intens)
        tmp.intens_m = total(wts_glob * data_raw[*,*,idx])
        tmp.diff_t = total(total(wts_loc * diff_t[*,*,idx],1),1)
        tmp.n_diff_t = total(total(wts_loc * n_diff_t[*,*,idx],1),1)
        tmp.f_var = total(total(wts_loc * f_var[*,*,idx],1),1)
        tmp.f_var_m = total(wts_glob * f_var[*,*,idx])

        if  (tmp.intens_x le erupt_intensity_threshold) then continue

        if _w then begin
		    window, 0, xs=800, ys = 800
		    !p.multi = 0
		    plot_image, total(mask,3)
        endif

        ; positions
        tmp.x_center = total(total(wts_loc * x_arr[*,*,idx],1),1)
        tmp.y_center = total(total(wts_loc * y_arr[*,*,idx],1),1)
        tmp.x_center_m = total(wts_glob * x_arr[*,*,idx])
        tmp.y_center_m = total(wts_glob * y_arr[*,*,idx])

        tmp.x_start = mean(tmp.x_center[0:1])
        tmp.y_start = mean(tmp.y_center[0:1])

        vec_x = mean(tmp.x_center[0:n_points-1] - tmp.x_start)
        vec_y = mean(tmp.y_center[0:n_points-1] - tmp.y_start)
        vec_d = sqrt(vec_x^2+vec_y^2)

        vec_x = vec_x / vec_d & vec_y = vec_y / vec_d

        tmp.x_versor = vec_x & tmp.y_versor = vec_y

        if _v then begin
            print, '  start   ', anytim(tmp.t_start, /yohkoh)
            print, '  end     ', anytim(tmp.t_end, /yohkoh)
            print, '  (x,y)   ', tmp.x_start, tmp.y_start
            print, '  (kx,ky) ', vec_x, vec_y
        endif

        if vec_d ge erupt_movement_threshold then begin
        	tmp.is_eruption = 1
        	if _v then print, '  POSSIBLE ERUPTION!'
        	h_arr = (x_arr-tmp.x_start) * vec_x + (y_arr-tmp.y_start) * vec_y
        	tmp.h_center = total(total(wts_loc * h_arr[*,*,idx],1),1)
        	for i = 0, n_elements(idx)-1 do begin
        		ix = where(mask[*,*,idx[i]])
        		tmp.h_front[i] = max( (h_arr[*,*,0])[ix] )
        		tmp.h_bottom[i] = min( (h_arr[*,*,0])[ix] )
        	endfor
        	n = n_elements(idx)
        	tmp.h_traject_2 = poly_fit( findgen(n)*2, tmp.h_center[0:n-1], 2 )
        	tmp.h_traject_3 = poly_fit( findgen(n)*2, tmp.h_center[0:n-1], 3 )
        	if _v then print, 'Trajectory:'
        	if _v then print, tmp.h_traject_2
        endif else continue



    	if _w then begin
    		window, 1, xs = 1000, ys = 800
    		!p.multi = [0,2,2]
    		n = n_elements(idx)

    		plot, tmp.x_center[0:n-1], tmp.y_center[0:n-1], ps=-1, title = 'POSITION'
    		oplot, tmp.x_start + 50*[0,vec_x], tmp.y_start + 50*[0,vec_y], thick = 2

    		plot, tmp.area[0:n-1], title = 'AREA'

    		plot, tmp.intens[0:n-1], title = 'INTENSITY'

    		plot, tmp.h_front[0:n-1], title = 'HEIGHT'
    		oplot, tmp.h_center[0:n-1], thick = 2
    		oplot, tmp.h_bottom[0:n-1], linestyle=2
    		xxx = makex(0,2*(n-1),0.001)
    		oplot, xxx*0.5, tmp.h_traject_2[0] + xxx * tmp.h_traject_2[1] + xxx^2 * tmp.h_traject_2[2], color = 200
    		oplot, xxx*0.5, tmp.h_traject_3[0] + xxx * tmp.h_traject_3[1] + xxx^2 * tmp.h_traject_3[2] + xxx^3 * tmp.h_traject_3[3], color = 100

    		erfn = 'f_' + gsdo_datefn(tmp.t_peak) + '__'      $
                    + string(tmp.x_start,f='(I0)') + '_' + string(tmp.y_start,f='(I0)')

            write_png, getenv('GSDO_DATA') + path_sep() + 'img' + path_sep() + erfn + '.png', tvrd(/true)
    	endif


    	if keyword_set(savegraph) then begin
    		gsdo_erup_sheets, tmp, index, data_raw, n_diff_t, float(mask)
    	endif

    	if keyword_set(savestruct) then begin
    		erupt_str = tmp
    		save, filename = gsdo_erupdir(tmp) + path_sep() + 'erupt_str.sav', erupt_str, description = gsdo_erupname(tmp)
    		undefine, erupt_str
    	endif

        gsdo_append, eruptions, tmp
        k = k + 1


        print, '    ---'



    endwhile

    n_found = n_elements(eruptions)

    ; if any eruptions were found
    if n_found gt 0 then begin


;        if keyword_set(savestruct) then begin
;            ; wygenerowac fnout
;            k1 = anytim( interv_start, /EX )
;            k2 = anytim( interv_end, /EX )
;
;            fnout = 'erup__' + string(wave,f='(I04)') + '__'      $
;                    + string(k1[6],f='(I0)') + strjoin(string(k1[[5,4]],f='(I02)')) + '__'       $
;                    + strjoin(string(k1[0:1],f='(I02)')) + '_' + strjoin(string(k2[0:1],f='(I02)'))
;
;            savpath = getenv('GSDO_DATA') + path_sep() + 'sav' + path_sep() + fnout + '.sav'
;            save, filename = savpath, interv_start, interv_end, eruptions
;            print, 'RESULT SAVED: ' + savpath
;        endif


        if _v then begin
            print, 'Eruptions found: ', n_elements(eruptions)
            print, '  -- F I N I S H E D --   ' + gsdo_toc()
        endif

        return, eruptions

    endif else begin

        if _v then print, ' No eruptions found :('
        return, -1

    endelse



end

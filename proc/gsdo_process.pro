

function gsdo_process, fn_list,          $
        transform_param = a_param,        $
        prob_threshold = prob_threshold,    $
        erupt_movement_threshold = erupt_movement_threshold,		$
        blur_apriori = blur_apriori,          $
        area_threshold = erupt_area_threshold,      $
        erupt_intensity_threshold = erupt_intensity_threshold,			$
        w_param = w_param, blur_image = blur_image,		$
        verbose = verbose, n_found = n_found, $
        n_points_min = n_points_min,   $
        map_max_tiles = map_max_tiles, $
        savestruct = savestruct, savegraph = savegraph

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    checkvar, prob_threshold, 0.5
    checkvar, blur_apriori, 0.0
    checkvar, blur_image, 0.0
	checkvar, n_points_min, 8
    checkvar, erupt_area_threshold, 200
    checkvar, erupt_movement_threshold, 25
    checkvar, erupt_intensity_threshold, 30
    checkvar, map_max_tiles, 12
    checkvar, w_param, 8

    _v = keyword_set(verbose)


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    help, /MEMORY

    gsdo_tic
    gsdo_header, 'Reading images...'

    m = 1
    read_sdo, fn_list, index0, data0n, m, m, 1024 - 2*m, 1024 - 2*m, /UNCOMP_DELETE, /NOSHELL

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

    print, '    DONE ' + GSDO_TOC()

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    sz = size(data0)

    ix_dark = where( total(total(data0,1),1)/(sz[1]*sz[2]) lt 10, cn_dark )
    if cn_dark gt 0 then data0[*,*,ix_dark] = !values.f_nan
    ix_broken = where( ~finite(data0), cn_broken )
    if cn_broken gt 0 then begin
    	gsdo_header, 'FIXING THE DATA'
        print, '     found black frames:', cn_dark
        print, '     found bad pixels:', cn_broken - cn_dark * sz(1) * sz(2)
    	data_fix = convol( data0, gsdo_psf([0,0,4]), /normalize, /nan )
    	data0[ix_broken] = data_fix[ix_broken]
    	undefine, data_fix
        print, '     PROBLEM SOLWED'
    endif


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    gsdo_tic

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    wave = index0[0].wavelnth

    case wave of
        171: a_def = 8.
        304: a_def = 2.5
        211: a_def = 3.
        else: a_def = 5.
    endcase

    checkvar, a_param, a_def, 1.

    print, 'Transformation parameter: ', a_param


    ;;; reject first and last frames of index
    n_clip = 1
    idx = findgen((size(data0))[3]-2*n_clip) + n_clip
    index = index0[idx]

    ;;; raw copy
    dataraw = gsdo_fix(data0[*,*,idx],0)

    ;;; smooth
    if blur_image gt 0.1 then begin
        gsdo_header, 'COMPUTING CONVOLUNTION'
        print, 'Convolving with kernel FWHM  =', blur_image
        psf2d = gsdo_psf2d(blur_image)
        data0 = convol( temporary(data0),   $
                reform(psf2d,[ size(psf2d,/dim), 1 ]), $
                /normalize, /nan )
    endif else data0 = gsdo_fix(temporary(data0),0)

    data = data0[*,*,idx]

    gsdo_header, 'COMPUTING DERIVATIVES'

    diff_t = (gsdo_deriv( data0, axis=3, order=1 ))[*,*,idx]

    ;;; normalized differentials -- computed from transformed fucntion
    n_data = gsdo_fix(alog(temporary(data0)+a_param),0)
    n_diff_t = (gsdo_deriv( n_data, axis=3, order=1 ))[*,*,idx]
    n_diff_tt = (gsdo_deriv( temporary(n_data), axis=3, order=2 ))[*,*,idx]


    ;;; compute variability index
    f_var = sqrt( (n_diff_t)^2 + 0.25*(n_diff_tt)^2 )

	n_diff_tt = 0

    print, '   -->  differentials OK'
    print, '    DONE ' + GSDO_TOC()


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    gsdo_tic
    gsdo_header, 'GENERATING ACTIVITY MAP'

    imgapr_master = gsdo_activity_map(index, data, f_var,   $
            max_tiles=map_max_tiles,  $
            min_tiles = 2, $
            w_param=w_param)

    print, 'Generating apriori done!'
    print, ' ----- OK ' + gsdo_toc()


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





    if blur_apriori gt 0.1 then begin
        gsdo_header, 'BLURRING PROBABILITY MAP'
        gsdo_tic
        psf2d = gsdo_psf2d(blur_apriori)
        imgapr_master_bl = convol((imgapr_master),    $
              reform(psf2d,[size(psf2d,/dim),1]),          $
              /EDGE_TRUNC)
        print, ' ----- OK ' + gsdo_toc()
    endif  else imgapr_master_bl = imgapr_master

    imgapr_master_mask = temporary(imgapr_master_bl) ge prob_threshold
    print, '   Probability threshold:', prob_threshold


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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

    n = (size(imgapr_master))[3]

    x_arr = gsdo_coord_arr(index, data, /X)
    y_arr = gsdo_coord_arr(index, data, /Y)




    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    k = 1
    kk = 1

    gsdo_tic
    gsdo_header, 'LOOKING FOR ERUPTIONS'



    while total(abs(imgapr_master_mask)) gt 0 do begin

        print, 'Candidate ' + string(kk, f='(I0)') + '...'
        print, '  (found ' + string(k-1, f='(I0)') + ')'

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
        print, '  points:', tmp.n_points

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

        print, '  area', tmp.area_x

        ; probability mask for weighted averages
        wts_glob = float(mask[*,*,idx]) * imgapr_master[*,*,idx]
        wts_glob = wts_glob / total(wts_glob)
        wts_t = total(total(wts_glob,1),1)
        wts_loc = wts_glob / gsdo_v2m(wts_t, wts_glob, axis=3)

        ; intesities, differences
        tmp.intens = total(total(wts_loc * dataraw[*,*,idx],1),1)
        tmp.intens_x = max(tmp.intens)
        tmp.intens_m = total(wts_glob * dataraw[*,*,idx])
        tmp.diff_t = total(total(wts_loc * diff_t[*,*,idx],1),1)
        tmp.n_diff_t = total(total(wts_loc * n_diff_t[*,*,idx],1),1)
        tmp.f_var = total(total(wts_loc * f_var[*,*,idx],1),1)
        tmp.f_var_m = total(wts_glob * f_var[*,*,idx])

        if  (tmp.intens_x le erupt_intensity_threshold) then continue

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

            print, '  start   ', anytim(tmp.t_start, /yohkoh)
            print, '  end     ', anytim(tmp.t_end, /yohkoh)
            print, '  (x,y)   ', tmp.x_start, tmp.y_start
            print, '  (kx,ky) ', vec_x, vec_y

        if vec_d ge erupt_movement_threshold then begin
        	tmp.is_eruption = 1
        	print, '  POSSIBLE ERUPTION!'
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
        	print, 'Trajectory:'
        	print, tmp.h_traject_2
        endif else continue


        gsdo_erup_sheets, tmp, index, dataraw, n_diff_t, imgapr_master, float(mask)
        erupt_str = tmp
        save, filename = gsdo_erupdir(tmp) + path_sep() + 'erupt_str.sav', erupt_str, description = gsdo_erupname(tmp)
        undefine, erupt_str


        gsdo_append, eruptions, tmp
        k = k + 1


        print, '    --------------------------------'



    endwhile

    n_found = n_elements(eruptions)

    gsdo_header, 'F I N I S H E D   ' + gsdo_toc()

    ; if any eruptions were found
    if n_found gt 0 then begin

        print, 'Eruptions found: ', n_elements(eruptions)

        return, eruptions

    endif else begin

        print, ' No eruptions found :('
        return, 0

    endelse



end

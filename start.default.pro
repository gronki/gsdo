

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;                                                      ;;;;
    ;;;;                    GSDO/AIA                          ;;;;
    ;;;;                                                      ;;;;
    ;;;;       Main code for automated eruption detection     ;;;;
    ;;;;       on SDO/AIA 171/304 A images.                   ;;;;
    ;;;;                                                      ;;;;
    ;;;;       version: 2015/05/13                            ;;;;
    ;;;;                                                      ;;;;
    ;;;;       D.Gronkiewicz 2015                             ;;;;
    ;;;;       Master Thesis                                  ;;;;
    ;;;;                                                      ;;;;
    ;;;;                                                      ;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  


    
    start_time  = '15-mar-2012 00:24'
    end_time    = '31-mar-2012 00:36'
    
    interval    = (60*4)*60l
    wave        = 171

    test_mode = 0
    
    marg = 3
    
    error_handling = 1

    set_plot,'Z'
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    gsdo_log, 'STARTING ===== ' + anytim(start_time,/yoh,/trunc) + ' - ' + anytim(end_time,/yoh,/trunc)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    
    sl = path_sep() 

    ; directory where fits files are stored
    fits_dir = getenv('GSDO_DATA') + sl + (test_mode ? 'fits_test' : 'fits')
    sav_dir = getenv('GSDO_DATA') + sl + 'sav'
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    
    t0 = anytim(start_time)
    
    anchfn = sav_dir + sl + 'anchor.sav'
    if (FILE_SEARCH(anchfn))[0] ne '' then begin
    	restore, filename = anchfn
    	t = anytim(time_finished)
    	if (t gt anytim(start_time)) and (t lt anytim(end_time)) then begin
    		gsdo_log, 'Restoring saved point ' + anytim(t,/yoh,/trunc)
    		t0 = t
    	endif 
    endif
    
    t1 = t0 + interval
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    
    while t1 le anytim(end_time) do begin  
        
        if error_handling then begin
		    catch, err
		    if err ne 0 then begin
		    	print,'  ERROR  ERROR  ERROR  ERROR  ERROR  ERROR !!!!!!!!'
		    	gsdo_log, 'Severe error on interval: ' + anytim(t0,/yoh,/trunc) + ' - ' + anytim(t1,/yoh,/trunc)
		    	t0 = t1 & t1 = t0 + interval
		    	catch,/cancel
		    	continue
		    endif
        endif
        
        if test_mode eq 0 then begin
            ; clean up
    
			fn0 = FILE_SEARCH(fits_dir + path_sep() + '*.fits', /FOLD_CASE)
		
			if fn0[0] ne '' then begin
				file_delete, fn0, /allow_nonexistent
			endif
    
		    pushd, fits_dir
		    print, 'Downloading data...'
		    
		    gsdo_synop_get, anytim(t0 - marg*2*60. - 1), anytim(t1 + marg*2*60. + 1), filter = wave, /verb
		    popd
        endif
        
        fn = FILE_SEARCH(fits_dir + path_sep() + '*.fits', /FOLD_CASE)
        
        if fn[0] eq '' then begin
            message, 'error: no files'
        endif
        
        eruptions = gsdo_process(fn,                        $
                prob_threshold = 0.35,                      $
                prob_smooth = 7,                            $
                area_threshold = 600,                       $
                n_points_min = 10,							$
                erupt_movement_threshold = 25,				$
                erupt_intensity_threshold = 30,				$
                n_found = n_found,                          $
                w_param = 8,							$
                /SaveStruct, /Verbose, /savegraph, windowed=(test_mode ne 0))
        
      ;  if n_found ne 0 then        $
      ;      gsdo_append, eruptions_all, eruptions

		gsdo_log, 'FINISHED ('+anytim(t0,/yoh,/trunc) + ' - ' + anytim(t1,/yoh,/trunc)+')'
		gsdo_log, '     found eruptions ' + string(n_found)
        
        if ~test_mode then begin
        	time_finished = t1
        	save, filename = anchfn, time_finished
        endif
        
        t0 = t1 & t1 = t0 + interval
        
        if test_mode then break
        
        
    
    endwhile
    
   ; if n_elements(eruptions_all) ne 0 then begin
   ;     save, filename = sav_dir + path_sep() + 'all__' + gsdo_datefn(start_time)        $
   ;             + '__' + gsdo_datefn(end_time) + '.sav',        $
   ;             eruptions_all, start_time, end_time
   ; endif
    
   gsdo_log, ' === JOB ENDED ===' 


end

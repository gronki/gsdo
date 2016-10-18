function gsdo_activity_map, index, data, f_var,         $
        max_tiles = max_tiles, $
        w_param = w_param, $
        min_tiles = min_tiles

  on_error, 2


  ;;; define the grid of rectangular elements
  checkvar, max_tiles, 8
  checkvar, min_tiles, 1
  gridz = gsdo_tilegen(max_tiles,min_tiles=min_tiles)
  sz = size(data)
  sq_areas = sz[1]*sz[2]/(gridz[0,*]*gridz[1,*])

  ;;; this will be the final product: probability map
  imgapr_master = float(data * 0)
  imgapr = float(data * 0)

  ;;; compute center pixel of solar disk
  sunc = GSDO_COORDS(index[0],0,0,/PIXEL)

  ;;; iterate thru grid configurations
  for k = 0, n_elements(gridz[0,*])-1 do begin

    sz = size(data)
    imgapr[*] = 0

    ;;; divide img into squares
    sqr0 = gsdo_squarization( sz[1], sz[2], gridz[0,k], gridz[1,k] )

    ;;; ignore squares that are in corners if tiles are small
    ;;; (less than 150pix)
    if sqrt(sq_areas[k]) ge 80 then begin
      sqr = sqr0
    endif else begin
      sqr = sqr0[ where( ( (sqr0.xc - sunc[0])^2    $
              + (sqr0.yc - sunc[1])^2 ) le ( (sz[1]-35)*sqrt(2.) )^2 ) ]
    endelse

    print, '   ----------------'
    print, 'Iteration ' + string(k+1,f='(I0)')
    grid_str = string(gridz[0,k],gridz[1,k],f='(I0,"x",I0)')
    print, '   --> sq division: ', grid_str


    if gsdo_flag('GSDO_EXTRAPLOT') then begin
        square_dir = getenv('GSDO_DATA') + '/img/' + grid_str
        mk_dir,square_dir
    endif

    ;;; now iterate through small rectangles

    for i = 0, n_elements(sqr)-1 do begin

        if gsdo_flag('GSDO_EXTRAPLOT') then begin
            panel_str = string(sqr(i).ix,sqr(i).iy,f='("X",I0,"Y",I0)')
            panel_dir = square_dir + '/' + panel_str
            mk_dir,panel_dir
            setenv, 'GSDO_PANEL_DIR=' + panel_dir
        endif

        ;;; extract coordinates
        xr = [ sqr[i].xll, sqr[i].xtr ]
        yr = [ sqr[i].yll, sqr[i].ytr ]

        ;;; crop a rectangle
        GSDO_IXDATA_CROP, index, data, index_crp, data_crp,    $
                XRANGE=xr, YRANGE=yr, /PIXEL
        GSDO_IXDATA_CROP, index, f_var, index_crp, f_var_crp,    $
                XRANGE=xr, YRANGE=yr, /PIXEL

        ;;; compute a-priori probability of activity
        imgapr_crp = gsdo_apriori_map( index_crp, data_crp, f_var_crp,  $
                w_param = w_param )

        ;;; add the square to entire image
        imgapr[xr[0]:xr[1],yr[0]:yr[1],*] = imgapr_crp
    endfor

    print, '            OK'

    ;;; add the contribution to the stack
    imgapr_master = temporary(imgapr_master)    $
            + imgapr / n_elements(sq_areas)

    if getenv('GSDO_EXTRAPLOT') ne 0 then begin
		set_graph, 120, 120, /mm
		!p.multi = 0
		plot_rgb, mono2rgb(total(imgapr,3) / n_elements(sq_areas),min=0.5,max=0), index=index(0), title='FINAL PROBABILITY MAP for ' + grid_str
		write_png, square_dir + '/map.png', tvrd(/true)
    endif

  endfor

  return, imgapr_master

end

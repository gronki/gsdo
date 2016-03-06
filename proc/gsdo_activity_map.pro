function gsdo_activity_map, index, data, f_var,         $
        max_tiles = max_tiles, windowed = windowed, w_param = w_param

  on_error, 2  
  
  _w = keyword_set(windowed)
  
  ;;; define the grid of rectangular elements
  checkvar, max_tiles, 8
  gridz = gsdo_tilegen(max_tiles,min_tiles=2)
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
    print, '   --> sq division:', reform(gridz[*,k])
    
    ;;; now iterate through small rectangles
    
    for i = 0, n_elements(sqr)-1 do begin
    
      ;;; extract coordinates
      xr = [ sqr[i].xll, sqr[i].xtr ]
      yr = [ sqr[i].yll, sqr[i].ytr ]
    
      ;;; crop a rectangle
      GSDO_IXDATA_CROP, index, data, index_crp, data_crp,    $
          XRANGE=xr, YRANGE=yr, /PIXEL   
      GSDO_IXDATA_CROP, index, f_var, index_crp, f_var_crp,    $
          XRANGE=xr, YRANGE=yr, /PIXEL    
      
      ;;; compute a-priori probability of activity
      imgapr_crp = gsdo_apriori_map( index_crp, data_crp, f_var_crp, windowed = windowed, w_param = w_param )
    
      ;;; add the square to entire image
      imgapr[xr[0]:xr[1],yr[0]:yr[1],*] = imgapr_crp
    endfor
    
    print, '            OK' 
    
    ;;; add the contribution to the stack
    imgapr_master = temporary(imgapr_master)    $
            + imgapr / n_elements(sq_areas)
    
    if _w then begin
		window, 3, xs = 800, ys = 800
		!p.multi = 0 & loadct, 0
		plot_image, total(imgapr,3) / n_elements(sq_areas), min = 0, max = 1
		gsdo_shot        
    endif        
            
  endfor
  
  return, imgapr_master
  
end



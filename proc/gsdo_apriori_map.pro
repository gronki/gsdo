function gsdo_apriori_map, index, data, f_var, windowed = windowed, n_iter = n_iter, w_param = w_param

	_w = keyword_set(windowed)
	checkvar, n_iter, 3
	checkvar, w_param, 8

    ;;; compress using asinh
    af_var = alog10(f_var)
    l_data = alog10(float(data))


	if _w then begin
		window, 3, xs = 1000, ys = 800
		!p.multi = [0,3,2] & loadct, 0       
    endif 
    ;;; determine quiet frames
    ix_q = GSDO_QUIET_INDICES(index,f_var,data, w1=w_param, plot=_w)
    
    b = round(float(n_elements(data))^(1/4.))
      
    ;;; and make histogram of them   
    h_q = GSDO_HIST2D(/STRUCT,   $
          af_var[*,*,ix_q], $
          l_data[*,*,ix_q],    $
          MIN_X = -2.2, MAX_X = 0, N_X = b,   $
          MIN_Y = 1.3, MAX_Y = 4.5, N_Y = b, /nonorm)
          
    h_all = gsdo_hist2d(/struct, like = h_q,        $
            af_var, l_data, /nonorm)      
            
    ;;; kernel used to smooth probabilities
    ;krn_hist = gsdo_psf([3,2])        
    ;;; smooth probability distribution for less noise
    ;;; during division
    hq_conv = float(h_q.hist)/n_elements(ix_q);, krn_hist, /EDGE_TRUNC) 
    hall_conv = float(h_all.hist)/n_elements(data[0,0,*]);, krn_hist, /EDGE_TRUNC)  
    
    ;;; compute apriori probability that pixel is not quiet
    h_apr = h_q
    ;h_apr.hist = ((h_all.hist - h_q.hist)>0)/(h_all.hist) 
    
    ;;; assume eruption fill factor of 1%
    s = 0.001

    sh = fltarr(n_iter)
    
    for i = 0,n_iter-1 do begin
		;;; calculate a-priori probability
		h_apr.hist = gsdo_fix( ((hall_conv - (1.-s)*hq_conv)>0) / hall_conv, 0) 
		sh[i] = s
		
		;;; remap it to an image       
		imgapr = GSDO_HIST2D_REMAP(af_var, l_data, h_apr)
		
		;;; recompute eruption fill factor
		s = ( total(float(imgapr gt 0.5)) / n_elements(imgapr) ) < 0.5
		
    endfor
    
    if _w then begin
		gsdo_plot_hist2d, h_all
		gsdo_plot_hist2d, h_q
		plot_image, h_apr.hist, min=0, max=1, /nosq
		plot_image, total(imgapr,3), min=0, max=(size(imgapr))[3], title='s='+string(s)
		plot, sh, yr=[0.000001,1], /yl, ps=-1
		gsdo_shot        
    endif 
       
;    ;;; space for apriori images
;    imgapr = l_data * 0.  

;    ;;; make a gaussian filter to mask out the noise in the middle
;    ;      gq = 1.- exp( -(h_q.grid_x)^2/sigm_dead^2 )

;    ;;; iterate thru frames
    ; sz = size(data)   
    ; fn_gen = strjoin(string(sz,f='(I0)'),'x')
   ;
;    for j = 0, sz[3]-1 do begin
;        ;;; make the IV diagram
;        h = GSDO_HIST2D(/STRUCT, LIKE=h_q,      $
;            af_var[*,*,j], $
;            l_data[*,*,j])
;        ;;; smooth it    
;        h_conv =  convol(h.hist, krn_hist, /EDGE_TRUNC) 
;        ;;; compute apriori probability
;        h_apr = h_q & h_apr.hist = ((h_conv-hq_conv)>0)/h_conv
;        ;;; invert it and save to image cube
;        a = GSDO_HIST2D_REMAP(af_var[*,*,j],    $
;            l_data[*,*,j],h_apr)
;        imgapr[*,*,j] = GSDO_FIX(a)
;    endfor
    
    return, imgapr
end

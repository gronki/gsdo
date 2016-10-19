function gsdo_apriori_map, index, data, var,  n_iter = n_iter, w_param = w_param

	checkvar, n_iter, 5
	checkvar, w_param, 8

    ;;; compress using asinh
    log_fvar = alog10(float(var))
    log_data = alog10(float(data))

    ;;; determine quiet frames
    ix_q = GSDO_QUIET_INDICES(index,var,data, w1=w_param)

	blur_scale = 3.0
	b = round(blur_scale * float(n_elements(data))^(1/4.))

	print, 'b = ', b

    ;;; and make histogram of them
    h_q = GSDO_HIST2D(/STRUCT,   $
          log_fvar[*,*,ix_q], $
          log_data[*,*,ix_q],    $
          MIN_X = -2.5, MAX_X = 0.5, N_X = b,   $
          MIN_Y = 1.0, MAX_Y = 4.5, N_Y = b)

    h_all = gsdo_hist2d(/struct, like = h_q,        $
            log_fvar, log_data)

    ;;; kernel used to smooth probabilities
    krn_hist =  gsdo_psf2d(blur_scale * 1.66667)
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

    for i = 1,n_iter do begin
		;;; calculate a-priori probability
		h_apr.hist = gsdo_fix( ((h_all_conv.hist - (1.-s)*h_q_conv.hist)>0) / h_all_conv.hist,0)
		h_apr.hist = float(h_apr.hist)

		;;; remap it to an image
		imgapr = GSDO_HIST2D_REMAP(log_fvar, log_data, h_apr)

		;;; recompute eruption fill factor
		s = ( total(float(imgapr gt 0.5)) / n_elements(imgapr) ) < 0.5

    endfor

    return, imgapr
end

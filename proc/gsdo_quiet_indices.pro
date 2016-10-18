function gsdo_quiet_indices, index, cube1, cube2,  QUANT=quant, title=tit,  $
    PLOT=plot, QUIETNESS=quietness, w1 = w1, w2 = w2

  CHECKVAR, quant, 0.2
  checkvar, w1, 1.
  checkvar, w2, 1.

  _p = keyword_set(plot)

  N = n_elements(index)


  m1 = dblarr(N)
  m2 = dblarr(N)


  for i = 0, N-1 do begin
    e = cube1[*,*,i]
    ixx = where(finite(e),nf)
    m1[i] = (nf gt 0) ? mean(e[ixx]) : 100000.
    e = cube2[*,*,i]
    ixx = where(finite(e),nf)
    m2[i] = (nf gt 0) ? mean(e[ixx]) : 100000.
  endfor

  var_indic = w1*(m1-mean(m1))/stddev(m1)     $
            + w2*(m2-mean(m2))/stddev(m2)
  quietness = var_indic

  if _p then begin

    CLEAR_UTPLOT

    t = anytim((index.date_obs))
    t0 = min(t)

   ; stop
    checkvar, tit, 'SELECTING QUIET FRAMES'
    UTPLOT, t - t0, var_indic, t0,  ps=-1, TITLE=tit,    $
      YTITLE='Variability index'

  endif


;  thr = median(var_indic[where(var_indic le median(var_indic))])
;
;  if _p then OUTPLOT, max(t-t0)*[-1,2], [1,1] * ( thr ), t0, LineStyl=2
;
;
;  return, where(var_indic le thr)

	s = sort(var_indic)
	q_idx = s[0:round(n_elements(s)*quant)]


	 if _p then begin

		OUTPLOT, (t - t0)[q_idx], var_indic[q_idx], t0,  ps=6, symsize=2

	  endif

	return, q_idx
end

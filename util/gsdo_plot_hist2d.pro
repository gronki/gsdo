PRO GSDO_PLOT_HIST2D, h_str,            $
        max=max,                        $
        min=min,                        $
        title=title,                    $
        xtitle=xtitle,                  $
        ytitle=ytitle,                  $
        linear = linear,                $
        sqrt_scaling = sqrt_scaling,    $
        asinh_scaling = asinh_scaling

  if not keyword_set(max) then max = max(h_str.hist)
  if not keyword_set(min) then min = 0

  device, decomposed = 1

  if keyword_set(asinh_scaling) then begin
      _h = asinh(h_str.hist)
      _min = asinh(max)
      _max = asinh(min)
  endif else if keyword_set(sqrt_scaling) then begin
      _h = sqrt(h_str.hist)
      _min = sqrt(max)
      _max = sqrt(min)
  endif else begin
      _h = h_str.hist
      _min = max
      _max = min
  endelse

  plot_rgb, $
        mono2temperature(temporary(_h),min=_min,max=_max), $
        /NOSQUARE,    $
        ORIGIN=[h_str.min_x,h_str.min_y],    $
        SCALE=[h_str.bin_x,h_str.bin_y], $
        title=title, xtitle=xtitle,  ytitle=ytitle
END

function gsdo_plot_hist2d_compress, x
    a = 0.08
    return, alog10(a + x) - alog10(a)
end

PRO GSDO_PLOT_HIST2D, h_str,            $
        paper=paper,                    $
        max=max,                        $
        min=min,                        $
        title=title,                    $
        xtitle=xtitle,                  $
        ytitle=ytitle,                  $
        linear = linear

  if not keyword_set(max) then max = max(h_str.hist)
  if not keyword_set(min) then min = 0

  device, decomposed = 1

  if keyword_set(linear) then begin
      _h = h_str.hist
      _min = max
      _max = min
  endif else begin
      _h = gsdo_plot_hist2d_compress(h_str.hist)
      _min = gsdo_plot_hist2d_compress(max)
      _max = gsdo_plot_hist2d_compress(min)
  endelse

  plot_rgb, $
        mono2temperature(temporary(_h),min=_min,max=_max), $
        /NOSQUARE,    $
        ORIGIN=[h_str.min_x,h_str.min_y],    $
        SCALE=[h_str.bin_x,h_str.bin_y], $
        title=title, xtitle=xtitle,  ytitle=ytitle
END

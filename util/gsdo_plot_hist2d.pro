PRO GSDO_PLOT_HIST2D, h_str, paper=paper, max=max, min=min,  _EXTRA=_extra

  if not keyword_set(max) then max = max(h_str.hist)
  if not keyword_set(min) then min = 0

  device, decomposed = 1

  if gsdo_flag('GSDO_IMAGES_COLOR') then begin
      g = mono2temperature(sqrt(h_str.hist),min=sqrt(max),max=sqrt(min))
  endif else begin
      g = mono2rgb(sqrt(h_str.hist),min=sqrt(max),max=sqrt(min))
  endelse

  plot_rgb, g, /NOSQUARE,    $
    ORIGIN=[h_str.min_x,h_str.min_y],    $
    SCALE=[h_str.bin_x,h_str.bin_y], _EXTRA=_extra
END

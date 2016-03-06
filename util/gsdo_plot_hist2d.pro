PRO GSDO_PLOT_HIST2D, h_str, paper=paper,  _EXTRA=_extra

  ct = 39
  sg = 1.
  if keyword_set(paper) then begin
    ct = 9
    sg = -1.
  endif
  LOADCT, ct, /SILENT
  PLOT_IMAGE, sg*SQRT(h_str.HIST), /NOSQUARE,    $
    ORIGIN=[h_str.min_x,h_str.min_y],     $
    SCALE=[h_str.bin_x,h_str.bin_y], _EXTRA=_extra
  LOADCT, 0, /SILENT  
END

PRO GSDO_PLOT_HIST2D, h_str,  _EXTRA=_extra
  LOADCT, 39, /SILENT
  PLOT_IMAGE, SQRT(h_str.HIST), /NOSQUARE,    $
    ORIGIN=[h_str.min_x,h_str.min_y],     $
    SCALE=[h_str.bin_x,h_str.bin_y], _EXTRA=_extra
  LOADCT, 0, /SILENT  
END

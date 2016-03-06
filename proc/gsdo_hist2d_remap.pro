function gsdo_hist2d_remap, img_x, img_y, hist
  cub = hist.hist
  RETURN, interpolate(cub,  (img_x - hist.min_x)/hist.bin_x,    $
                            (img_y - hist.min_y)/hist.bin_y, missing = 0)
end

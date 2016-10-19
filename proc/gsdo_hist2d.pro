function GSDO_HIST2D, data_x, data_y,   $
    MIN_X=min_x, MAX_X=max_x, BIN_X=bin_x, N_X=n_x,   $
    MIN_Y=min_y, MAX_Y=max_y, BIN_Y=bin_y, N_Y=n_y,   $
    LIKE=hist_alike,   $
    VERBOSE=verbose,  $
    STRUCT = struct, $
    NORMALIZE=Normalize

  CHECKVAR, min_x, min(data_x)
  CHECKVAR, max_x, max(data_x)
  CHECKVAR, min_y, min(data_y)
  CHECKVAR, max_y, max(data_y)

  _p = keyword_set(plot)
  _v = keyword_set(verbose)

  if n_elements(hist_alike) ne 0    $
        and size(hist_alike,/TNAME) eq 'STRUCT' then begin
    if _v then PRINT, 'GSDO_HIST2D: Copying histogram properties..'
    min_x = hist_alike.min_x
    max_x = hist_alike.max_x
    bin_x = hist_alike.bin_x

    min_y = hist_alike.min_y
    max_y = hist_alike.max_y
    bin_y = hist_alike.bin_y
  endif


  bin_present = (n_elements(bin_x) ne 0) and (n_elements(bin_y) ne 0)
  n_present = (n_elements(n_x) ne 0) and (n_elements(n_y) ne 0)

  IF not bin_present THEN BEGIN
    ;;; bins are not given
    IF NOT n_present THEN BEGIN
      ;;; if n not present, assume
      n_x = 50 & n_y = 50
    ENDIF
    ;;; compute bin widths
    bin_x = abs(0.d + max_x - min_x) / (n_x-1L)
    bin_y = abs(0.d + max_y - min_y) / (n_y-1L)
  endif

  ;;; bins are given, calculate n's
  n_x = FLOOR( abs(0.d +max_x - min_x)/bin_x ) + 1L
  n_y = FLOOR( abs(0.d +max_y - min_y)/bin_y ) + 1L

  ;;; locations
  loc_x = min_x + bin_x * findgen(n_x)
  loc_y = min_y + bin_y * findgen(n_y)

  grid_x = REBIN(loc_x, n_x, n_y)
  grid_y = REBIN(TRANSPOSE(loc_y), n_x, n_y)

  hist = hist_2d(data_x,data_y,    $
    MIN1=min_x, MAX1=max_x, BIN1=bin_x,  $
    MIN2=min_y, MAX2=max_y, BIN2=bin_y )

  IF keyword_set(normalize) THEN   $
    hist = 1. * hist / n_elements(data_x)

  if keyword_set(struct) then begin
    return, {    $
          TYPE: 'XY',   $
          hist:float(hist),    $
          min_x:min_x, max_x:max_x, bin_x:bin_x, N_X:n_x, LOC_X:loc_x, GRID_X:grid_x,   $
          min_y:min_y, max_y:max_y, bin_y:bin_y, N_Y:n_y, LOC_Y:loc_y, GRID_Y:grid_y }
  endif

  return, hist

END

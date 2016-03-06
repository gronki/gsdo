FUNCTION GSDO_FNLIST, PICK=pick, T_RANGE=t_range, WAVE=wave

  if KEYWORD_SET(pick) then begin
    fn0 = DIALOG_PICKFILE(FILTER='AIA*.fits', /MULTIPLE, /MUST_EXIST)
  endif else begin
    fn0 = FILE_SEARCH('AIA*.fits', /FOLD_CASE)
  endelse
  
  range_given = N_ELEMENTS(t_range) eq 2
  wave_given = N_ELEMENTS(wave) eq 1
  
  if range_given or wave_given then begin
    READ_SDO, fn0, ix, dt, /UNCOMP_DELETE, /NOSHELL, /NODATA
  endif
  
  msk = BYTARR(N_ELEMENTS(fn0)) + 1b
  
  if range_given then begin  
    t = anytim(ix.date_obs)
    msk = msk and ( t ge (anytim(t_range[0])) and t le (anytim(t_range[1])))
  endif
  
  if wave_given then begin  
    msk = msk and ( ix.wavelnth eq wave )
  endif
  
  
  RETURN, fn0[WHERE(msk)]
END

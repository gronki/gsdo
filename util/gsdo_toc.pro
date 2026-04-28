function gsdo_toc, i, N
  common tictoc32131, tm, arr_id, arr_tm, is_init
  
  if n_elements(tm) eq 0 then gsdo_tic
  
  if N_PARAMS() eq 2 then begin
    return, GSDO_SEC2STR( (SYSTIME(1)-tm)/(i+1.)*(N-i-1.) )
  endif

  return, gsdo_sec2str(systime(1)-tm)
end
FUNCTION GSDO_SYNOP_NEARTIME, T0
  return, round(anytim(t0)/120.,/L64)*120.d
END

PRO GSDO_SYNOP_FILENAMES, t0, t1, out_local_names, out_remote_names, FILTER=filter

  CHECKVAR, filter, 304
  filt_str = string(filter,FORM='(I04)')

  url0 = 'http://jsoc.stanford.edu/data/aia/synoptic/'

  tm = gsdo_synop_neartime(t0)

  while tm le anytim(t1) do begin
    tm_str = anytim(tm,/CCSDS)

    arr1 = strsplit(tm_str,'T',/EXTRACT)
    date_arr = strsplit(arr1[0],'-',/EXTRACT)
    tm_arr = strsplit(arr1[1],':',/EXTRACT)

    rem_path = strjoin(date_arr,'/') + '/H' + tm_arr[0] + '00/'

    fn = 'AIA' + strjoin(date_arr,'') + '_' + tm_arr[0]     $
      + tm_arr[1] + '_' + filt_str + '.fits'

    gsdo_append, local_names, fn
    gsdo_append, remote_names, url0 + rem_path + fn

    tm = tm + 120.
  endwhile


  out_local_names = local_names
  out_remote_names = remote_names


END

PRO GSDO_SYNOP_GET, t0, t1, OUTDIR=outdir, FILTER=filter, verbose = verbose

  if n_elements(outdir) ne 0 then pushd, outdir

  _v = keyword_set(verbose)

  GSDO_SYNOP_FILENAMES, t0, t1, fn_loc, fn_rem, FILTER=filter

  tim_start = systime(1)

  gsdo_tic

  if n_elements(fn_loc) ne 0 then begin
    if _v then gsdo_header, string('Downloading ',n_elements(fn_loc),' images...', format='(A,I0,A)')
    for i = 0, n_elements(fn_loc)-1 do begin
      wait, 0.3
      tmp = webget(fn_rem[i], COPYFILE=fn_loc[i])
      strtmleft = gsdo_sec2str( 1.*(systime(1)-tim_start)/(i+1)*(n_elements(fn_loc)-1-i) )
      if _v then PRINT, 'GOT ' + fn_loc[i]
      if _v then PRINT, '    ---> left ' + strtmleft
    endfor
  endif

  if _v then print, 'Total time: ', gsdo_toc()

  if n_elements(outdir) ne 0 then popd, outdir

END

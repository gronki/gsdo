PRO GSDO_APPEND, arr, elm
  if n_elements(arr) eq 0     $
    then arr = [ elm ]    $
    else arr = [ [arr], elm ]
END

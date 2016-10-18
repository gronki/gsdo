function gsdo_squarization_tilesize, x, d

  ;;; calculate remainders -- we want the best division
  dev = round(.1*d)
  if dev eq 0 or (x mod d) eq 0 then begin
    d_x = d
  endif else begin
    d_arr = d - dev + FINDGEN(2*dev+1)
    r_x = x mod d_arr
    ;;; pick the best
    m = MIN(r_x,i) & d_x = d_arr[i]
  endelse
  return, d_x
end

FUNCTION gsdo_squarization, x, y, n_x, n_y
  CHECKVAR, n_x, 5
  CHECKVAR, n_y, n_x

;  d_x = gsdo_squarization_tilesize(x,d)
;  d_y = gsdo_squarization_tilesize(y,d2)

;  n_x = FLOOR( 1. * x / d_x )
;  n_y = FLOOR( 1. * y / d_y )

  d_x = FLOOR( 1. * x / n_x )
  d_y = FLOOR( 1. * y / n_y )

  result = REPLICATE( { XLL:0., YLL:0.,     $
                        XTR:0., YTR:0.,     $
                        XC:0.,  YC:0.,      $
                        XD:0.,  YD:0.,      $
                        IX: 0, IY: 0,       $
                        NX: 0, NY: 0 }, n_x*n_y )

  result.XD = d_x
  result.YD = d_y

  k = 0L
  for i = 0L, n_x-1 do begin
    for j = 0L, n_y-1 do begin
      result[k].XLL = i * d_x
      result[k].YLL = j * d_y
      result[k].IX = i + 1
      result[k].IY = j + 1
      result[k].NX = n_x
      result[k].NY = n_y
      k = k + 1
    endfor
  endfor

  result.XTR = result.XLL + result.XD - 1L
  result.YTR = result.YLL + result.YD - 1L

  result.XC = 0.5 * ( result.XLL + result.XTR )
  result.YC = 0.5 * ( result.YLL + result.YTR )

  return, result

END

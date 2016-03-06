function GSDO_LAPBL_2D, xx
  r = xx * 1.d
  r = TEMPORARY(r) + SHIFT2(xx, 1, 0, 0) + SHIFT2(xx, -1, 0, 0)
  return, 0.2*(TEMPORARY(r)     $
      + SHIFT2(xx, 0, 1, 0) + SHIFT2(xx, 0, -1, 0))
end
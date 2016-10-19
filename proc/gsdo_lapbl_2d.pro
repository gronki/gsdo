
function shift2, p, dx, dy, dz

  CHECKVAR, dx, 0
  CHECKVAR, dy, 0
  CHECKVAR, dz, 0

  sz = size(p)
  dim = make_array(3, /LONG, VALUE=1)
  dim[0:sz[0]-1] = sz[1:sz[0]]

  ix = ((findgen(dim[0]) - (dx mod dim[0])) > 0) < (dim[0]-1)
  iy = ((findgen(dim[1]) - (dy mod dim[1])) > 0) < (dim[1]-1)
  iz = ((findgen(dim[2]) - (dz mod dim[2])) > 0) < (dim[2]-1)

  return, ((p[ix,*,*])[*,iy,*])[*,*,iz]
end

function GSDO_LAPBL_2D, xx
  r = xx * 1.d
  r = TEMPORARY(r) + SHIFT2(xx, 1, 0, 0) + SHIFT2(xx, -1, 0, 0)
  return, 0.2*(TEMPORARY(r)     $
      + SHIFT2(xx, 0, 1, 0) + SHIFT2(xx, 0, -1, 0))
end

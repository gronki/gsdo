
function sinthr, x
    return, 0.5*sin(((x < 1.) > (-1.))*!pi/2.)+0.5
end
function tanthr, x
    return, atan(x*!pi)  / !pi + 0.5
end

function thr,x, x1, x2
    y = (x-x1) / (x2 - x1 + 0.)
    return, ((y < 1) > 0)
end

function prism, x, x1, x2, x3
    return, thr(x,x1,x2) - thr(x,x2,x3)
end

function mono2temperature, x, min=min, max=max
    if n_elements(min) eq 0 then  min = min(x)
    if n_elements(max) eq 0 then  max = max(x)

    y = (x - min - 0.) / (max - min)
    y = ( ( temporary(y) > 0.0 ) < 1.0 )
    out = fltarr( [ 3, size(y,/dim) ] )
    z = y(*,*,*)

    out_r = thr(z,0.30,0.65) * 0.85 $
        + thr(z,0.65,1) * 0.15 $
        - 0.08 * prism(z,0.3,0.5,0.58)
    out_g = thr(z,0.05,0.65) * 0.3       $
        + thr(z,0.65,0.83) * 0.5        $
        + thr(z,0.83,1) * 0.2           $
        + 0.21 * prism(z,0.1,0.38,0.6)  $
        - 0.02 * prism(z,0.33,0.38,0.49)  $
        + 0.05 * prism(z,0.1,0.25,0.4)
    out_b = 0.15 * thr(z,0,0.18) $
        + 0.27 * prism(z,0,0.18,0.45) $
        + 0.1 * thr(z,0.45,0.85)  $
        + 0.8 * thr(z,0.85,1) $
        + 0.09 * prism(z,0.45,0.5,0.64)

    out[0,*,*,*] = temporary(out_r)
    out[1,*,*,*] = temporary(out_g)
    out[2,*,*,*] = temporary(out_b)
    return, bytscl(temporary(out),min=0.,max=1.)
end

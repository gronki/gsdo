
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

function mono2temperature, x, min=min, max=max
    if n_elements(min) eq 0 then  min = min(x)
    if n_elements(max) eq 0 then  max = max(x)

    y = (x - min - 0.) / (max - min)
    y = ( ( temporary(y) > 0.0 ) < 1.0 )
    out = fltarr( [ 3, size(y,/dim) ] )
    z = y(*,*,*)

    out_r = thr(z,0.25,0.7) * 0.92 + thr(z,0.7,1) * 0.08 ; + ( -thr(z,0.6,0.7) + thr(z,0.7,0.8) ) * 0.4
    out_g = thr(z,0.05,0.4) * 0.3 + thr(z,0.65,0.85) * 0.5 + thr(z,0.85,1) * 0.2 + 0.18 * ( thr(z,0.1,0.3) - thr(z,0.4,0.6) )
    out_b = 0.5 * thr(z,0,0.18) - 0.4 * thr(z,0.25,0.45)  + 0.9 * thr(z,0.85,1)

    out[0,*,*,*] = temporary(out_r)
    out[1,*,*,*] = temporary(out_g)
    out[2,*,*,*] = temporary(out_b)
    return, bytscl(temporary(out),min=0.,max=1.)
end

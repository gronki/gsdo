
function sinthr, x
    return, 0.5*sin(((x < 1.) > (-1.))*!pi/2.)+0.5
end
function tanthr, x
    return, atan(x*!pi)  / !pi + 0.5
end

function mono2rainbow, x, min=min, max=max
    if n_elements(min) eq 0 then  min = min(x)
    if n_elements(max) eq 0 then  max = max(x)

    xx = (x - min - 0.) / (max - min)
    y = 6. * ( ( temporary(xx) > 0.0 ) < 1.0 ) - 3.
    out = fltarr( [ 3, size(y,/dim) ] )
    z = y(*,*,*)

    rp = [-2.5, 2.0, 19, 20]
    gp = [ 0.2, 2.5, 18, 20]
    bp = [ 2.0, 1.3, 99, 20]

    out[1,*,*,*] = sinthr((z-gp(0))/gp(1)) - sinthr((z-gp(2))/gp(3))
    out[0,*,*,*] = sinthr((z-rp(0))/rp(1)) - sinthr((z-rp(2))/rp(3))
    out[2,*,*,*] = sinthr((z-bp(0))/bp(1)) - sinthr((z-bp(2))/bp(3))
    return, bytscl(temporary(out),min=0.,max=1.)
end





PRO GSDO_HORNSCHUNCK_FLOW, diff_t, diff_x, diff_y, flow_x_out, flow_y_out, ITMAX=itmax, ALPHA=alpha

    CHECKVAR, itmax, 100
    CHECKVAR, alpha, 1.

    krn1 = [ [0,1,0], [1,0,1], [0,1,0] ] / 4.d
    krn2 = [ [1,2,1], [2,0,2], [1,2,1] ] / 12.d
    krn = reform(krn2,[3,3,1])

    sz = size(diff_t)
    if sz[0] ne 3 then begin
        MESSAGE, 'ERROR: image cube expected!'
        STOP
    endif

    flow_x = float(diff_t*0)
    flow_y = float(diff_t*0)

    k1 = 0.d + diff_x^2 + diff_y^2 + alpha^2

    FOR i = 0, itmax-1 DO BEGIN

        ;    flow_x_bl = flow_x & flow_y_bl = flow_y
        ;    FOR j = 0, sz[3]-2 DO BEGIN
        ;      flow_x_bl[*,*,j] = CONVOL(reform(flow_x[*,*,j]),krn2,/EDGE_TRUNC)
        ;      flow_y_bl[*,*,j] = CONVOL(reform(flow_y[*,*,j]),krn2,/EDGE_TRUNC)
        ;    ENDFOR

        flow_x_bl = convol(temporary(flow_x),krn,/Edge_Trunc)
        flow_y_bl = convol(temporary(flow_y),krn,/Edge_Trunc)

        k = ( diff_x * flow_x_bl + diff_y * flow_y_bl + diff_t ) / k1

        flow_x = float( temporary(flow_x_bl) - diff_x * k  )
        flow_y = float( temporary(flow_y_bl) - diff_y * k  )

    ENDFOR

    flow_x_out = temporary(flow_x)
    flow_y_out = temporary(flow_y)

END

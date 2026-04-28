function gsdo_deriv, img, axis = axis, order = order
	
	checkvar, axis, 1
	checkvar, order, 1

	case order of
        1: krn1 = [-0.5,0,0.5]
        2: krn1 = [1,-2,1]
        else: message, 'order must be 1 or 2!'
	endcase
	
	ref = intarr((size(img))[0]) + 1
    ref[axis-1] = n_elements(krn1)	
    
  ;  stop
	return, convol(img, reform(krn1, ref), /edge_trunc)

end

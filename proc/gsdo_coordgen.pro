function gsdo_coordgen, dimensions, AXIS=axis, LIKE=like, FLOATING=floating, DOUBLE=double

    on_error, 2

	checkvar, axis, 1
	
	; if no dimensions were specified
	if n_elements(dimensions) eq 0 then begin
	    if n_elements(like) ne 0 then begin
	        dimensions = size(like, /DIM)
	    endif else begin
	        message, 'Dimensions not specified'
	    endelse
	endif

		
	; check if desired axis is within dimensions
	if axis gt n_elements(dimensions) then begin
	    ;message, 'Given axis ' + string(axis,F='(I0)') + ' is not within '       $
	    ;         + string(n_dim,F='(I0)') + 'D space.'
	    dim2 = intarr(axis) + 1
	    dim2[0] = dimensions
	    dimensions = dim2
    endif
    if axis le 0 then begin
	    message, 'Axes counting starts from 1.'
    endif
    
    ; number of dimensions
	n_dim =  n_elements(dimensions)
	
	; index of desired dimension
	x_idx = axis - 1
	
	; size in selected dimension
	x_sz = dimensions[x_idx]
	
	_t = 1l
	if keyword_set(floating) then _t = 1.
	if keyword_set(double) then _t = 1.d	
	
	; do the trick
	arr = intarr(n_dim)+1 & arr[x_idx] = x_sz
	return, rebin(reform(lindgen(x_sz)*_t,arr),dimensions)
	
end


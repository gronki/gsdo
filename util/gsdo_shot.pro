pro gsdo_shot, fn

	common gsdo_shot___, lastid
	if n_elements(lastid) eq 0 then lastid = 0
	
	if n_elements(fn) eq 0 then begin
		lastid = lastid + 1
		fn = 's' + string(lastid,f='(I08)')
	endif
	
	write_png, getenv('GSDO_DATA') + path_sep() + 'img' + path_sep() + fn + '.png', tvrd(/true)
end

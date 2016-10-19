pro plot_rgb, im, min=min, max=max, $
        index=index, subtitle = subtitle, title=title, $
        xtitle = xtitle, ytitle = ytitle, $
        _extra=_extra
    if n_elements(index) ne 0 then begin
        tstr = anytim(/yoh, index.date_obs)
        if n_elements(title) eq 0 then begin
            title = tstr
        endif else if n_elements(xtitle) eq 0 then begin
            xtitle = tstr
        endif else subtitle = tstr

        plot_image, rgb2plotimage(im), min=0, max=255, $
            origin=gsdo_coords(index,0,0,/arcsec), $
            scale=[index.cdelt1,index.cdelt2], $
            title=title, xtitle=xtitle, ytitle=ytitle, $
            subtitle = subtitle, $
            _extra=_extra
    endif else  plot_image, rgb2plotimage(im), min=0, max=255, $
        title=title, xtitle=xtitle, ytitle=ytitle, $
        subtitle = subtitle, $
        _extra=_extra
end

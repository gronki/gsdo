
pro gsdo_ixdata_crop, index0, data0, index1, data1,   PIXEL=pixel, ARCSEC=arcsec, $ 
      XRANGE=xrange,  YRANGE=yrange,   $
      CENTER=center,    DIMENSIONS=dimensions
      
   if   (n_elements(xrange) ne 2 or n_elements(yrange) ne 2)    $
    and (n_elements(center) ne 2 or n_elements(dimensions) ne 2) then begin
      message, 'You must specify 2 ranges or center point and dimensions.'
      return
   endif
   
   ;;; no corners but dimensions are present
   if (n_elements(xrange) ne 2 or n_elements(yrange) ne 2) then begin
      xrange = center[0] + 0.5*abs(dimensions[0])*[-1,1]
      yrange = center[1] + 0.5*abs(dimensions[1])*[-1,1]
   endif
   
   if not keyword_set(pixel) then begin
     crn1 = round( gsdo_coords( index0, xrange[0], yrange[0], /pix ) )
     crn2 = round( gsdo_coords( index0, xrange[1], yrange[1], /pix ) )
   endif else begin
     crn1 = [xrange[0],yrange[0]]
     crn2 = [xrange[1],yrange[1]]
   endelse
   
   ; crop to image dimensions
   crn1 = ((crn1 > 0) < ( (size(data0))[1:2] - 1 ))
   crn2 = ((crn2 > 0) < ( (size(data0))[1:2] - 1 ))
   
   data1 = data0[ crn1[0]:crn2[0], crn1[1]:crn2[1], * ]
   index1 = index0
   index1.crpix1 = index0.crpix1 - crn1[0]
   index1.crpix2 = index0.crpix2 - crn1[1]
   
   crn1_arc = gsdo_coords( index0, crn1[0], crn1[1], /arc )
   crn2_arc = gsdo_coords( index0, crn2[0], crn2[1], /arc )
   index1.xcen = mean([ crn1_arc[0],crn2_arc[0] ])
   index1.ycen = mean([ crn1_arc[1],crn2_arc[1] ])

end

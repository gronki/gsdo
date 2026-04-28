function gsdo_erupname, erup
	return, gsdo_datefn(erup.t_peak) + '_'      $
                    + ((erup.x_start ge 0) ? 'W' : 'E') + string(abs(erup.x_start),f='(I04)') + '_'   $
                    + ((erup.y_start ge 0) ? 'N' : 'S') + string(abs(erup.y_start),f='(I04)') 
                    
end

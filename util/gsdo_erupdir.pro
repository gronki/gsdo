function gsdo_erupdir, erup
	erfn = 'ER_' + gsdo_erupname(erup)
                
    er_dir = getenv('GSDO_DATA') + path_sep() + 'erup' + path_sep() + erfn           
    mk_dir, er_dir 
    return, er_dir
 end

;pro gsdo_setup
    
    findpro, 'gsdo_process', prolist=l
    
    if l[0] eq '' then begin

        !PATH = !PATH + path_sep(/s) + expand_path('+' + curdir())

        setenv,'GSDO_PATH='+curdir()
        setenv,'GSDO_DATA=' + getenv('GSDO_PATH') + path_sep() + 'data'
        
    endif
        
    mk_dir, getenv('GSDO_DATA')
    mk_dir, getenv('GSDO_DATA') + '/fits'
    mk_dir, getenv('GSDO_DATA') + '/sav'
    mk_dir, getenv('GSDO_DATA') + '/erup'
      
END

;pro gsdo_setup

    findpro, 'gsdo_process', prolist=l

    setenv, 'GSDO_IMAGES_DPI=150'
    setenv, 'GSDO_EXTRAPLOT=1'
    setenv, 'GSDO_MAKERECTS=0'

    if l[0] eq '' then begin

        !PATH = !PATH + path_sep(/s) + expand_path('+' + curdir())

        setenv,'GSDO_PATH='+curdir()
        setenv,'GSDO_DATA=' + getenv('GSDO_PATH') + path_sep() + 'data'

    endif

    mk_dir, getenv('GSDO_DATA')
    mk_dir, getenv('GSDO_DATA') + '/fits'
    mk_dir, getenv('GSDO_DATA') + '/sav'
    mk_dir, getenv('GSDO_DATA') + '/erup'
    mk_dir, getenv('GSDO_DATA') + '/img'

END

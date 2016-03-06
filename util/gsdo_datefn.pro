function gsdo_datefn, d

    k1 = anytim( d, /EX )

    return, string(k1[6],f='(I0)') + strjoin(string(k1[[5,4]],f='(I02)')) + '_'       $
                        + strjoin(string(k1[0:1],f='(I02)'))
                    
end

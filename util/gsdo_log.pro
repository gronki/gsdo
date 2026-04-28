pro gsdo_log, msg
  dt = anytim(mjd2any(systime(/jul)-2400000.5),/yoh,/trunc)
  fn = filepath('log.txt', root=getenv('GSDO_DATA'))
  s = '[' + dt + ']  ' + msg
  print,s
  file_append, fn, s
end

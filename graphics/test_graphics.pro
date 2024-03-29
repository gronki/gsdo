
n = 1000l
a = findgen(n)/(n-1)
a3 = (3*a) mod 1.
b = rebin(a,[n,n/4])
b3 = rebin(a3,[n,n/4])


; goto, aaa

set_graph, 150, 120, 1
; !p.multi = [0,2,2,0,1]
!p.multi = [0,1,2]

!PATH = !PATH + ':' + expand_path('+..')

r = mono2rainbow(b)
plot, a, r[0,*,0], /noda, yr=[0,255]
oplot, a, r[0,*,0], color=rgb(255,0,0)
oplot, a, r[1,*,0], color=rgb(0,255,0)
oplot, a, r[2,*,0], color=rgb(0,0,255)
oplot, a, sqrt((r[0,*,0]/255.0)^2 + (r[1,*,0]/255.0)^2 + (r[2,*,0]/255.0)^2) * 255, $
                color=rgb(40,40,40), linestyle=2
plot_rgb, r, scale=[a(1)-a(0),1],/nosq

; r3 = mono2rainbow(b3)
; plot, a*3, r3[0,*,0], /noda, yr=[0,255]
; oplot, a*3, r3[0,*,0], color=rgb(255,0,0)
; oplot, a*3, r3[1,*,0], color=rgb(0,255,0)
; oplot, a*3, r3[2,*,0], color=rgb(0,0,255)
; plot_rgb, r3, scale=[a3(1)-a3(0),1],/nosq

; aaa:

set_graph, 150, 120, 2
!p.multi = [0,1,2]

r = mono2temperature(b)
plot, a, r[0,*,0], /noda, yr=[0,255]
oplot, a, r[0,*,0], color=rgb(255,0,0)
oplot, a, r[1,*,0], color=rgb(0,255,0)
oplot, a, r[2,*,0], color=rgb(0,0,255)
oplot, a, sqrt((r[0,*,0]/255.0)^2 + (r[1,*,0]/255.0)^2 + (r[2,*,0]/255.0)^2) * 255, $
color=rgb(40,40,40), linestyle=2
plot_rgb, r, scale=[a(1)-a(0),1],/nosq

set_graph, 160,160, 3
!p.multi = [0,2,2]
x = findgen(1001) / 1000
plot, x, sin(4*x + 1), title='TYTUL', subtitle='PODTYTUL', xtit='OS X', ytit='OS Y'
plot, x, sin(2*x + 0.5), title='TYTUL', subtitle='PODTYTUL', xtit='OS X', ytit='OS Y'
plot, x, sin(11*x + 1), title='TYTUL', subtitle='PODTYTUL', xtit='OS X', ytit='OS Y'
plot, x, sin(9*x + 0.5), title='TYTUL', subtitle='PODTYTUL', xtit='OS X', ytit='OS Y'

end

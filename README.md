# GSDO
Automatyczna metoda poszukiwania erupcji w danych SDO/AIA.

Kontakt: gronki@camk.edu.pl

## Pobieranie programu
Aby pobrać program na swój komputer (wymagany system **Linux/UNIX/OSX**, powłoka **tcsh** i instalacja **IDL** w wersji 7 lub wyższej) najłatwiej wykonać polecenie (w katalogu roboczym, w którym chcemy ściągnąć program):
```
git clone --recursive https://github.com/gronki/gsdo.git
```

## Instalacja SSW w katalogu domowym
Program **GSDO** zakłada, że SSW z wymaganymi pakietami znajduję się w lokalizacji ``$HOME/.local/ssw``. Aby zainstalować SSW w tym położeniu, można uruchomić skrypt ``install`` znajdujący się w katalogu ``ssw``.
```
ssw/install
```
Powyższe polecenie zainstaluje minimalną wersję SSW. Aby zainstalować konieczne paczki SSW (``aia``, ``vobs``, ``ontology``), należy uruchomić SSWIDL i wykonać polecenie ``ssw_upgrade``.
```
# uruchamiamy sswidl
ssw/start
# instalujemy porzebne pakiety -- moze zajac dluzsza chwile!
ssw_upgrade,/aia,/vobs,/ontology,/nomail,/spawn,/loud,/passive
```

## Konfiguracja i uruchamianie

Aby skonfigurować parametry programu, trzeba najpierw utworzyć plik startowy. Najlepiej zrobić to na podstawie dostarczonego pliku ``start.default.pro``:
```
cp start.default.pro start.pro
```
Po wprowadzeniu zmian w pliku ``start.pro`` można uruchomić program w terminalu poleceniem ``./start``, lub, aby uruchomić program w tle (przydatne np. przy logowaniu przez sesję SSH), poleceniem ``./lazy-start``.

# GSDO
Automatyczna metoda poszukiwania erupcji w danych SDO/AIA.

Kontakt: gronki@camk.edu.pl

## Pobieranie programu
Aby pobrać program na swój komputer (wymagany system **Linux/UNIX/OSX**, powłoka **tcsh** i instalacja **IDL** w wersji 7 lub wyższej) najłatwiej wykonać polecenie (w katalogu roboczym, w którym chcemy ściągnąć program):
```
git clone --recursive https://github.com/gronki/gsdo.git
```

## SSWIDL requirements

It is advised that the SSW installation is located in the directory ``$HOME/.ssw``. If otherwise, this location can be changed in ``start_ssw`` file.

If SSW is not installed, here is a quick instruction.
Download the installation script ``ssw_install.csh`` from [SolarSoft website](http://www.lmsal.com/solarsoft/ssw_install.html). 
Make sure that **Transfer Protocol** is set to **cURL** and **Explicit Path** is set to ``$HOME/.ssw``.
Required SSW packages are ``aia``, ``vobs``, ``ontology``.
Then run the installation script using ``tcsh``.

## Konfiguracja i uruchamianie

Aby skonfigurować parametry programu, trzeba najpierw utworzyć plik startowy. Najlepiej zrobić to na podstawie dostarczonego pliku ``start.default.pro``:
```
cp start.default.pro start.pro
```
Po wprowadzeniu zmian w pliku ``start.pro`` można uruchomić program w terminalu poleceniem ``./start``, lub, aby uruchomić program w tle (przydatne np. przy logowaniu przez sesję SSH), poleceniem ``./lazy-start``.

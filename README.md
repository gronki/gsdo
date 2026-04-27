# GSDO
Automatic method for searching for eruptions in SDO/AIA data.

Contact: gronki@camk.edu.pl


## Requirements

- IDL version 7.0
- SSWIDL: ``aia``, ``vobs``, ``ontology``
- `curl` command
- `tcsh` shell

## Downloading the program

To download the program to your computer, click on the "Code" button, located to the top-right of the file list, and choose "Download ZIP".

If you work with git, you may use:

```
git clone --recursive --depth 1 https://github.com/gronki/gsdo.git
```


### SSWIDL requirements

It is advised that the SSW installation is located in the directory ``$HOME/.ssw``. If otherwise, this location can be changed in ``start_ssw`` file.

If SSW is not installed, here is a quick instruction.
Download the installation script ``ssw_install.csh`` from [SolarSoft website](http://www.lmsal.com/solarsoft/ssw_install.html). 
Make sure that **Transfer Protocol** is set to **cURL** and **Explicit Path** is set to ``$HOME/.ssw``.
Required SSW packages are ``aia``, ``vobs``, ``ontology``.
Then run the installation script using ``tcsh``.

### Curl

As of 2026, JSOC moved their servers to `https` protocol, which was not handled by IDL `winget` procedure. The new version is using `curl` command which must be available in the system.

## Configuration and running

To configure the program parameters, you first need to create a startup file. The easiest way is to base it on the provided file `gsdo_start.default.pro`:

```
cp gsdo_start.default.pro gsdo_start.pro
```

After making changes in `gsdo_start.pro`, you can run it from IDL console.

```
; only run setup once after starting IDL
.r gsdo_setup 
; you can re-run start many times
.r gsdo_start
```

# GSDO
Automatic method for searching for eruptions in SDO/AIA data.

Contact: gronki@camk.edu.pl


## Requirements

- IDL version 7.0 / GDL
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

### Windows 10 and 11

This program uses ``imcopy`` tool (via Ontology package), which may fail to load under more recent Windows systems. There could be an issue with files being downloaded to `fits` folder but silently failing to load, resulting in an error about "zero dimension for convolution". The solution is to install Visual C++ 2010 Redistributable [from Microsoft](https://www.microsoft.com/en-us/download/details.aspx?id=26999).

### Docker and GNU Data Language (GDL)

To keep the science open, an effort has been made that this program runs on free [GDL](https://gnudatalanguage.github.io/). It has been tested to provide pixel-to-pixel identical results in comparison with the proprietary IDL interpeter, although the setup requires a few adjustments:

- SSW AIA software needs a patch
- set environment variable `GSDO_DEVICE="X"`

The easiest way to run this code without an IDL license is to use [Docker Engine](https://www.docker.com/). Once [configured](https://docs.docker.com/engine/install/ubuntu/), the helper script should build the container and spin up the program:

```sh
./run_gdl_docker.sh
# add --detach to run in the background
```


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

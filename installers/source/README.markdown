# Source Files for dfsetup.run

`dfsetup.run` is a self-extracting tar archive (made using [Makeself](https://makeself.io/)) and contains the following 5 scripts (located in this folder):
* `setup.sh` - After `dfsetup.run` extracts it will call this script, which will determine the OS you are running on, and then call on the relevant script (below)
* `ubuntu.sh`
* `centos.sh`
* `debian.sh`
* `fedora.sh`

You can install df using the scripts in this folder instead of `dfsetup.run` if you wish. To do so simply make `setup.sh` executable with `chmod +x` and then run it with `sudo ./setup.sh` but note that `setup.sh` will call on the appropriately titled installer for your OS, and so that script must be in the same directory.
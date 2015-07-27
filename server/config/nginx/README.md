## Usage with nginx (1.6.x on Ubuntu 14.04)
On Ubuntu systems, do the following:

 1. copy the files from `config/external/nginx/etc/nginx/sites-available` into your `/etc/nginx/sites-available/` directory.
 2. Copy the files from `config/external/nginx/etc/nginx/conf.d` to your `/etc/nginx/conf.d` directory.
 3. Create an `/etc/nginx/sites-enabled` directory on your box if you do not have one.
 4. Create a symlink for the DSP: `$ sudo ln -s /etc/nginx/sites-available/dsp.single.local /etc/nginx/sites-enabled/dsp.local`

Edit the newly files accordingly to match your system configuration (i.e. log location, server name, etc.).

## Other OSes
CentOS and Redhat have similar virtual-host setups and you should be able to adapt the included files easily.

### Windows
You're on your own bud.

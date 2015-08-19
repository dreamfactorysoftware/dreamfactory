## Usage with Apache
On Ubuntu systems, copy the files from `config/external/apache/etc/apache2/sites-available` into your `/etc/apache2/sites-available/` directory.

Once there you can enable them and enable as follows:

### Enable
```
$ sudo a2ensite dsp.local ssl-dsp.local && sudo service apache2 restart
```

### Disable
```
$ sudo a2dissite dsp.local ssl-dsp.local && sudo service apache2 restart
```

## Other OSes
CentOS and Redhat have similar virtual-host setups and you should be able to adapt the included files easily.

### Windows
You're on your own bud.

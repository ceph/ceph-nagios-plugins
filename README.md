# Nagios plugins for Ceph

A collection of nagios plugins to monitor a [Ceph][] cluster.

## check_ceph_health

The `check_ceph_health` nagios plugin montiors the ceph cluster, and report its health.

### Usage

    usage: check_ceph_health [-h] [-e EXE] [-c CONF] [-m MONADDRESS] [-i ID] [-k KEYRING] [-d]

    'ceph health' nagios plugin.

    optional arguments:
      -h, --help            show this help message and exit
      -e EXE, --exe EXE     ceph executable [/usr/bin/ceph]
      -c CONF, --conf CONF  alternative ceph conf file
      -m MONADDRESS, --monaddress MONADDRESS
                            ceph monitor address[:port]
      -i ID, --id ID        ceph client id
      -k KEYRING, --keyring KEYRING
                            ceph client keyring file
      -d, --detail          exec 'ceph health detail'

## check_ceph_mon

The `check_ceph_mon` nagios plugin monitors an individual mon daemon, reporting its status.

Possible result includes OK (up), WARN (missing).

### Usage

    usage: check_ceph_mon [-h] [-e EXE] [-c CONF] [-m MONADDRESS] [-i ID]
                          [-k KEYRING] [-V] [-I MONID] [-H HOST]

    'ceph mon' nagios plugin.

    optional arguments:
      -h, --help            show this help message and exit
      -e EXE, --exe EXE     ceph executable [/usr/bin/ceph]
      -c CONF, --conf CONF  alternative ceph conf file
      -m MONADDRESS, --monaddress MONADDRESS
                            ceph monitor to use for queries (address[:port])
      -i ID, --id ID        ceph client id
      -k KEYRING, --keyring KEYRING
                            ceph client keyring file
      -V, --version         show version and exit
      -I MONID, --monid MONID
                            mon id to be checked for availability
      -H HOST, --host HOST  mon host to be checked for availability

## check_ceph_osd

The `check_ceph_osd` nagios plugin monitors an individual osd daemon, reporting its status.

Possible result includes OK (up), WARN (down or missing).

### Usage

    usage: check_ceph_osd [-h] [-e EXE] [-c CONF] [-m MONADDRESS] [-i ID]
                         [-k KEYRING] [-V] [-I OSDID] [-H HOST]

    'ceph osd' nagios plugin.

    optional arguments:
      -h, --help            show this help message and exit
      -e EXE, --exe EXE     ceph executable [/usr/bin/ceph]
      -c CONF, --conf CONF  alternative ceph conf file
      -m MONADDRESS, --monaddress MONADDRESS
                            ceph monitor address[:port]
      -i ID, --id ID        ceph client id
      -k KEYRING, --keyring KEYRING
                            ceph client keyring file
      -V, --version         show version and exit
      -I OSDID, --osdid OSDID
                            osd id
      -H HOST, --host HOST  osd host

### Authentication

Ceph is normally configured to use [cephx] to authenticate its client. 

To run the `check_ceph_health` plugin as user `nagios` you have to create a special keyring:

    root# ceph auth get-or-create client.nagios mon 'allow r' > client.nagios.keyring

And use this keyring with the plugin:

    nagios$ ./check_ceph_health --id nagios --keyring client.nagios.keyring
    
### Example

    nagios$ ./check_ceph_health --id nagios --keyring client.nagios.keyring
    HEALTH WARNING: 1 pgs degraded; 1 pgs recovering; 1 pgs stuck unclean; recovery 4448/28924462 degraded (0.015%); 2/9857830 unfound (0.000%); 
    nagios$ echo $?
    1
    nagios$

    nagios$ ./check_ceph_mon -H 172.17.0.2 -I a
    MON OK

    nagios$ ./check_ceph_mon -H 172.17.0.2 -I b
    MON WARN: no MON.b found at host 172.17.0.2

    nagios$ ./check_ceph_osd -H 172.17.0.2 -I 0
    OSD OK

    nagios$ ./check_ceph_osd -H 172.17.0.2 -I 0
    OSD WARN: OSD.0 is down at 172.17.0.2

    nagios$ ./check_ceph_osd -H 172.17.0.2 -I 100
    OSD WARN: no OSD.100 found at host 172.17.0.2

[ceph]: http://www.ceph.com
[cephx]: http://ceph.com/docs/master/rados/operations/authentication/

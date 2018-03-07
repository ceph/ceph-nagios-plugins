#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  Copyright (c) 2013-2016 SWITCH http://www.switch.ch
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

import argparse
import os
import subprocess
import sys
import re
import json

__version__ = '1.5.2'

# default ceph values
CEPH_COMMAND = '/usr/bin/ceph'

# nagios exit code
STATUS_OK = 0
STATUS_WARNING = 1
STATUS_ERROR = 2
STATUS_UNKNOWN = 3

def main():

    # parse args
    parser = argparse.ArgumentParser(description="'ceph health' nagios plugin.")
    parser.add_argument('-e','--exe', help='ceph executable [%s]' % CEPH_COMMAND)
    parser.add_argument('--cluster', help='ceph cluster name')
    parser.add_argument('-c','--conf', help='alternative ceph conf file')
    parser.add_argument('-m','--monaddress', help='ceph monitor address[:port]')
    parser.add_argument('-i','--id', help='ceph client id')
    parser.add_argument('-n','--name', help='ceph client name')
    parser.add_argument('-k','--keyring', help='ceph client keyring file')
    parser.add_argument('-w','--whitelist', help='whitelist regexp for ceph health warnings')
    parser.add_argument('-d','--detail', help="exec 'ceph health detail'", action='store_true')
    parser.add_argument('-V','--version', help='show version and exit', action='store_true')
    args = parser.parse_args()

    # validate args
    ceph_exec = args.exe if args.exe else CEPH_COMMAND
    if not os.path.exists(ceph_exec):
        print "ERROR: ceph executable '%s' doesn't exist" % ceph_exec
        return STATUS_UNKNOWN

    if args.version:
        print 'version %s' % __version__
        return STATUS_OK

    if args.conf and not os.path.exists(args.conf):
        print "ERROR: ceph conf file '%s' doesn't exist" % args.conf
        return STATUS_UNKNOWN

    if args.keyring and not os.path.exists(args.keyring):
        print "ERROR: keyring file '%s' doesn't exist" % args.keyring
        return STATUS_UNKNOWN

    # build command
    ceph_health = [ceph_exec]
    if args.monaddress:
        ceph_health.append('-m')
        ceph_health.append(args.monaddress)
    if args.cluster:
        ceph_health.append('--cluster')
        ceph_health.append(args.cluster)
    if args.conf:
        ceph_health.append('-c')
        ceph_health.append(args.conf)
    if args.id:
        ceph_health.append('--id')
        ceph_health.append(args.id)
    if args.name:
        ceph_health.append('--name')
        ceph_health.append(args.name)
    if args.keyring:
        ceph_health.append('--keyring')
        ceph_health.append(args.keyring)
    ceph_health.append('health')
    if args.detail:
        ceph_health.append('detail')

    ceph_health.append('--format')
    ceph_health.append('json')
    #print ceph_health

    # exec command
    p = subprocess.Popen(ceph_health,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    output, err = p.communicate()
    try:
        output = json.loads(output)
    except ValueError:
        return STATUS_UNKNOWN

    # parse output
    # print "output:", output
    #print "err:", err
    if output:
        ret = STATUS_OK
        msg = ""
        extended = ""
        if output.has_key('checks'):
            #luminous
            for check,status in output['checks'].iteritems():
                if status["severity"] == "HEALTH_ERR":
                    extended += msg
                    msg = "CRITCAL: %s( %s )" % (check,status['summary']['message'])
                    ret = STATUS_ERROR
                    continue

                if args.whitelist and re.search(args.whitelist,status['summary']['message']):
                    continue

                if not msg:
                    msg = "WARNING: %s( %s )" % (check,status['summary']['message'])
                    ret = STATUS_WARNING
                else:
                     extended += "%s( %s )" % (check,status['summary']['message'])+'\n'
        else:
            #pre-luminous
            for status in output["summary"]:
                if status != "HEALTH_OK":
                  if status == "HEALTH_ERROR":
                      msg = "CRITCAL: %s" % status['summary']
                      ret = STATUS_ERROR
                      continue

                  if args.whitelist and re.search(args.whitelist,status['summary']):
                      continue

                  if not msg:
                      msg = "WARNING: %s" % status['summary']
                      ret = STATUS_WARNING
                  else:
                     extended += status['summary']+'\n'
        if msg:
            print msg
        else:
            print "HEALTH OK"
        if extended: print extended
        return ret


    elif err:
        # read only first line of error
        one_line = err.split('\n')[0]
        if '-1 ' in one_line:
            idx = one_line.rfind('-1 ')
            print 'ERROR: %s: %s' % (ceph_exec, one_line[idx+len('-1 '):])
        else:
            print one_line

    return STATUS_UNKNOWN


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  Copyright (c) 2013 Catalyst IT http://www.catalyst.net.nz
#  Copyright (c) 2015 SWITCH http://www.switch.ch
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

from __future__ import print_function
import argparse
import socket
import os
import re
import subprocess
import sys
import json

__version__ = '1.5.0'

# default ceph values
CEPH_EXEC = '/usr/bin/ceph'
CEPH_COMMAND = 'quorum_status'

# nagios exit code
STATUS_OK = 0
STATUS_WARNING = 1
STATUS_ERROR = 2
STATUS_UNKNOWN = 3

##
# ceph quorum_status output example
##
ceph_quorum_status_output_example = '''{
   "quorum_leader_name" : "s0001",
   "monmap" : {
      "mons" : [
         {
            "name" : "s0001",
            "addr" : "[2001:620:5ca1:8000::1001]:6789/0",
            "rank" : 0
         },
         {
            "name" : "s0003",
            "addr" : "[2001:620:5ca1:8000::1003]:6789/0",
            "rank" : 1
         }
      ],
      "created" : "2014-12-15 08:28:35.153650",
      "epoch" : 2,
      "modified" : "2014-12-15 08:28:40.371878",
      "fsid" : "22348d2b-b69d-46cc-9a79-ca93cd6bae84"
   },
   "quorum_names" : [
      "s0001",
      "s0003"
   ],
   "quorum" : [
      0,
      1
   ],
   "election_epoch" : 24
}'''

def main():

  # parse args
  parser = argparse.ArgumentParser(description="'ceph quorum_status' nagios plugin.")
  parser.add_argument('-e','--exe', help='ceph executable [%s]' % CEPH_EXEC)
  parser.add_argument('-c','--conf', help='alternative ceph conf file')
  parser.add_argument('-m','--monaddress', help='ceph monitor to use for queries (address[:port])')
  parser.add_argument('-i','--id', help='ceph client id')
  parser.add_argument('-k','--keyring', help='ceph client keyring file')
  parser.add_argument('-V','--version', help='show version and exit', action='store_true')
  parser.add_argument('-I','--monid', help='mon ID to be checked for availability')
  args = parser.parse_args()

  if args.version:
    print('version %s' % __version__)
    return STATUS_OK

  # validate args
  ceph_exec = args.exe if args.exe else CEPH_EXEC
  if not os.path.exists(ceph_exec):
    print("MON ERROR: ceph executable '%s' doesn't exist" % ceph_exec)
    return STATUS_UNKNOWN

  if args.conf and not os.path.exists(args.conf):
    print("MON ERROR: ceph conf file '%s' doesn't exist" % args.conf)
    return STATUS_UNKNOWN

  if args.keyring and not os.path.exists(args.keyring):
    print("MON ERROR: keyring file '%s' doesn't exist" % args.keyring)
    return STATUS_UNKNOWN

  if not args.monid:
    print("MON ERROR: no MON ID given, use -I/--monid parameter")
    return STATUS_UNKNOWN

  # build command
  ceph_cmd = [ceph_exec]
  if args.monaddress:
    ceph_cmd.append('-m')
    ceph_cmd.append(args.monaddress)
  if args.conf:
    ceph_cmd.append('-c')
    ceph_cmd.append(args.conf)
  if args.id:
    ceph_cmd.append('--id')
    ceph_cmd.append(args.id)
  if args.keyring:
    ceph_cmd.append('--keyring')
    ceph_cmd.append(args.keyring)
  ceph_cmd.append(CEPH_COMMAND)

  # exec command
  p = subprocess.Popen(ceph_cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
  output, err = p.communicate()

  if p.returncode != 0 or not output:
    print("MON ERROR: %s" % err)
    return STATUS_ERROR

  # load json output and parse
  quorum_status = False
  try:
    quorum_status = json.loads(output)
  except Exception as e:
    print("MON ERROR: could not parse '%s' output: %s: %s" % (CEPH_COMMAND,output,e))
    return STATUS_UNKNOWN

  #print "XXX: quorum_status['quorum_names']:", quorum_status['quorum_names']

  # do our checks
  is_monitor = False
  for mon in quorum_status['monmap']['mons']:
    if mon['name'] == args.monid:
      is_monitor = True
  if not is_monitor:
    print("MON WARN: mon '%s' is not in monmap: %s" % (args.monid,quorum_status['monmap']['mons']))
    return STATUS_WARNING

  in_quorum = args.monid in quorum_status['quorum_names']
  if in_quorum:
    print("MON OK")
    return STATUS_OK
  else:
    print("MON WARN: no MON '%s' found in quorum" % args.monid)
    return STATUS_WARNING

# main
if __name__ == "__main__":
  sys.exit(main())

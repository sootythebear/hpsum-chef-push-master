# Base Version of HP SUM supported (set by HPE) - #.#.#
default['hpsum']['proxy']['version']['base'] = "7.3.0"

# Upper Version of HP SUM supported (set by HPE) - #.#.#
default['hpsum']['proxy']['version']['upper'] = "7.5.0"

# How many devices to update per run (HP SUM max. is 50 - 10 VMware max) - ##
default['hpsum']['proxy']['scope'] = 1

# Storage location of log files
default['hpsum']['proxy']['loglocation'] = "/var/hp/log/chefrun/proxy"

# Local server mount point for the HP SUM software
default['hpsum']['proxy']['sum']['locallocation'] = '/opt/hpsum'

# Remote NFS server and exported filesystem for HP SUM software
default['hpsum']['proxy']['sum']['remotelocation'] = 'xxx.xxx.xxx.xxx:/opt/mount1/hpsum'

# HP SUM NFS mount type - options are "rw", "ro", or "baseline"
default['hpsum']['proxy']['sum']['type'] = 'baseline'

# Clean local store repository before and after run - options nil or "true"
default['hpsum']['proxy']['local']['clean'] = nil

# Local store repository for copying HP SUM to server
default['hpsum']['proxy']['local']['directory'] = '/var/tmp'

# Local server mount point for firmware baseline
default['hpsum']['proxy']['baseline']['localfs'] = '/opt/gen9_fw'

# Remote NFS server and exported filesystem for Firmware baseline
default['hpsum']['proxy']['baseline']['remotefs'] = 'xxx.xxx.xxx.xxx:/opt/mount1/gen9_7_4_sum'

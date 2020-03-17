#
# Cookbook Name:: hp_sum_push
# Recipe:: hp_sum_push
#
# Copyright 2015, Hewlett Packard Enterprise
#
# All rights reserved - Do Not Redistribute
#
require 'fileutils'

#
# Record last run so to allow reports to show last and one back
#
node.set['hpsum']['proxy']['status']['previousrun'] = node['hpsum']['proxy']['status']['lastrun']

#
# Set up array range for this run. Create variable if first run, scope comes from attributes file.
# Arrays are 0 to #, hence endpos is -1 the next start position.
# Values are passed into install_fw resource; nextpos is set after this resource completes
#
if node['hpsum']['proxy']['status']['presentpos'] == nil
  startpos = 0
  nextpos = startpos + node['hpsum']['proxy']['scope']
  endpos = nextpos - 1
else
  startpos = node['hpsum']['proxy']['status']['presentpos']
  nextpos = startpos + node['hpsum']['proxy']['scope']
  endpos = nextpos - 1
end

#
# Delete local HP SUM if necessary - if "true"
#
if node['hpsum']['proxy']['local']['clean']
  directory node['hpsum']['proxy']['local']['directory'] + "/localhpsum" do
    recursive true
    action :delete
  end
end

#
# Create the local mount points and storage location directories as required
#
# HP SUM mountpoint
directory node['hpsum']['proxy']['sum']['locallocation'] do
  owner 'root'
  group 'root'
  mode 0755
  ignore_failure true
  action :create
end

# Baseline mountpoint
directory node['hpsum']['proxy']['baseline']['localfs'] do
  owner 'root'
  group 'root'
  mode 0755
  ignore_failure true
  action :create
end

# Create log folder
directory node['hpsum']['proxy']['loglocation'] do
  owner 'root'
  group 'root'
  mode 0755
  recursive true
  ignore_failure true
  action :create
end

#
# Mount HP SUM NFS mount point (if required - not for baseline)
#
case node['hpsum']['proxy']['sum']['type']
when "rw"
  log "Mounting HP SUM NFS FS read-write!" do
    level :info
  end

  mount node['hpsum']['proxy']['sum']['locallocation'] do
     device node['hpsum']['proxy']['sum']['remotelocation']
     fstype 'nfs'
     options 'rw'
  end
when "ro"
  log "Mounting HP SUM NFS FS read-only!" do
    level :info
  end

  mount node['hpsum']['proxy']['sum']['locallocation'] do
     device node['hpsum']['proxy']['sum']['remotelocation']
     fstype 'nfs'
     options 'ro'
  end
when "baseline"
  log "Using Baseline location in this iteration." do
    level :info
  end
end

#
# Mount the baseline NFS Mount Point
#
log "Mounting Firmware baseline NFS mount" do
  level :info
end

mount node['hpsum']['proxy']['baseline']['localfs'] do
   device node['hpsum']['proxy']['baseline']['remotefs']
   fstype 'nfs'
   options 'ro'
end

#
# Call resource to run HP SUM command, if HP SUM mount is RO, specify location (TMPDIR = localtmp)
# Resource used to allow Ruby checking that Baseline mount point includes HP SUM executables.
#
hp_sum_push_install_fw 'install_FW_SW' do
  hslocalmount node['hpsum']['proxy']['sum']['locallocation']
  bllocalmount node['hpsum']['proxy']['baseline']['localfs']
  nfstype node['hpsum']['proxy']['sum']['type']
  localtmp node['hpsum']['proxy']['local']['directory']
  loglocation node['hpsum']['proxy']['loglocation']
  baseversion node['hpsum']['proxy']['version']['base']
  upperversion node['hpsum']['proxy']['version']['upper']
  startpos startpos
  endpos endpos
  action :install
end

#
# Set the present position within the array for next run
#
node.set['hpsum']['proxy']['status']['presentpos'] = nextpos

#
# Manually unmount the NFS mounts - cannot notify from resource above.
#
mount node['hpsum']['proxy']['baseline']['localfs'] do
     device node['hpsum']['proxy']['baseline']['remotefs']
     action :umount
end

mount node['hpsum']['proxy']['sum']['locallocation'] do
     device node['hpsum']['proxy']['sum']['remotelocation']
     action :umount
end

#
# Remove local store if required - if "true"
#
if node['hpsum']['proxy']['local']['clean']
  directory node['hpsum']['proxy']['local']['directory'] + "/localhpsum" do
    recursive true
    action :delete
  end
end

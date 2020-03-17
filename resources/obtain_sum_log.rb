property :oblogdir, String

action :obtain_logs do

  require 'fileutils'

  Dir.chdir("#{oblogdir}")
  Dir.entries("#{oblogdir}/hp/log").each { |manageddevice|

# Ignore the parent and present files
    if manageddevice != "." and manageddevice != ".."
# Save the previous run result before posting latest results
      node.set['hpsum']['proxy']['result']["#{manageddevice}"]['previousrun'] = node.set['hpsum']['proxy']['result']["#{manageddevice}"]['lastrun']
# Save this runs results into the Chef Server
      node.set['hpsum']['proxy']['result']["#{manageddevice}"]['lastrun'] = `cat #{oblogdir}/hp/log/"#{manageddevice}"/hpsum_log.txt`
    end
  }
end

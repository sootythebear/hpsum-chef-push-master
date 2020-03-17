property :hslocalmount, String
property :bllocalmount, String
property :nfstype, String
property :localtmp, String
property :loglocation, String
property :baseversion, String
property :upperversion, String
property :startpos, Integer
property :endpos, Integer

action :install do

#
# Each option (rw, ro and baseline) performs the same tasks:
# 1. Configure range values for template file
# 2. set the command location dependant on rw, ro, or baseline config (command_bin)
# 3. find the version of the HP SUM executable (mountversion)
# 4. check version against tested values (if Gem::....)
# 5. call the resource to perform the actual install (performinstall)
# 6. set attribute on success or failure (node.set)
#
# Note: for baseline, we confirm the executable folder exists.
# For baseline, we pull the Ohai record for machine architect after step 1 (Dir.exists)
#

# Capture the date/time for this run
  date_time = `date +%F-%H-%M`.chomp

# Pull Databag of nodes for hub/proxy - each databag needs to match the hub machinename Ohai attribute
  servers = search("#{node[:machinename]}", "*:*")

# Find the length of the array
  serverslen = servers.length

# Ensure we do not start past the end of the databag array - end if we are

  if serverslen <= startpos
    log "We have come to the end of the databag list for this hub/proxy node!!" do
      level :info
    end
    node.set['hpsum']['proxy']['status']['lastrun'] = "Abandoned - Completed node list within databag - #{date_time}"
  else

# Ensure we do not run past the end of the array list of nodes within the databag - set value to last array

    if serverslen <= endpos
      epos = serverslen - 1
    else
      epos = endpos
    end

# Perform command dependant on mount type etc. Performinstall resource create hpsum.in file with range of nodes

    case nfstype
    when "rw"
      command_bin = "#{hslocalmount}/bin/hpsum"
      mountversion = `#{command_bin} -v`.scan(/[0-9]\.[0-9]\.[0-9]/)[0]

      if Gem::Version.new("#{baseversion}") <= Gem::Version.new("#{mountversion}") && Gem::Version.new("#{mountversion}") <= Gem::Version.new("#{upperversion}")
        hp_sum_push_performinstall 'Install' do
          picommand_bin command_bin
          pibllocalmount bllocalmount
          pilocaltmp localtmp
          piloglocation loglocation
          pistartpos startpos
          piendpos epos
          action :install
        end
        node.set['hpsum']['proxy']['status']['lastrun'] = "Success - rw - #{date_time}"
      else
        log "These cookbooks suppport HP SUM versions between #{baseversion} and #{upperversion}. We are not within this range of versions!!" do
          level :info
        end
        node.set['hpsum']['proxy']['status']['lastrun'] = "Abandoned - Wrong version(NFS) - #{date_time}"
      end
    when "ro"
      command_bin = "#{hslocalmount}/bin/hpsum"
      mountversion = `#{command_bin} -v`.scan(/[0-9]\.[0-9]\.[0-9]/)[0]

      if Gem::Version.new("#{baseversion}") <= Gem::Version.new("#{mountversion}") && Gem::Version.new("#{mountversion}") <= Gem::Version.new("#{upperversion}")
        hp_sum_push_performinstall 'Install' do
          picommand_bin command_bin
          pibllocalmount bllocalmount
          pilocaltmp localtmp
          piloglocation loglocation
          pistartpos startpos
          piendpos epos
          action :install
        end
        node.set['hpsum']['proxy']['status']['lastrun'] = "Success - ro - #{date_time}"
      else
        log "These cookbooks suppport HP SUM versions between #{baseversion} and #{upperversion}. We are not within this range of versions!!" do
          level :info
        end
        node.set['hpsum']['proxy']['status']['lastrun'] = "Abandoned - Wrong version(NFS) - #{date_time}"
      end
    when "baseline"
      local64 = "#{bllocalmount}/x64"

      if ::Dir.exist?(local64)
        if node.default['kernel']['machine'] = "x86_64"
          command_bin = "#{bllocalmount}/x64/hpsum_bin_x64"
          mountversion = `#{command_bin} -v`.scan(/[0-9]\.[0-9]\.[0-9]/)[0]

          if Gem::Version.new("#{baseversion}") <= Gem::Version.new("#{mountversion}") && Gem::Version.new("#{mountversion}") <= Gem::Version.new("#{upperversion}")
            hp_sum_push_performinstall 'Install' do
              picommand_bin command_bin
              pibllocalmount bllocalmount
              pilocaltmp localtmp
              piloglocation loglocation
              pistartpos startpos
              piendpos epos
              action :install
            end
              node.set['hpsum']['proxy']['status']['lastrun'] = "Success - baseline64 - #{date_time}"
            else
              log "These cookbooks suppport HP SUM versions between #{baseversion} and #{upperversion}. We are not within this range of versions!!" do
                level :info
              end
              node.set['hpsum']['proxy']['status']['lastrun'] = "Abandoned - Wrong version(baseline) - #{date_time}"
          end
        elsif node.default['kernel']['machine'] = "x86"
          command_bin = "#{bllocalmount}/x86/hpsum_bin_x86"
          mountversion = `#{command_bin} -v`.scan(/[0-9]\.[0-9]\.[0-9]/)[0]

          if Gem::Version.new("#{baseversion}") <= Gem::Version.new("#{mountversion}") && Gem::Version.new("#{mountversion}") <= Gem::Version.new("#{upperversion}")
            hp_sum_push_performinstall 'Install' do
              picommand_bin command_bin
              pibllocalmount bllocalmount
              pilocaltmp localtmp
              piloglocation loglocation
              pistartpos startpos
              piendpos epos
              action :install
            end
            node.set['hpsum']['proxy']['status']['lastrun'] = "Success - baseline86 - #{date_time}"
          else
            log "These cookbooks suppport HP SUM versions between #{baseversion} and #{upperversion}. We are not within this range of versions!!" do
              level :info
            end
            node.set['hpsum']['proxy']['status']['lastrun'] = "Abandoned - Wrong version(baseline) - #{date_time}"
          end
        else
          log "Cannot obtain CPU type for baseline, exiting without update." do
            level :info
          end
          node.set['hpsum']['proxy']['status']['lastrun'] = "Abandoned - Cannot obtain CPU type(baseline) - #{date_time}"
        end
      else
        log "Cannot locate the HP SUM executable within baseline mount, ensure baseline instead of ISO is mounted" do
          level :info
        end
        node.set['hpsum']['proxy']['status']['lastrun'] = "Abandoned - No HP SUM executable(baseline) - #{date_time}"
      end
    end
  end
end

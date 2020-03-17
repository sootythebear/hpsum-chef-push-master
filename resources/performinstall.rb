property :picommand_bin, String
property :pibllocalmount, String
property :pilocaltmp, String
property :piloglocation, String
property :pistartpos, Integer
property :piendpos, Integer

action :install do

#
# First part is to create hpsum.in file detailing requirements for proxy run
# Second part is the actual HP SUM command
# Third part stores this run's HP SUM result - a resource is called to pull the contents of the HP SUM log file
#

# Create hpsum.in file to advise on nodes and type of hpsum execution
# Create a unique folder to record this HP SUM run
  date_time = `date +%F-%H-%M`.chomp
  logdir = "#{piloglocation}/" + date_time

# Pull Databag of nodes for hub/proxy - each databag needs to match the hub machinename Ohai attribute
  servers = search("#{node[:machinename]}", "*:*")

# Create hpsum.in file from template file
  template "#{piloglocation}/hpsum.in"do
    source 'hpsum.in.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables({
      :logdir => logdir,
      :localmount => pibllocalmount,
      :nodes => servers,
      :startpos => pistartpos,
      :endpos => piendpos
    })
  end

  execute 'install' do
    command "#{picommand_bin} --inputfile #{piloglocation}/hpsum.in"
    environment 'TMPDIR' => "#{pilocaltmp}"
    returns [0,1,3]
    timeout 1800
  end

    hp_sum_push_obtain_sum_log 'sum_logfiles' do
      oblogdir logdir
      action :obtain_logs
    end
end

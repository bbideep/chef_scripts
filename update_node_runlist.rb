#!/usr/bin/env ruby

require 'json'
require 'chef/node'
require 'chef/rest'
require 'chef/log'
require 'chef/config'
require 'chef/application/client'

chefconfig = ''
chefdir = ''
runlist = ''

#Change the paths as required
if RUBY_PLATFORM[/mswin|msys|mingw|cygwin|bccwin|wince|emc/i]
	chefconfig = 'c:\chef\config.rb'
	chefdir = 'c:\chef'
else
	chefconfig = '/etc/chef/config.rb'
	chefdir = '/etc/chef'
end

if ((ARGV.length < 2) || (ARGV[0] != 'add' && ARGV[0] != 'remove'))
	usage = '*** Usage: ./update_node_runlist.rb add|remove recipe[mycookbook]|role[myrole] [Optional index location to add runlist. Default is the last index.]. ***'
	abort usage
end

action = ARGV[0]
runlist = ARGV[1]
indx = ARGV[2]

Chef::Config.from_file(chefconfig)

begin
	restclient = Chef::REST.new(Chef::Config[:chef_server_url])
	nodeobj = restclient.get_rest("/nodes/"+Chef::Config[:node_name])
	curr_runlist = JSON.parse(nodeobj.run_list.to_json)
	if action == 'add'
		if !curr_runlist.include?(runlist)
			if !indx.nil?
				curr_runlist.insert(indx.to_i, runlist)
			else
				#Append the input runlist to the end
				curr_runlist.push(runlist)
			end
		else
			abort 'Input runlist already exists on the node!'
		end
	else
		if curr_runlist.include?(runlist)
			curr_runlist.delete(runlist)
		else
			abort 'Input runlist does not exist on the node!'
		end
	end
	File.open("./nodedata", "w") do |f| 
		f.puts JSON.pretty_generate(nodeobj)
	end
	nodeobj_hash = JSON.parse(File.read('./nodedata'))
	nodeobj_hash['run_list'] = curr_runlist

	restclient.put_rest("nodes/"+Chef::Config[:node_name], nodeobj_hash)
	puts 'Updated runlist!'
	File.delete('./nodedata')
rescue Exception => e
	puts e.message
	puts e.backtrace
end
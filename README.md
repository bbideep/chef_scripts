# chef_scripts

##chef_upload_script.rb
	Usage: ./chef_upload_script.rb 'GitHub Repo URL' 'Databag|Cookbook|Role|Environment' 'Comma separated artifacts'
Comma separated artifacts can be Databag|Cookbook names, or Role|Environment file names like role1.rb,role2.rb


##update_node_runlist.rb
	Usage: ./update_node_runlist.rb add|remove recipe[mycookbook]|role[myrole] [Optional index location to add runlist. Default is the last index.].

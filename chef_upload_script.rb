#!/usr/bin/env ruby

if ARGV.length < 3
	puts "Usage: ./chef_upload_script.rb 'GitHub Repo URL' 'Databag|Cookbook|Role|Environment' 'Comma separated artifacts'"
	puts 'Comma separated artifacts can be Databag|Cookbook names, or Role|Environment file names like role1.rb,role2.rb'
	abort
end

$knifefile='KNIFE_CONFIG_PATH'
chefrepo='CHEF_REPO_PATH'
$databagpath="#{chefrepo}/data_bags"
$cookbookpath="#{chefrepo}/cookbooks"
$rolepath="#{chefrepo}/roles"
$envpath="#{chefrepo}/environments"
$githubrepo=ARGV[0]
artifacttype=ARGV[1]
artifactnames=ARGV[2]

if artifactnames.empty?
	abort 'Artifact names required!'
else
	artifacts = artifactnames.split(',')
end

case artifacttype
when 'Databag'
	`git clone #$githubrepo #$databagpath`
	artifacts.each do |artifact|
		`knife data bag create #{artifact} -c #$knifefile`
		`knife data bag from file #{artifact} #$databagpath/#{artifact}/*.json -c #$knifefile`
	end
when 'Cookbook'
	`git clone #$githubrepo #$cookbookpath`
	artifacts.each do |artifact|
		`knife cookbook upload #{artifact} -o #$cookbookpath -c #$knifefile`
	end
when 'Role'
	`git clone #$githubrepo #$rolepath`
	artifacts.each do |artifact|
		`knife role from file #$rolepath/#{artifact} -c #$knifefile`
	end
when 'Environment'
	`git clone #$githubrepo #$envpath`
	artifacts.each do |artifact|
		`knife environment from file #$envpath/#{artifact} -c #$knifefile`
	end
else
	abort 'Unknown Artifact Type!'
end

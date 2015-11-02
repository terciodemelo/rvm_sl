#
# Cookbook Name:: rvm
# Recipe:: default
#
# Copyright 2015, David Saenz Tagarro
#
# All rights reserved - Do Not Redistribute
#

user_name = node['rvm']['user']['name']
user_password = node['rvm']['user']['password']
home = "/home/#{user_name}"

package %w(gnupg curl)

keyserver = node['rvm']['keyserver']
recv_keys = node['rvm']['recv-keys']

ruby_block 'install_rvm' do
  block do
    cmd = Mixlib::ShellOut.new(
      "gpg --keyserver #{keyserver} --recv-keys #{recv_keys}",
      user: user_name, password: user_password, cwd: home)
    cmd.run_command
    cmd.error!

    cmd = Mixlib::ShellOut.new(
      '\curl -sSL https://get.rvm.io | bash -s stable',
      user: user_name, password: user_password, cwd: home)
    cmd.run_command
    cmd.error!
  end
  action :create
  notifies :run, 'execute[bootstrap_bashrc]', :immediately
end

execute 'bootstrap_bashrc' do
  command "echo '[[ -s \"$HOME/.rvm/scripts/rvm\" ]] && " \
          "source \"$HOME/.rvm/scripts/rvm\"' >> .bashrc"
  user user_name
  cwd home
  notifies :create, 'file[lock_rvm]', :immediately
  action :nothing
end

file 'lock_rvm' do
  path "#{home}/.lockrvm"
  name 'lock_rvm'
  user 'vagrant'
  action :nothing
end
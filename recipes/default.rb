
#  -------    CHEF-QEMU-SC --------

# LICENSETEXT
# 
#   Copyright (C) 2013 : GreenSocs Ltd
#       http://www.greensocs.com/ , email: info@greensocs.com
# 
# The contents of this file are subject to the licensing terms specified
# in the file LICENSE. Please consult this file for restrictions and
# limitations that may apply.
# 
# ENDLICENSETEXT

#Add these packages to your versions cookbook
#package "build-essential"
#package "cmake"
#package "libboost-filesystem1.49-dev"
#package "git"

directory "#{node[:prefix]}/ModelLibrary/greensocs/qemu_sc" do
  action :create
  recursive true
end


bash "Checkout QEMU SYSTEMC" do
  code <<-EOH
# need to specify branch
    git clone git://git.greensocs.com/qemu-sc.git -b new_system_c  #{node[:prefix]}/ModelLibrary/greensocs/qemu_sc.source
  EOH
  creates "#{node[:prefix]}/ModelLibrary/greensocs/qemu_sc.source"
  environment ({ 'http_proxy' => Chef::Config[:http_proxy] })
end

bash "Update QEMU SYSTEMC" do
  code <<-EOH
    cd #{node[:prefix]}/ModelLibrary/greensocs/qemu_sc.source
    git pull origin new_system_c
  EOH
  environment ({ 'http_proxy' => Chef::Config[:http_proxy] })
end

ruby_block "compile QEMU SystemC" do
  block do
     IO.popen(  <<-EOH
       for i in #{node[:prefix]}/bash.profile.d/*; do . $i; done
       # the profile should now include SystemC export SYSTEMC_HOME=/usr/local/systemc-2.3.0

       cd #{node[:prefix]}/ModelLibrary/greensocs/qemu_sc.source
       mkdir -p qemu_sc.build
       cd qemu_sc.build
       
       ../configure --prefix=#{node[:prefix]}/ModelLibrary/greensocs --target-list=arm-softmmu --enable-fdt --with-greensocs=#{node[:prefix]}/ModelLibrary/greensocs --with-systemc=/usr/local/systemc-2.3.0 --with-tlm=/usr/local/systemc-2.3.0 --with-boost=/usr
       make install
     EOH
   ) { |f|  f.each_line { |line| puts line } }
  end
end



# remote_file Chef::Config[:file_cache_path]+"/greenlib-1.0.0-Source.tar.gz" do
#   not_if {File.exists?('#{node[:prefix]}/ModelLibrary/greensocs/include')}
#   source "http://www.greensocs.com/files/greenlib-1.0.0-Source.tar.gz"
#   mode "0644"
#   action :create_if_missing
# end

# bash "get GreenLib" do
#   cwd Chef::Config[:file_cache_path]
#   code <<-EOH

#   tar xzf greenlib-1.0.0-Source.tar.gz
#   mkdir greenlib.build
#   cd greenlib.build

#   export SYSTEMC_HOME=/usr/local/systemc-2.3.0

#   cmake -DCMAKE_INSTALL_PREFIX=#{node[:prefix]}/ModelLibrary/greensocs ../greenlib-1.0.0-Source/
#   make install

#   EOH
#   creates "#{node[:prefix]}/ModelLibrary/greensocs/include"
# end

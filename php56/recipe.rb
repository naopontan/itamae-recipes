# naopontan pukiwiki の環境
# MEMO: pukiwiki は mysql 不要
# Amazon Linux 2018.03-release
# yum update -y は各自で
package 'httpd24' do
  action :install
end

# https でつながるようにする。 /etc/httpd/conf.d/ssl.conf が出来上がる
package 'mod24_ssl' do
  action :install
end

directory "/home/ec2-user/public_html" do
  owner "ec2-user"
  mode "0775"
end

file "/etc/httpd/conf/httpd.conf" do
  action :edit
  block do |content|
    content.gsub!(/^Listen 80$/, "#Listen 80")
    content.gsub!(/^DocumentRoot .*/, 'DocumentRoot "/home/ec2-user/public_html"')
  end
end

file "/etc/ssh/sshd_config" do
  action :edit
  block do |content|
    content.gsub!(/^Listen 80$/, "#Listen 80")
  end
end

# yum -y remove php70-*
%w[php56 php56-devel php56-mbstring php56-mcrypt php56-mysqlnd php56-pdo].each do |pkg|
  package pkg do
    action :install
  end
end

node.validate! do
  {
    myhome_ip: string,
  }
end

# 間違えるとアクセスできなくなるので注意!
# example:
# $ cat node.json
# {
#   "myhome_ip": "203.0.113.0/24"
# }
template "/etc/sysconfig/iptables" do
  owner "ec2-user"
end

execute "chmod 0755 ~ec2-user"

remote_file "/home/ec2-user/public_html/index.php" do
  owner "ec2-user"
  mode "0755"
end

# start しない!?
service 'httpd' do
  action [:enable, :start]
end

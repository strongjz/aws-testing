#!/Users/220033098/.rvm/rubies/ruby-2.0.0-p195

require 'aws-sdk'
require 'socket'
require 'net/ssh'
    
ip = IPSocket.getaddress(Socket.gethostname)
puts ip 


config_file = File.join(File.dirname(__FILE__), "config.yml")
AWS.config(YAML.load(File.read(config_file)))

time = Time.now

puts "creating the ec2 object"
ec2 = AWS::EC2.new(:ec2_endpoint => 'ec2.us-east-1.amazonaws.com')

puts "creating the key"
key_pair = ec2.key_pairs.create("ruby-test-key-#{time}")
private_key = key_pair.private_key

home = ENV['HOME']
puts "HOME IS: #{home}"
file = "#{home}/.ssh/ec2-#{time}"
File.open("#{file}", "wb") do |f|
  f.write(key_pair.private_key)
end

File.chmod(0660, "#{file}")

#public_key = key_pair.public_key
puts "Private Key is #{private_key}"
#puts "Public Key is #{public_key}"

puts "creating the sec group"
security_group = ec2.security_groups.create("ruby-test-sec-group-#{time}")

ip_addresses = ["#{ip}/0"]

security_group.authorize_ingress :tcp, 22, *ip_addresses		

puts "creating the instance"
instance = ec2.instances.create(
  :image_id => 'ami-ce35d1a6',
  :instance_type => 'g2.2xlarge',
  :count => 1, 
  :security_groups => "ruby-test-sec-group-#{time}", 
  :key_pair => ec2.key_pairs["ruby-test-key-#{time}"]
) 

if instance.exists?
  puts "instance exists"
  while instance.status != :running do 
  
    puts "STATUS: #{instance.status}"
  end

  dns = instance.dns_name

  puts "DNS name is : #{dns}"

#  key = Net::SSH::Authentication::KeyManager.new

#  key.add(private_key)

#  Net::SSH.start("#{dns}", "ubuntu", :) do |ssh|
#  result = ssh.exec!("ls -l")
#  puts result

#  end

else
  puts "instance does not exist"
end



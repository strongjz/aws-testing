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
ec2 = AWS::EC2.new(:ec2_endpoint => 'ec2.us-west-1.amazonaws.com')

puts "creating the key"
key_pair = ec2.key_pairs.create("ruby-test-key-#{time}")
private_key = key_pair.private_key;

puts "creating the sec group"
security_group = ec2.security_groups.create("ruby-test-sec-group-#{time}")

ip_addresses = ["#{ip}/0"]

security_group.authorize_ingress :tcp, 22, *ip_addresses		

puts "creating the instance"
instance = ec2.instances.create(
  :image_id => 'ami-11d68a54',
  :instance_type => 'm1.small',
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

else
  puts "instance does not exist"
end



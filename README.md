Tested on **Ubuntu Server 12.04 x64**

**Run in terminal**:
```
git clone https://github.com/arguslab/ancor-environment.git && cd ancor-environment
sudo ./install.sh
./install-local.sh
exit
```

Configures the following:

+ Official RabbitMQ and Puppetlabs repositories
+ MCollective
+ Puppet Master
+ Hiera with YAML and HTTP backends
+ Puppet Dashboard
+ Phusion Passenger (served by Apache2)
+ MySQL
+ RabbitMQ

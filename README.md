Tested on Ubuntu Server 12.04 x64

Configures the following:

+ Official RabbitMQ and Puppetlabs repositories
+ MCollective
+ Puppet Master
+ Hiera with YAML and HTTP backends
+ Puppet Dashboard
+ Phusion Passenge (served by Apache2)
+ MySQL
+ RabbitMQ

```
git clone https://github.com/arguslab/ancor-environment.git && cd ancor-environment
sudo ./install.sh
./install-local.sh
```

primary=${primary:-false}
node_ip=${node_ip:-"127.0.0.1"}
mongo_hosts=${mongo_hosts:-""}
for i in $mongo_hosts; do
  if [ -z "$hosts" ]; then
    hosts=$i
  else
    hosts="$hosts, $i"
  fi
done

wget https://apt.puppetlabs.com/puppetlabs-release-precise.deb
sudo dpkg -i puppetlabs-release-precise.deb
sudo apt-get update

sudo apt-get install puppet git iptables-persistent -y --force-yes
sudo puppet resource package puppetmaster ensure=latest

git clone https://github.com/stackforge/fuel-library /tmp/fuel-library

sudo chown -R $(whoami):$(whoami) /etc/puppet/modules

cp -r /tmp/fuel-library/deployment/puppet/* /etc/puppet/modules/
rm -rf /tmp/fuel-library

cp setup_mongo.pp tmp.pp
sed -i "s%<internal_address>%'$node_ip'%g" setup_mongo.pp
sed -i "s%<primary>%$primary%g" setup_mongo.pp
sed -i "s%<mongo_hosts>%$hosts%g" setup_mongo.pp

cat setup_mongo.pp

sudo puppet apply setup_mongo.pp -dv --modulepath=/etc/puppet/modules

mongo -uadmin -pceilometer admin --eval "printjson(rs.status())"

for i in $mongo_hosts; do
  if [ $i != "'$node_ip'" ]; then
    mongo -uadmin -pceilometer admin --eval "printjson(rs.add('$i'))"
  fi
done

cp tmp.pp setup_mongo.pp

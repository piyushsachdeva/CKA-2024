## 🗋 k8s-vmware-cluster/worker.sh

# k8s-vmware-cluster/worker.sh
#!/bin/bash

set -e

# Wait until the join.sh script exists
for i in {1..30}; do
  if [ -f /vagrant/join.sh ]; then
    break
  fi
  echo "[$(date '+%T')] Checking if /vagrant/join.sh exists... (try $i/30)"
  sleep 10
  if [ "$i" == "30" ]; then
    echo "Timeout waiting for /vagrant/join.sh"
    exit 1
  fi
  done

chmod +x /vagrant/join.sh
sudo bash /vagrant/join.sh
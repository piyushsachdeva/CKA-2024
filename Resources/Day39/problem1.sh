#!/usr/bin/env bash

# Wait for control-plane node to transition into the "Ready" status
while true; do 
  JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' && kubectl get nodes -o jsonpath="$JSONPATH" | grep "Ready=True" | grep "Ready=True" &> /dev/null
  if [[ "$?" -ne 0 ]]; then
    sleep 5
  else
    break
  fi
done

# Misconfigure kubelet configuration
sudo sed -i 's/clientCAFile: \/etc\/kubernetes\/pki\/ca.crt/clientCAFile: \/etc\/kubernetes\/pki\/non-existent-ca.crt/g' /var/lib/kubelet/config.yaml

# Restart kubelet to pick up new configuration
sudo systemctl daemon-reload
sudo systemctl restart kubelet

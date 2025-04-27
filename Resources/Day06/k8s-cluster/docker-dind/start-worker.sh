#!/bin/bash

containerd &

sleep 5

# Wait for the join command file
while [ ! -f /shared/join-command.sh ]; do
  echo "Waiting for join command..."
  sleep 2
done

bash /shared/join-command.sh

tail -f /dev/null

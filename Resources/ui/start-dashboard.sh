#!/bin/bash
rm -rf ./UI-token-admin-user.txt
kubectl -n kubernetes-dashboard create token admin-user>UI-token-admin-user.txt 
echo "-------------------------------------------------------------------------"
echo "token is :"
echo "-------------------------------------------------------------------------"
cat ./UI-token-admin-user.txt
echo "-------------------------------------------------------------------------"
rm -rf rm -rf ./UI-token-admin-user.txt
kubectl proxy

#   http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
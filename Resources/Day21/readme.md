# Day 21/40 - Manage TLS Certificates In a Kubernetes Cluster 

## Check out the video below for Day21 👇

[![Day 21/40 - Manage TLS Certificates In a Kubernetes Cluster ](https://img.youtube.com/vi/LvPA-z8Xg4s/sddefault.jpg)](https://youtu.be/LvPA-z8Xg4s)


### Commands used in the video

**To generate a key file**
```
openssl genrsa -out adam.key 2048
```

**To generate a csr file**
```
openssl req -new -key adam.key -out adam.csr -subj "/CN=adam"
```

**To approve a csr**
```
kubectl certificate approve <certificate-signing-request-name>
```

**To deny a csr**
```
kubectl certificate deny <certificate-signing-request-name>
```

**Below document can also be referred**

https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#create-certificatessigningrequest


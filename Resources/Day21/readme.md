# Day 21/40 - Manage TLS Certificates In a Kubernetes Cluster 

## Check out the video below for Day21 👇

[![Day 21/40 - Manage TLS Certificates In a Kubernetes Cluster ](https://img.youtube.com/vi/LvPA-z8Xg4s/sddefault.jpg)](https://youtu.be/LvPA-z8Xg4s)


### Tls in Kubernetes 

![image](https://github.com/user-attachments/assets/340139b0-e5db-4e28-91eb-96cf6cedc44b)

### Client-Server model

![image](https://github.com/user-attachments/assets/316de6e9-491e-4b89-af06-0b5fe2059f4f)

### How certs are loaded

![image](https://github.com/user-attachments/assets/adf2c877-c8b0-4e87-948f-f1f78ef25e27)

### Where we use certs in control plane components

![image](https://github.com/user-attachments/assets/ec9fd842-9a25-4138-afb4-930876adb8b8)


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


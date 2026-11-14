# Day 22/40 - Kubernetes Authentication and Authorization Simply Explained

## Check out the video below for Day22 👇

[![Day 22/40 - Kubernetes Authentication and Authorization Simply Explained](https://img.youtube.com/vi/P0bogYEyfeI/sddefault.jpg)](https://youtu.be/P0bogYEyfeI)


### Authentication: Verifying Who You Are

Imagine your cluster is a fortress.  Authentication is like checking IDs at the gate.  Kubeconfig is your keycard containing certificates that identify you to the Kubernetes API server.


![image](https://github.com/user-attachments/assets/057a58d8-537b-4dcb-96e6-ce195d1232bb)


### Making API Calls:

To run a command against a cluster, you can use the below command
```
kubectl get pods --kubeconfig config
```

Normally, kubectl uses your local `$HOME/.kube/config` file for authentication so you dont have to pass the --kubeconfig parameter in every command. You can use below command
```
kubectl get pods
```

The below command shows an API call using raw arguments:

```
kubectl get --raw /api/v1/namespaces/default/pods \
  --server https://localhost:64418 \
  --client-key adam.key \
  --client-certificate adam.crt \
  --certificate-authority ca.crt
```

### Authorization: What You Can Do

Authorization is like granting access levels within the fortress. Kubernetes offers different methods:

- Node Authorizer: Ensures kubelets on nodes are authorized to communicate with the API server.
- ABAC (Attribute-Based Access Control): Associates users with permissions but can be complex to manage.
- RBAC (Role-Based Access Control): The recommended approach! You create roles (like "dev") and assign users or groups to those roles.
- Webhooks (Optional): Leverage external tools like OPA for more complex authorization logic.

### Authorization Modes:

The API server can be configured with different authorization modes (like `AlwaysAllow` or `AlwaysDeny`), but these are for testing only. The modes are set with the `--authorization-mode` flag of the API server and are checked in the order in which they are listed. A kubeadm cluster uses `--authorization-mode=Node,RBAC` by default:

- Node Authorizer: Checks requests coming from the kubelets.
- RBAC: Grants access based on assigned roles.
- Webhook (if enabled): Asks an external service to make the decision.

As soon as one mode allows or denies the request, the decision is final. If a mode has no opinion, the request goes to the next mode. If no mode allows it, the request is denied.

```
sudo grep authorization-mode /etc/kubernetes/manifests/kube-apiserver.yaml
```

### Add a new user to your kubeconfig

Once you have a signed certificate for a user (Day 21), add the user and a context to your kubeconfig. You will need this for the Day 23 task.

```
kubectl config set-credentials adam --client-key=adam.key --client-certificate=adam.crt --embed-certs=true
kubectl config set-context adam --cluster=<cluster-name> --user=adam
kubectl config get-contexts
kubectl config use-context adam
kubectl auth whoami
```

You get the cluster name from `kubectl config get-clusters`. To go back to the admin user, run `kubectl config use-context <admin-context-name>`.

### Remember:

- Authentication verifies your identity.
- Authorization determines your access level.
- RBAC is a user-friendly and recommended way to manage authorization.

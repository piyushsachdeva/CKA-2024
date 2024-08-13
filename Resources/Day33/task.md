## Task for ingress

<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `default`<br>
* Documentation: [Ingresses](https://kubernetes.io/docs/concepts/services-networking/ingress/), [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

</p>
</details>

In this exercise, you will create an Ingress with a simple rule that routes traffic to a Service.

> [!IMPORTANT]
> Kubernetes requires running an Ingress Controller to evaluate Ingress rules. Make sure your cluster employs an [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/). You can find installation guidance in the Day33 video. 


1. Verify that the Ingress Controller is running.
2. Create a new Deployment named `web` that controls a single replica running the image `username/nodejs-hello-world:1.0.0` on port 3000.
3. Expose the Deployment with a Service named `web` of type `ClusterIP`. The Service routes traffic to the Pods controlled by the Deployment `web`.
4. Make a request to the endpoint of the application on the context path `/`. You should see the message "Hello World".
5. Create an Ingress that exposes the path `/` for the host `hello-world.exposed`. The traffic should be routed to the Service created earlier.
6. List the Ingress object.
7. Add an entry in `/etc/hosts` that maps the virtual node IP address to the host `hello-world.exposed`.
8. Make a request to `http://hello-world.exposed`. You should see the message "Hello World".

## Task 10/40


In this exercise, you will explore namespaces in depth by creating multiple Kubernetes resources.

> [!NOTE]
> If you do not already have a Kubernetes cluster, you can create a local Kubernetes cluster by following [Day06 Video](https://youtu.be/RORhczcOrWs)
Also, could you do the port binding at the cluster level if you are using KIND? The Day9 video has the details on how to do that.

### Task details
- Create two namespaces and name them ns1 and ns2
- Create a deployment with a single replica in each of these namespaces with the image as nginx and name as deploy-ns1 and deploy-ns2, respectively
- Get the IP address of each of the pods (Remember the kubectl command for that?)
- Exec into the pod of deploy-ns1 and try to curl the IP address of the pod running on deploy-ns2
- Your pod-to-pod connection should work, and you should be able to get a successful response back.
- Now scale both of your deployments from 1 to 3 replicas.
- Create two services to expose both of your deployments and name them svc-ns1 and svc-ns2
- exec into each pod and try to curl the IP address of the service running on the other namespace.
- This curl should work.
- Now try curling the service name instead of IP. You will notice that you are getting an error and cannot resolve the host.
- Now use the FQDN of the service and try to curl again, this should work.
- In the end, delete both the namespaces, which should delete the services and deployments underneath them.


3. **Share your learnings**: Document your key takeaways and insights in a blog post and social media update
4. **Make it public**: Share what you learn publicly on LinkedIn or Twitter.
   - **Tag us and use the hashtag**: Include the following in your post:
     - Tag [@PiyushSachdeva](https://www.linkedin.com/in/piyush-sachdeva) and [@CloudOps Community](https://www.linkedin.com/company/thecloudopscomm) (on both platforms)
     - Use the hashtag **#40daysofkubernetes**
     - **Embed the video**: Enhance your blog post by embedding the video lesson from the Kubernetes series. This will give you visual context and reinforce your written explanations.

## Blog Post Focus 📝

- **Clarity is essential**: Write your blog post clearly and concisely, making it easy for anyone to grasp the concepts, regardless of their prior Kubernetes experience.


## Task 6/40


1. **Task Details**
- Document your learnings from the video
- Following the [doc](https://kind.sigs.k8s.io/) install a single node kind cluster on your local machine with Kubernetes version 1.29
- Delete the cluster created in the above step
- Following the same [doc](https://kind.sigs.k8s.io/) install a multi-node kind cluster on your local machine using the below details:
    - **Cluster Name** :- cka-cluster2
    - **Nodes**:- 1 Control plane and 3 worker nodes
    - **Kubernetes Version** :- 1.30
- Install Kubectl client on the machine using the [doc]((https://kind.sigs.k8s.io/))
- Set the current context to the newly created cluster
- Run commands such as `kubectl get nodes` and ensure you have all the nodes ready
- These nodes are nothing but containers as KIND means Kubernetes IN Docker, which creates containers and uses them as nodes.
- Run `docker ps` command to verify that all nodes are running as containers.

**Please remember to include references to the video in your blog and any documentation you follow.**

2. **Share your learnings**: Document your key takeaways and insights in a blog post and social media update
3. **Make it public**: Share what you learn publicly on LinkedIn or Twitter.
   - **Tag us and use the hashtag**: Include the following in your post:
     - Tag [@PiyushSachdeva](https://www.linkedin.com/in/piyush-sachdeva) and [@CloudOps Community](https://www.linkedin.com/company/thecloudopscomm) (on both platforms)
     - Use the hashtag **#40daysofkubernetes**
     - **Embed the video**: Enhance your blog post by embedding the video lesson from the Kubernetes series. This will provide visual context and reinforce your written explanations.

## Blog Post Focus 📝

- **Clarity is essential**: Write your blog post clearly and concisely, making it easy for anyone to grasp the concepts, regardless of their prior Kubernetes experience.


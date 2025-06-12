## Task 18/40

In this exercise, you will explore health probes in Kubernetes
> [!NOTE]
> If you do not already have a Kubernetes cluster, you can create a local Kubernetes cluster by following [Day06 Video](https://youtu.be/RORhczcOrWs)
Also, could you do the port binding at the cluster level if you are using KIND? The Day9 video has the details on how to do that.

### Task details
1.
- Login to your cluster and create a pod with the image name as registry.k8s.io/busybox
- use the below command for the container
  `touch /tmp/healthy; sleep 30; rm -f /tmp/healthy; sleep 600`
- create a livenessprobe that executes the command `cat /tmp/healthy` after every 5 seconds, the first check should be after 5 seconds
- create another pod with the image name as `registry.k8s.io/e2e-test-images/agnhost:2.40`
- add the liveness and readiness probes that perform health checks on port 8080 on the path /healthz , the checks should start after 5 seconds for every 10 seconds

2. **Share your learnings**: Document your key takeaways and insights in a blog post and social media update
3. **Make it public**: Share what you learn publicly on LinkedIn or Twitter.
   - **Tag us and use the hashtag**: Include the following in your post:
     - Tag [@PiyushSachdeva](https://www.linkedin.com/in/piyush-sachdeva) and [@CloudOps Community](https://www.linkedin.com/company/thecloudopscomm) (on both platforms)
     - Use the hashtag **#40daysofkubernetes**
     - **Embed the video**: Enhance your blog post by embedding the video lesson from the Kubernetes series. This will give you visual context and reinforce your written explanations.

## Blog Post Focus 📝

- **Clarity is essential**: Write your blog post clearly and concisely, making it easy for anyone to grasp the concepts, regardless of their prior Kubernetes experience.

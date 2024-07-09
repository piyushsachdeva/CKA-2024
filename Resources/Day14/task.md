## Task 14/40

In this exercise, you will explore Taints and Tolerations in Kubernetes
> [!NOTE]
> If you do not already have a Kubernetes cluster, you can create a local Kubernetes cluster by following [Day06 Video](https://youtu.be/RORhczcOrWs)
Also, could you do the port binding at the cluster level if you are using KIND? The Day9 video has the details on how to do that.

### Task details
- Taint both of your worker nodes as below

   worker01--> gpu=true:NoSchedule , worker02--> gpu=false:NoSchedule
- Create a new pod with the image nginx and see why it's not getting scheduled on worker nodes and control plane nodes.
- Create a toleration on the pod gpu=true:NoSchedule to match with the taint on worker01
- The pod should be scheduled now on worker01
- Delete the taint on the control plane node
- Create a new pod with the image redis , it should be scheduled on control plane node
- Add the taint back on the control plane node(the one that was removed)

3. **Share your learnings**: Document your key takeaways and insights in a blog post and social media update
4. **Make it public**: Share what you learn publicly on LinkedIn or Twitter.
   - **Tag us and use the hashtag**: Include the following in your post:
     - Tag [@PiyushSachdeva](https://www.linkedin.com/in/piyush-sachdeva) and [@CloudOps Community](https://www.linkedin.com/company/thecloudopscomm) (on both platforms)
     - Use the hashtag **#40daysofkubernetes**
     - **Embed the video**: Enhance your blog post by embedding the video lesson from the Kubernetes series. This will give you visual context and reinforce your written explanations.

## Blog Post Focus 📝

- **Clarity is essential**: Write your blog post clearly and concisely, making it easy for anyone to grasp the concepts, regardless of their prior Kubernetes experience.

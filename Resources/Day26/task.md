## Task 26/40

In this exercise, you will learn Authentication and Authorization in Kubernetes

### Task details
1. Create a new kind cluster by disabling the default CNI
2. Install `Calico` Network Add-on to your Kind cluster
3. Create 3 deployments with as below:
    name: frontend , image-name: nginx , replicas=1 , containerPort
    name: backend , image-name: nginx , replicas=1 , containerPort
    name: db , image-name: mysql , replicas=1 , containerPort: 3306
4. Expose all of these applications on a nodePort service with the same name as the deployment name
5. Do the connectivity test that all of your pods are able to interact with each other.
6. Create a network policy and restrict the access so that only backend pod should be able to access the db service on port 3306.
7. Attach this network policy to the backend deployment
   
8. **Share your learnings**: Document your key takeaways and insights in a blog post and social media update
9. **Make it public**: Share what you learn publicly on LinkedIn or Twitter.
   - **Tag us and use the hashtag**: Include the following in your post:
     - Tag [@PiyushSachdeva](https://www.linkedin.com/in/piyush-sachdeva) and [@CloudOps Community](https://www.linkedin.com/company/thecloudopscomm) (on both platforms)
     - Use the hashtag **#40daysofkubernetes**
     - **Embed the video**: Enhance your blog post by embedding the video lesson from the Kubernetes series. This will give you visual context and reinforce your written explanations.

## Blog Post Focus 📝

- **Clarity is essential**: Write your blog post clearly and concisely, making it easy for anyone to grasp the concepts, regardless of their prior Kubernetes experience.

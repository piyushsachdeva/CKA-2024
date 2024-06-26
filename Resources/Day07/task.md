## Task 7/40


1. **Task Details** ☕️
- Document what you learned from the video in a blog, embed the video, and include all the references in the blog.

**Task 1**
- Create a pod using the imperative command and use nginx as the image

**Task2**
- Create the YAML from the nginx pod created in task 1
- Update the pod name in the YAML
- Use that YAML to create a new pod with the name nginx-new.

**Task3**
- Apply the below YAML and fix the errors, including all the commands that you run during the troubleshooting and the error message

```YAML
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: test
  name: redis
spec:
  containers:
  - image: rediss
    name: redis
    
```
2. **Share your learnings**: Document your key takeaways and insights in a blog post and social media update
3. **Make it public**: Share what you learn publicly on LinkedIn or Twitter.
   - **Tag us and use the hashtag**: Include the following in your post:
     - Tag [@PiyushSachdeva](https://www.linkedin.com/in/piyush-sachdeva) and [@CloudOps Community](https://www.linkedin.com/company/thecloudopscomm) (on both platforms)
     - Use the hashtag **#40daysofkubernetes**
     - **Embed the video**: Enhance your blog post by embedding the video lesson from the Kubernetes series. This will provide visual context and reinforce your written explanations.

## Blog Post Focus 📝

- **Clarity is essential**: Write your blog post clearly and concisely, making it easy for anyone to grasp the concepts, regardless of their prior Kubernetes experience.


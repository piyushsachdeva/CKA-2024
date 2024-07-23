## Task 23/40

In this exercise, you will learn RBAC and creating role and role binding objects.

### Task details

#### Checking Default User Permissions
Note: I am referring the username as `krishna` here in this task but feel free to use your own name or `adam` as per the previous task.
1. Change to the context to `krishna` that you created in the previous day 22 task.
2. Create a new Pod. What would you expect to happen?

#### Granting Access to the User

- Switch back to the original context with admin permissions. 
- Create a new Role named `pod-reader`. The Role should grant permissions to get, watch and list Pods.
- Create a new RoleBinding named `read-pods`. Map the user `krishna` to the Role named `pod-reader`.
- Make sure that both objects have been created properly.
- Switch to the context named `krishna`.
- Create a new Pod named `nginx` with the image `nginx`. What would you expect to happen?
- List the Pods in the namespace. What would you expect to happen?
- Create a new deploymened named `nginx-deploy`. What would you expect to happen?

2. **Share your learnings**: Document your key takeaways and insights in a blog post and social media update
3. **Make it public**: Share what you learn publicly on LinkedIn or Twitter.
   - **Tag us and use the hashtag**: Include the following in your post:
     - Tag [@PiyushSachdeva](https://www.linkedin.com/in/piyush-sachdeva) and [@CloudOps Community](https://www.linkedin.com/company/thecloudopscomm) (on both platforms)
     - Use the hashtag **#40daysofkubernetes**
     - **Embed the video**: Enhance your blog post by embedding the video lesson from the Kubernetes series. This will give you visual context and reinforce your written explanations.

## Blog Post Focus 📝

- **Clarity is essential**: Write your blog post clearly and concisely, making it easy for anyone to grasp the concepts, regardless of their prior Kubernetes experience.

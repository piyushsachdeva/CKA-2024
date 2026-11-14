## Task 23/40

In this exercise, you will learn RBAC and creating role and role binding objects.

### Task details

#### Checking Default User Permissions
Note: I am referring the username as `krishna` here in this task but feel free to use your own name or `adam` as per the previous task.
1. Change the context to `krishna` that you created in the Day 22 task.
2. Create a new Pod. What would you expect to happen?

#### Granting Access to the User

- Switch back to the original context with admin permissions. 
- Create a new Role named `pod-reader`. The Role should grant permissions to get, watch and list Pods.
- Create a new RoleBinding named `read-pods`. Map the user `krishna` to the Role named `pod-reader`.
- Make sure that both objects have been created properly.
- Switch to the context named `krishna`.
- Create a new Pod named `nginx` with the image `nginx`. What would you expect to happen?
- List the Pods in the namespace. What would you expect to happen?
- Create a new deployment named `nginx-deploy`. What would you expect to happen?

## Task 35/40

In this exercise, you will explore the Kubernetes ETCD backup and restore process.

> [!NOTE]
> If you do not already have a Kubernetes cluster, you can create a Kubernetes cluster using `kubeadm` by following Day 27 video.

### Task details
1. Login to your control plane node
2. Ensure all the nodes are in ready status
3. Find out version of etcd
4. Create an nginx deployment with 2 pods
5. Identify endpoint url, server certs and ca certs
6. Set the ETCDCTL_API=3 as the env variable
7. Run `etcdctl snapshot` command to view different option
8. Using the above help, take the backup of etcd cluster to `/opt/etcd-snapshot.db` directory
9. Delete the deployment
10. Restore the original state of the cluster from backup file at `/opt/etcd-snapshot.db` to the directory `/var/lib/etcd-from-backup`
11. Point ETCD to the new directory with the restored backup
12. Restart etcd pod
13. Check the deployment using `kubectl get deploy` , make sure that it is available as you have restored the backup prior to deleting the deployment

14. **Share your learnings**: Document your key takeaways and insights in a blog post and social media update
15. **Make it public**: Share what you learn publicly on LinkedIn or Twitter.
   - **Tag us and use the hashtag**: Include the following in your post:
     - Tag [@PiyushSachdeva](https://www.linkedin.com/in/piyush-sachdeva) and [@CloudOps Community](https://www.linkedin.com/company/thecloudopscomm) (on both platforms)
     - Use the hashtag **#40daysofkubernetes**
     - **Embed the video**: Enhance your blog post by embedding the video lesson from the Kubernetes series. This will give you visual context and reinforce your written explanations.

## Blog Post Focus 📝

- **Clarity is essential**: Write your blog post clearly and concisely, making it easy for anyone to grasp the concepts, regardless of their prior Kubernetes experience.


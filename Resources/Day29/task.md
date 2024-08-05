## Task 29/40

In this exercise, you will explore Kubernetes volumes.

> [!NOTE]
> Make sure you have a Kubernetes cluster created setup on virtual machines, you can follow [this video](https://youtu.be/WcdMC3Lj4tU) as a pre-requisites

### Task details
1. Create a PersistentVolume named `pv-demo`, access mode `ReadWriteMany`, 512Mi of storage capacity and the host path `/data/config`.
2. Create a PersistentVolumeClaim named `pvc-demo`. The claim should request 256Mi and use an empty string value for the storage class. Please make sure that the PersistentVolumeClaim is properly bound after its creation.
3. Mount the PersistentVolumeClaim from a new Pod named `app` with the path `/var/app/config`. The Pod uses the image `nginx:latest`.
4. Open an interactive shell to the Pod and create a file in the directory `/var/app/config`.
5. **Share your learnings**: Document your key takeaways and insights in a blog post and social media update
6. **Make it public**: Share what you learn publicly on LinkedIn or Twitter.
   - **Tag us and use the hashtag**: Include the following in your post:
     - Tag [@PiyushSachdeva](https://www.linkedin.com/in/piyush-sachdeva) and [@CloudOps Community](https://www.linkedin.com/company/thecloudopscomm) (on both platforms)
     - Use the hashtag **#40daysofkubernetes**
     - **Embed the video**: Enhance your blog post by embedding the video lesson from the Kubernetes series. This will give you visual context and reinforce your written explanations.

## Blog Post Focus 📝

- **Clarity is essential**: Write your blog post clearly and concisely, making it easy for anyone to grasp the concepts, regardless of their prior Kubernetes experience.

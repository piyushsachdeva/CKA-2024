# Conquer Your CKA Exam: Tips & Tricks for Success (Video Notes)

>Note: This is your quick guide to taking the Certified Kubernetes Administrator (CKA) exam based on the latest information from the video. Make sure to complete the entire series from Day 1 and all the hands-on tasks given after each video, and then come back to this video/study guide for last-minute preparation.

## Exam Preparation

- **Registration**: Before registering, look for discounts (25-40% off) on the CKA exam. They usually offer a discount, but if it's not there, wait for it.
- **Format**: This is an online proctored exam, there is no need to visit a test center.
- **Study Material**: The [exam guide](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2) is crucial! It details the exam format and tasks.
- **Checklist**: Make sure to complete the exam [checklist](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2/exam-preparation-checklist) beforehand and then schedule the exam.
- **Sample tests**: After registering for the exam, you will receive complimentary access to the `killer.sh` platform. This platform is similar to the exam guide and allows you to practice hands-on, with tasks that are more difficult than the actual exam.
- **Practice more** : If you want, you can practice more on Killercoda.com which is available free of cost
- **Rules**: Also read exam [rules and policies](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2/exam-rules-and-policies)
- **Exam UI**: Get yourself familiarize with the [exam UI](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2/exam-user-interface/examui-performance-based-exams)
- **FAQs**: Also check the frequently asked questions over [here](https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad)

## Exam Environment

- You'll be provided with a virtual machine running Ubuntu.
- As of 24th July 2024, the exam sandbox is running on the latest Kubernetes version 1.30
- A web browser is available to access official Kubernetes documentation (kubernetes.io/docs, kubernetes.io/blog, and all its subdomains).
- Copy-pasting commands/YAML from the documentation to the exam terminal is allowed.
- **Important Note**: The Terminal (Terminal Emulator Application) is a Linux Terminal,  to copy & paste within the Linux Terminal you need to use LINUX keyboard shortcuts: 
`Copy = Ctrl+Shift+C`
`Paste = Ctrl+Shift+V`
(Or use the right-click context menu and select Copy or Paste)

In other applications on the Remote Desktop (which is on a Linux Desktop), you'll want to use:
`Copy = Ctrl+C`
`Paste = Ctrl+V` ⚠️

## My Exam Strategy (July 13th, 2024):

### Prioritize Efficiency:
- Tackle the easiest and quickest tasks first. Bookmark the rest for later.
- Then, move on to time-consuming but straightforward tasks like etcd backup/restore and cluster upgrades.
- Finally, attempt the complex and time-intensive tasks. ⏱️
- I completed 15 out of 17 tasks using this strategy!

## Pro Tips:

- **Utilize the pre-configured kubectl alias** `k`. `k` is the way to go!
- **Leverage bash auto-completion** for faster command typing.
- **Brush up on vi editor shortcuts**:
  - `i`: Enter insert mode
  - `esc`: Exit insert mode
  - `:wq!`: Save and quit the file
  - `:q!`: Quit without saving
  - `shift +A`: Enter insert mode at line end
  - `:n`: Go to nth line
  - `shift +G`: Go to end of line
  - `d`: Delete a character
  - `dd`: Delete entire line
- **Set Context**: Always use the provided command to set the context before starting each task. It's critical! Remember to set the context! ❗️
- **Copy Commands**: Click on any command in the question to copy it easily. Click, copy, conquer!
- **Elevated Access**: Use `sudo -i` (when instructed) for tasks requiring elevated privileges. Super user mode activated! ‍♂️
- **Read Carefully**: Please make sure you complete all tasks within each question. Read twice, do once!
- **Exiting SSH/sudo**: After SSHing into a node or using `sudo—i`, use `exit` to return to the original user. Be cautious, as a terminal session might close otherwise. Exit safely!
- **Prioritize kubectl commands**: Use imperative kubectl commands whenever possible to save time.
- **Cheat Sheet**: The kubectl [cheat sheet](https://kubernetes.io/docs/reference/kubectl/quick-reference/) provides a quick reference for commands. You can also use `kubectl command --help` for specific command details. Don't be afraid to ask for help! 🆘

## Sample Tasks:
I was awarded the CKA certification on July 13, 2024, and I wanted to share the tasks that I could recall from the exam. While your exam may not have the exact same tasks, it will likely be similar, so it's important to practice these as well.

1) Check the number of schedulable nodes excluding tainted(noschedule) and write the number to a file.
2) Scale the deployment to 4 replicas
3) Create a network policy that allows access only from the nginx pod in the dev namespace to the redis pod in the test namespace.
4) Perform etcd backup on the cluster on the path `/etc/backup`, once that is done, restore the backup using the backup file given in `/var/lib/etcd_bkp`
5) Expose the deployment as nodePort service on port `8080`
6) Monitor the logs of a pod and look for `error-not-found` and redirect the message to a file
7) Check for the pods that have label `env=xyz` and redirect the pod name with the highest CPU utilization to a file
8) Create a multi-container pod with the image as `redis` and `memcached`
9) Edit a pod and add an `initcontainer` with `busybox` image and a command
10) Given an unhealthy cluster with a worker node in a `Notready` state, fix the cluster by SSH into the worker node. Make sure the changes are permanent.
11) Create a cluster role, cluster role binding, and a service account, cluster role that allows deployment, service, and ds to be created in a namespace test.
12) Make the node unschedulable and move the traffic to other nodes
13) Create a pod and schedule it on node `worker01`
14) Create an ingress resource task in the [Day 33 folder](https://github.com/piyushsachdeva/CKA-2024/blob/main/Resources/Day33/task.md)
15) Create a pv with 1Gi capacity and mode readWriteOnce and no storage class; create a pvc with 500Mi storage and mode as readWriteOnce; it should be bounded with the pv. Create a pod that utilizes this pvc and use a mount path `/data`


# Conquer Your CKA Exam: Tips & Tricks for Success (Video Notes)

>Note: This is your quick guide to taking the Certified Kubernetes Administrator (CKA) exam. Make sure to complete the entire series from Day 1 and all the hands-on tasks given after each video, and then come back to this video/study guide for last-minute preparation.

>Note: The video was recorded in July 2024. The exam has changed since then: a new curriculum came into effect in February 2025, the exam environment moves to every new Kubernetes release, and each task is now solved on its own host over SSH. The notes below were last checked against the Linux Foundation pages in November 2026. Always confirm the details on the [official CKA page](https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/) before you book.

## Exam at a glance

| | |
|---|---|
| Format | Online, proctored, performance-based. You solve tasks on a command line, there are no multiple choice questions |
| Duration | 2 hours |
| Number of tasks | 15 to 20 |
| Passing score | 66% |
| Kubernetes version | v1.37 (the environment moves to the latest minor version about 4 to 8 weeks after each Kubernetes release) |
| Price | $445, which includes one free retake |
| Eligibility | 12 months from the date of purchase to schedule and take the exam |
| Validity | 2 years |
| Result | By email within 24 hours |
| Practice exam | Two killer.sh simulator sessions are included, each with 36 hours of access |

## Exam curriculum

| Domain | Weight | Where it is covered in this course |
|---|---|---|
| Troubleshooting | 30% | Day 36 to 39 |
| Cluster Architecture, Installation & Configuration | 25% | Day 5, 21 to 25, 27, 34, 35, 49, 50, 53, 55, Helm, Kustomize |
| Services & Networking | 20% | Day 9, 26, 30 to 33, 47, 48 |
| Workloads & Scheduling | 15% | Day 7, 8, 11 to 19, 46, 51 |
| Storage | 10% | Day 29, 45, 52 |

The full list of topics under each domain is in the [curriculum PDF](https://github.com/cncf/curriculum) published by the CNCF.

## Exam Preparation

- **Registration**: Before registering, look for discounts on the CKA exam. The Linux Foundation runs sales several times a year, so if there is no discount today, it is usually worth waiting for one.
- **Format**: This is an online proctored exam, there is no need to visit a test center.
- **Study Material**: The [candidate handbook](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2) is crucial! It details the exam format and rules.
- **Checklist**: Make sure to complete the exam [checklist](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2/exam-preparation-checklist) beforehand and then schedule the exam.
- **Sample tests**: After registering for the exam, you get two sessions on the `killer.sh` simulator. Each session gives you 36 hours of access to the same kind of environment as the real exam, with tasks that are more difficult than the actual exam. Keep at least one session for the last week before your exam.
- **Practice more**: If you want, you can practice more on killercoda.com, which has free CKA scenarios.
- **Rules**: Also read the exam [rules and policies](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2/exam-rules-and-policies)
- **Exam UI**: Get yourself familiar with the [exam UI](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2/exam-user-interface/examui-performance-based-exams)
- **Important instructions**: Read the [important instructions for CKA and CKAD](https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad) and the [FAQ](https://docs.linuxfoundation.org/tc-docs/certification/faq-cka-ckad-cks)
- **Your machine**: You cannot take the exam from a virtual machine, and only one monitor is allowed. Run the system compatibility check from the checklist a few days before the exam.

## Exam Environment

- You work inside a remote Linux desktop that opens in the PSI Secure Browser. It has a terminal and a Firefox browser.
- You start on a base system with the hostname `base`. Every task tells you which host to work on and gives you the command to connect, for example `ssh <nodename>`. You must solve the task on that host.
- When you finish a task, type `exit` to return to `base` before you start the next one. Nested SSH is not supported.
- Do not reboot the `base` system.
- The hosts have `kubectl` with the alias `k` and bash autocompletion, plus `yq`, `curl`, `wget` and `man`.
- The browser inside the remote desktop can open only these sites:
  - https://kubernetes.io/docs and https://kubernetes.io/blog
  - https://helm.sh/docs
  - https://gateway-api.sigs.k8s.io
  - Any documentation that is linked inside a task
- The official list is [here](https://docs.linuxfoundation.org/tc-docs/certification/certification-resources-allowed). You can use the search box of the Kubernetes docs, but you cannot open search results that lead to other sites.
- Copy-pasting commands/YAML from the documentation to the exam terminal is allowed.
- **Important Note**: The Terminal (Terminal Emulator Application) is a Linux Terminal,  to copy & paste within the Linux Terminal you need to use LINUX keyboard shortcuts: 
`Copy = Ctrl+Shift+C`
`Paste = Ctrl+Shift+V`
(Or use the right-click context menu and select Copy or Paste)

In other applications on the Remote Desktop (which is on a Linux Desktop), you'll want to use:
`Copy = Ctrl+C`
`Paste = Ctrl+V` ⚠️

- `Ctrl+W` closes the browser tab. To delete a word in the terminal, use `Ctrl+Alt+W`.

## My Exam Strategy (July 13th, 2024):

### Prioritize Efficiency:
- Tackle the easiest and quickest tasks first. Flag the rest for later.
- Then, move on to time-consuming but straightforward tasks like etcd backup/restore and cluster upgrades.
- Finally, attempt the complex and time-intensive tasks. ⏱️
- I completed 15 out of 17 tasks using this strategy!
- Troubleshooting is now 30% of the exam, so do not leave all of those tasks for the end.

## Pro Tips:

- **Utilize the pre-configured kubectl alias** `k`. `k` is the way to go!
- **Leverage bash auto-completion** for faster command typing.
- **Brush up on vi editor shortcuts**:
  - `i`: Enter insert mode
  - `esc`: Exit insert mode
  - `:wq!`: Save and quit the file
  - `:q!`: Quit without saving
  - `shift + A`: Enter insert mode at the end of the line
  - `:n`: Go to the nth line (for example `:25`)
  - `shift + G`: Go to the last line of the file
  - `gg`: Go to the first line of the file
  - `x`: Delete a character
  - `dd`: Delete the entire line
  - `u`: Undo
  - `/text`: Search for text, `n` for the next match
  - `:set nu`: Show line numbers
- **Connect to the right host**: Always run the SSH command given at the top of the task before you start working on it. A correct answer on the wrong host gets no marks. ❗️ (In the video, I say to set the context with `kubectl config use-context` before each task. That was how the exam worked until early 2025. Now each task has its own host.)
- **Copy Commands**: Click on any command or name in the question to copy it easily. This avoids typos in names.
- **Elevated Access**: Use `sudo -i` for tasks requiring elevated privileges, or `sudo` in front of a single command.
- **Read Carefully**: Please make sure you complete all the parts of each task, and check the namespace that the task asks for. Read twice, do once!
- **Exiting SSH/sudo**: After SSHing into a node or using `sudo -i`, use `exit` to return to the original user. Be careful not to type `exit` one time too many, because that closes the terminal.
- **Prioritize kubectl commands**: Use imperative kubectl commands whenever possible to save time. When you need YAML, generate it with `--dry-run=client -o yaml` and edit it.
- **Verify your work**: After every task, check the result (`kubectl get`, `kubectl describe`, a quick `curl`).
- **Cheat Sheet**: The kubectl [cheat sheet](https://kubernetes.io/docs/reference/kubectl/quick-reference/) provides a quick reference for commands. You can also use `kubectl <command> --help` and `kubectl explain <resource>.<field>` for the details.

## Topics added in the 2025 curriculum

These topics were not part of the exam when the video was recorded. Make sure you practise them as well:

- Gateway API: GatewayClass, Gateway, HTTPRoute, and migrating an Ingress to the Gateway API ([day47](../day47-GatewayAPI), [Day48](../Day48-Migrate-Ingress-to-Gateway))
- Helm and Kustomize to install cluster components ([Helm](../Helm), [Kustomize](../Kustomize))
- CRDs and operators ([Day49](../Day49-CustomResources), [Day-50](../Day-50-Operators))
- Extension interfaces: CNI, CSI and CRI, including installing a container runtime such as cri-dockerd ([Day32](../Day32), [Day53](../Day53-DockerD-Setup))
- Workload autoscaling with HPA ([Day17](../Day17))
- Pod admission and scheduling: priority classes, resource quotas, limit ranges, pod security ([Day46](../Day46-PriorityClass), [Day51](../Day51-AdmissionControllers), [Day54](../Day54-PodSecurity))
- StorageClasses and dynamic provisioning ([Day52](../Day52-StorageClass-DynamicProvisioning))
- Highly available control plane ([Day55](../Day55-HA-Controlplane.md))

## Sample Tasks:
I was awarded the CKA certification on July 13, 2024, and I wanted to share the tasks that I could recall from the exam. While your exam may not have the exact same tasks, it will likely be similar, so it's important to practice these as well.

1) Check the number of schedulable nodes excluding tainted(noschedule) and write the number to a file.
2) Scale the deployment to 4 replicas
3) Create a network policy that allows access only from the nginx pod in the dev namespace to the redis pod in the test namespace.
4) Perform etcd backup on the cluster on the path `/etc/backup`, once that is done, restore the backup using the backup file given in `/var/lib/etcd_bkp` (on current versions, the restore is done with `etcdutl`, see [Day35](../Day35))
5) Expose the deployment as nodePort service on port `8080`
6) Monitor the logs of a pod and look for `error-not-found` and redirect the message to a file
7) Check for the pods that have label `env=xyz` and redirect the pod name with the highest CPU utilization to a file
8) Create a multi-container pod with the image as `redis` and `memcached`
9) Edit a pod and add an `initcontainer` with `busybox` image and a command
10) Given an unhealthy cluster with a worker node in a `NotReady` state, fix the cluster by SSH into the worker node. Make sure the changes are permanent.
11) Create a service account and a cluster role that allows deployments, services and daemonsets to be created, and bind them so that the service account has this access in the namespace `test`.
12) Make the node unschedulable and move the traffic to other nodes
13) Create a pod and schedule it on node `worker01`
14) Create an ingress resource task in the [Day 33 folder](https://github.com/piyushsachdeva/CKA-2024/blob/main/Resources/Day33/task.md)
15) Create a pv with 1Gi capacity and mode readWriteOnce and no storage class; create a pvc with 500Mi storage and mode as readWriteOnce; it should be bounded with the pv. Create a pod that utilizes this pvc and use a mount path `/data`
16) Given a statefulset with 2 replicas, scale it up to 5 replicas.
17) Drain the control plane node, upgrade it from one patch version to the next, for example `v1.37.0` to `v1.37.1` (upgrade kubeadm, kubelet, kubectl, kube-apiserver, kube-controller-manager, kube-scheduler; no need to upgrade etcd, coredns, cni etc), and uncordon the control plane node after the upgrade.
18) Given a deployment update it with port and env, further expose it as `nodePort` at port 30007.
19) Given a ClusterRole, create a service account and give it the permissions of that ClusterRole only in the given namespace. (hint: use a RoleBinding that refers to the ClusterRole)
20) Create a PVC with 10Mi, mount this PVC to the pod at `/var/new-vol`. Now, edit the pvc and increase the size from 10Mi to 50Mi.
21) Given a pod, add another container logging the message each minute (command is given) which can access the same volume used by first container at `/var/log`. So, the first container running the command `tail -f /var/log/tmp-container.log` can access the file. Further, write the command to see those logs into a file.

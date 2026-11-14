# Day 3/40 - Multi Stage Docker Build - Docker Tutorial For Beginners - CKA Full Course 2024 ☸️


## Check out the video below for Day3 👇

[![Day 3/40 - Multi Stage Docker Build - Docker Tutorial For Beginners](https://img.youtube.com/vi/ajetvJmBvFo/sddefault.jpg)](https://youtu.be/ajetvJmBvFo)

# Pre-requisites ( If you have followed Day2 video and/or already have Docker Setup, then skip this step)

## If you would like to use a Docker or Kubernetes sandbox instead of a local setup, you can use the below:
- Docker playground: https://labs.play-with-docker.com/
- Kubernetes playground: https://killercoda.com/playgrounds/scenario/kubernetes

## Download Docker desktop client
```
https://www.docker.com/products/docker-desktop/
```

# Getting started with the demo

- Clone the below sample repository, or you can use any web application that you have

```
git clone https://github.com/piyushsachdeva/todoapp-docker.git
```

- cd into the directory
```
cd todoapp-docker/
```
- Create an empty file with the name Dockerfile
```
touch Dockerfile
```

- Using the text editor of your choice, paste the below content:
Note: Details about the below Dockerfile have already been shared in the video
```dockerfile
# Stage 1: build the app
FROM node:22-alpine AS installer
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: copy only the build output into a small web server image
FROM nginx:stable-alpine AS deployer
COPY --from=installer /app/build /usr/share/nginx/html
```

> Note: The video uses `node:18-alpine` and `nginx:latest`. Node 18 is end of life, so the Dockerfile above uses a supported Node LTS image. It also pins nginx to the `stable-alpine` tag, because `latest` can change under you and one of the best practices covered in this video is to avoid it.

- Build the docker image using the application code and Dockerfile

```
docker build -t todoapp-docker .
```
- Verify the image has been created and stored locally using the below command:
```
docker images
```

- Create a public repository on hub.docker.com and push the image to remote repo
```
docker login
docker tag todoapp-docker:latest username/new-reponame:tagname
docker images
docker push username/new-reponame:tagname
```

- To pull the image to another environment, you can use the below command
```
docker pull username/new-reponame:tagname
```

- To start the docker container, use the below command

```
docker run -dp 3000:80 username/new-reponame:tagname
```

- Verify your app. If you have followed the above steps correctly, your app should be listening on localhost:3000
- To enter(exec) into the container, use the below command

```
docker exec -it containername sh
or
docker exec -it containerid sh
```
- To view docker logs

```
docker logs containername
or
docker logs containerid
```

- To view the low-level details of a container or an image (config, mounts, network and so on)
```
docker inspect containername
docker inspect imagename
```

- Clean up the old docker images from your machine using the below command:

```
docker image rm image-id
```

# Day 2/40 - How To Dockerize a Project - CKA Full Course 2024 ☸️


## Check out the video below for Day2 👇

[![Day 2/40 - How To Dockerize a Project - CKA Full Course 2024](https://img.youtube.com/vi/nfRsPiRGx74/sddefault.jpg)](https://youtu.be/nfRsPiRGx74)

## If you would like to use a Docker or Kubernetes sandbox instead of a local setup, you can use the below:
- Docker playground: https://labs.play-with-docker.com/
- Kubernetes playground: https://killercoda.com/playgrounds/scenario/kubernetes

## Download Docker desktop client
```
https://www.docker.com/products/docker-desktop/
```

## Get started
- Clone a sample git repository using the below command or use your project for the demo:

```
git clone https://github.com/docker/getting-started-app.git
```

- cd into the directory
```
cd getting-started-app/
```
- Create an empty file with the name Dockerfile
```
touch Dockerfile
```
- Using the text editor of your choice, paste the below content (each instruction is explained in the video)
```dockerfile
FROM node:22-alpine
WORKDIR /app
COPY . .
RUN npm install --omit=dev
CMD ["node", "src/index.js"]
EXPOSE 3000
```

> Note: The video uses `node:18-alpine` and `yarn install --production`. Node 18 reached end of life in April 2025 and the sample repo has since moved from yarn to npm, so the Dockerfile above uses a supported Node LTS image and `npm`. The rest of the steps are the same as in the video.

- Build the docker image using the application code and Dockerfile

```
docker build -t day02-todo .
```
- Verify the image has been created and stored locally using the below command:
```
docker images
```

- Create a public repository on hub.docker.com and push the image to remote repo
```
docker login
docker tag day02-todo:latest username/new-reponame:tagname
docker images
docker push username/new-reponame:tagname
```

- To pull the image to another environment , you can use below command
```
docker pull username/new-reponame:tagname
```

- To start the docker container, use below command

```
docker run -dp 3000:3000 username/new-reponame:tagname
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



  

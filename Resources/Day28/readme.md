# Day 28/40 - Docker Volume Explained - Docker Bind Mount - Docker Persistent Storage

## Check out the video below for Day28 👇

[![Day 28/40 - Docker Volume Explained - Docker Bind Mount - Docker Persistent Storage ](https://img.youtube.com/vi/ZAPX21TMkkQ/sddefault.jpg)](https://youtu.be/ZAPX21TMkkQ)


### Docker layered architecture

![image](https://github.com/user-attachments/assets/a1f16123-f868-4ee6-a872-7af521427ebf)

- A Docker image is made of read-only layers, one for each instruction in the Dockerfile.
- When you start a container, Docker adds a thin writable layer on top of the image layers. Anything the container writes goes into this layer, and it is deleted when the container is removed.
- To keep data after the container is gone, you store it outside the writable layer, in a volume or a bind mount.

### Volume vs bind mount

- **Volume**: storage that is created and managed by Docker (under `/var/lib/docker/volumes/` on Linux). This is the preferred way to persist data.
- **Bind mount**: any directory or file from the host that you mount into the container. Useful in development, when you want the container to see your source code changes straight away.

### Commands used in the video

```bash
# volumes
docker volume create data_volume
docker volume ls
docker volume inspect data_volume
docker run -d --name app1 -v data_volume:/app nginx
docker run -d --name app2 --mount type=volume,source=data_volume,target=/app nginx

# bind mount
docker run -d --name app3 -v /home/ubuntu/data:/app nginx
docker run -d --name app4 --mount type=bind,source=/home/ubuntu/data,target=/app nginx

# clean up
docker rm -f app1 app2 app3 app4
docker volume rm data_volume
```

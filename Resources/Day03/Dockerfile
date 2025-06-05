FROM node:23-alpine AS installer
WORKDIR /app
ARG CACHEBUST=1
COPY ./4-in-a-row .
RUN yarn && yarn build

FROM nginx:latest AS deployer
COPY --from=installer  /app/dist /usr/share/nginx/html 
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]





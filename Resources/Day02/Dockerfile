FROM node:18-alpine
WORKDIR /app
COPY ./4-in-a-row .
RUN yarn && yarn build
CMD [ "yarn", "start" ]
EXPOSE 5173


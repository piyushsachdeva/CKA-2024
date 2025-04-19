FROM node:18-alpine
WORKDIR /app
COPY ./4-in-a-row .
RUN yarn install --production
CMD [ "node", "src/index.js" ]
EXPOSE 3000


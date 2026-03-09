FROM dhi.io/node:24-alpine3.23-dev AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --only=prod

FROM dhi.io/node:24-alpine3.23
WORKDIR /usr/src/app
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY index.js index.js
EXPOSE 3000
CMD ["node", "index.js"]
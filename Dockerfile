FROM dhi.io/node:26-alpine3.24-dev AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --only=prod

FROM dhi.io/node:26-alpine3.24
WORKDIR /usr/src/app
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY index.js index.js
EXPOSE 3000
CMD ["node", "index.js"]

FROM alpine:3.17.1

# Install nodejs
RUN apk add --no-cache nodejs npm

COPY index.js index.js
COPY node_modules/ node_modules/

# Expose port 3000
EXPOSE 3000

# Run the app
CMD ["node", "index.js"]
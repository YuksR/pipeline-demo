# Base Image node:18.17.1-alpine
FROM node:18.17.1-alpine

# Install jq
RUN apk add --no-cache jq

# Set working directory to /app
WORKDIR /app

# Set PATH /app/node_modules/.bin
ENV PATH /app/node_modules/.bin:$PATH

# Copy package.json and package-lock.json in the image
COPY package.json package-lock.json ./

# Run npm install command
RUN npm install

# Copy the app
COPY . ./

# Expose port 3000
EXPOSE 3000

# Start the app
CMD ["npm", "start"]


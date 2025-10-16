# Deploying a Next.js App on AWS EC2 with Docker, NGINX, and GitHub Actions

This guide walks you through deploying a Next.js app on an AWS EC2 instance using Docker and NGINX, with CI/CD automation via GitHub Actions.

---

## Table of Contents

- [Deploying a Next.js App on AWS EC2 with Docker, NGINX, and GitHub Actions](#deploying-a-nextjs-app-on-aws-ec2-with-docker-nginx-and-github-actions)
  - [Table of Contents](#table-of-contents)
  - [Project Setup](#project-setup)
  - [Dockerizing the App](#dockerizing-the-app)
  - [NGINX Proxy Setup](#nginx-proxy-setup)
  - [Automating Deployment with GitHub Actions](#automating-deployment-with-github-actions)
  - [Additional Notes](#additional-notes)
- [Next.js Production Dockerfile Explained](#nextjs-production-dockerfile-explained)
  - [🧩 Stage 1: Install Dependencies (`deps`)](#-stage-1-install-dependencies-deps)
  - [NEver GIve up](#never-give-up)

---

## Project Setup

1. **Create your project folder and Next.js app:**

    ```
    mkdir next-tutorial-app
    cd next-tutorial-app
    npx create-next-app@latest website
    cd website
    npm run dev
    ```

---

## Dockerizing the App

1. **Add a `Dockerfile` inside your `website/` folder:**

    ```
    FROM node:23.10.0-alpine
    WORKDIR /app
    COPY ./package*.json ./
    RUN yarn
    COPY . .
    EXPOSE 3000
    ```

2. **Create a `.dockerignore` in your `website/` folder:**

    ```
    node_modules
    .next
    .DS_Store
    dist
    ```

3. **Create a `docker-compose.yml` in your root folder:**

    ```
    services:
      website:
        build:
          context: ./website
          dockerfile: Dockerfile
        command: yarn dev
        ports:
          - "3000:3000"
    ```

4. **Start your containers:**

    ```
    docker-compose up
    ```

---

## NGINX Proxy Setup

1. **Create an `nginx/` directory in your root folder.**
2. **Inside `nginx/` create `nginx.conf`:**

    ```
    server {
      listen 80;
      server_name localhost;
      location / {
        proxy_pass http://website:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
      }
    }
    ```

3. **Add a Dockerfile to `nginx/`:**

    ```
    FROM nginx:latest
    RUN rm /etc/nginx/conf.d/*
    COPY nginx.conf /etc/nginx/conf.d/
    EXPOSE 80
    ```

4. **Update `docker-compose.yml` to add NGINX:**

    ```
    services:
      website:
        build:
          context: ./website
          dockerfile: Dockerfile
        ports:
          - "3000:3000"
      nginx:
        build:
          context: ./nginx
          dockerfile: Dockerfile
        ports:
          - "80:80"
        depends_on:
          - website
    ```

---

## Automating Deployment with GitHub Actions

1. **Create `.github/workflows/deploy.yml`:**

    ```
    name: Deploy to AWS EC2

    on:
      push:
        branches: [main]

    jobs:
      deploy:
        runs-on: ubuntu-latest
        steps:
          # - Checkout, build Docker image, SSH to EC2 and deploy
    ```

2. **Configure your steps for Docker builds and SSH-based deployment.**
3. **Push to your main branch to trigger deployment.**

---

## Additional Notes

- Set `output: 'standalone'` in your `next.config.js` for production-ready builds.
- Use `.env` files and secure secrets.
- For SSL, configure Let's Encrypt as needed.

---

**Happy Coding!**
# Next.js Production Dockerfile Explained

This document provides a detailed, line-by-line explanation of a multi-stage Dockerfile designed for a production-ready Next.js application. The goal is to create a small, secure, and efficient Docker image.

The process is broken down into three main stages:
1.  **`deps`**: Installs the necessary Node.js dependencies.
2.  **`builder`**: Builds the Next.js application.
3.  **`runner`**: Creates the final, lightweight image to run the application.

---

## 🧩 Stage 1: Install Dependencies (`deps`)

This first stage is dedicated solely to installing the project's dependencies. By isolating this step, Docker can cache the result, making future builds much faster if the dependencies haven't changed.

```dockerfile
ARG NODE=node:20-alpine
FROM ${NODE} AS deps
```
## NEver GIve up
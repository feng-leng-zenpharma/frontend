# Stage 1: Build
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY public ./public
COPY src ./src
COPY .env.production ./
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:1.25-alpine
COPY --from=builder /app/build /usr/share/nginx/html
# Rendered to /etc/nginx/conf.d/default.conf by the image's envsubst step
COPY nginx.conf /etc/nginx/templates/default.conf.template
ENV NGINX_ENTRYPOINT_LOCAL_RESOLVERS=1 \
    NGINX_ENVSUBST_FILTER="^(POD_NAMESPACE|NGINX_LOCAL_RESOLVERS)$" \
    POD_NAMESPACE=dev
RUN addgroup -S pharma && adduser -S pharma -G pharma
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
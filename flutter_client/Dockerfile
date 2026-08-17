# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS builder

ARG PUBLIC_API_URL=""
WORKDIR /app

# Get dependencies
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Build web distribution
COPY . .
RUN flutter build web --release --dart-define=API_URL=${PUBLIC_API_URL}

# Stage 2: Nginx Web Server
FROM nginx:alpine

# Copy built static assets
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# Build stage
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

# Runtime stage
# We use debian instead of scratch because IMAP/SMTP connections require SSL/CA certificates
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/bin/server /app/bin/

# Render sets the PORT environment variable automatically
ENV PORT=8080
EXPOSE 8080

CMD ["/app/bin/server"]

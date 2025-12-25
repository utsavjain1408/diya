# Stage 1: Builder
# Uses the official Go image with Alpine Linux as a build environment.
FROM golang:1.25-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum to download dependencies first, leveraging Docker's cache
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the Go application, creating a statically linked binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -o /go-app .

# Stage 2: Final Image
# Uses a minimal Alpine image for a small footprint.
FROM alpine:latest

# Add a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

WORKDIR /app

# Copy the compiled binary from the builder stage
COPY --from=builder /go-app /app/go-app

# Command to run the application
CMD ["/app/go-app"]

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Stage 1: Build the Go application
FROM golang:1.20.4-alpine@sha256:0a03b591c358a0bb02e39b93c30e955358dadd18dc507087a3b7f3912c17fe13 AS builder

# Install necessary packages
RUN apk add --no-cache ca-certificates git build-base

WORKDIR /src

# Copy go mod and sum files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the Go application with Skaffold compiler flags
ARG SKAFFOLD_GO_GCFLAGS=""
RUN go build -gcflags="${SKAFFOLD_GO_GCFLAGS}" -o /productcatalogservice .

# Stage 2: Setup runtime environment without grpc-health-probe-bin
FROM alpine:3.18.0@sha256:02bb6f428431fbc2809c5d1b41eab5a68350194fb508869a33cb1af4444c9b11 AS without-grpc-health-probe-bin

# Install necessary packages
RUN apk add --no-cache ca-certificates

WORKDIR /src

# Copy the built Go application from the builder stage
COPY --from=builder /productcatalogservice ./server
COPY products.json .

# Set environment variable for Go runtime stack traces
ENV GOTRACEBACK=single

# Expose the application port
EXPOSE 3550

# Set the entry point for the container
ENTRYPOINT ["/src/server"]

# Stage 3: Add grpc-health-probe
FROM without-grpc-health-probe-bin

# Define the version of grpc-health-probe to use
ENV GRPC_HEALTH_PROBE_VERSION=v0.4.18

# Download and install grpc-health-probe
RUN wget -qO /bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

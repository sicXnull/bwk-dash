#!/bin/bash

echo "Building website..."
cd client
yarn run build
cd ..

echo "Removing old builds..."
rm -fR bin
mkdir bin
rm -fR build
mkdir build

echo "Building binaries..."
GOOS=linux GOARCH=arm CGO_ENABLED=1 CC=arm-linux-gnueabi-gcc go build -o bin/linux-arm/posq-cron cmd/posq-cron/*.go
GOOS=linux GOARCH=arm CGO_ENABLED=1 CC=arm-linux-gnueabi-gcc go build -o bin/linux-arm/posq-dash cmd/posq-dash/*.go
echo "- Linux ARM done!"
GOOS=linux GOARCH=amd64 go build -o bin/linux-amd64/posq-cron cmd/posq-cron/*.go
GOOS=linux GOARCH=amd64 go build -o bin/linux-amd64/posq-dash cmd/posq-dash/*.go
echo "- Linux AMD64 done!"

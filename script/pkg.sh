#!/bin/bash

rm -fR build
mkdir build 

cd bin/linux-arm
tar -zcf ../../build/posq-dash-2.1.3-linux-arm.tar.gz posq-cron posq-dash

cd ../linux-amd64
tar -zcf ../../build/posq-dash-2.1.3-linux-amd64.tar.gz posq-cron posq-dash

cd ../../client/build
tar -zcf ../../build/posq-dash-2.1.3-html.tar.gz *

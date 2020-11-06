#!/usr/bin/env bash
# Request an ExApp URL until the GIT_HASH is sent in the x-app-build response header.
# This means AWS has deployed/updated the application and its fully available.

URL=$1
BUILD=$2

# Try to get the data for 10 minutes with 10 seconds sleeps between each try.
RETRIES=60
RETRY_SLEEP=10

while (( ${RETRIES} > 0 )); do
    echo "Requesting URL ${URL} and checking for x-app-build: ${BUILD} header..."

    FOUND=$(wget -O - -o /dev/null --save-headers ${URL} | grep -c "x-app-build: ${BUILD}")
    if (( ${FOUND} == 1 )); then
      echo "Found desired build in the headers, deployment successful."
      exit 0
    else
      echo "x-app-build header not found, ${RETRIES} retries left, next retry in ${RETRY_SLEEP} seconds..."
      RETRIES=$(($RETRIES-1))
      sleep ${RETRY_SLEEP}
    fi
done

echo "No retries left and the URL: ${URL} did not respond with the desired header, deployment failed."
exit 1

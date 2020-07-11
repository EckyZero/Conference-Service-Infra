#!/bin/bash

APP_NAME=$1
CONFIG_FILE=$2

# Declare services needed for this service
# Cloud SQL - enable web service to use the SQL backend
# Deployment Manager - enable this deployment script to work
# Secret Manager - enable app to access configurations
# App Engine - enable application deployment to App Engine
# Endpoints Portal - for Cloud Endpoints
# DNS - for project ownership of the domain
# Compute Engine - enabled as part of the DNS configuration above
declare -a services=("sqladmin.googleapis.com" 
                     "deploymentmanager.googleapis.com" 
                     "secretmanager.googleapis.com" 
                     "appengine.googleapis.com",
                     "endpointsportal.googleapis.com",
                     "dns.googleapis.com",
                     "compute.googleapis.com",
                     "iap.googleapis.com"
                )

# Enable specified services
for i in "${services[@]}"
do
   echo "Enabling $i"
   gcloud services enable $i   
done

# Check if deployment already exists
set +e
O=`gcloud deployment-manager deployments describe ${APP_NAME} 2>&1`  
exists=$?
set -e
    

if [ ${exists} -eq 0 ]; then
    # If existing, update current deployment
    echo ${APP_NAME} exists
    gcloud deployment-manager deployments update ${APP_NAME} --config=${CONFIG_FILE}
else
    # If first run, create new deployment
    gcloud deployment-manager deployments create ${APP_NAME} --config=${CONFIG_FILE}
fi

# Update cloud endpoints API portal
gcloud endpoints services deploy 'swagger.yaml'
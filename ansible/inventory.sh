#!/bin/bash

TERRAFORM_STAGE='https://storage.yandexcloud.net/terraform-tfstate-stage/terraform.tfstate?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=YCAJEmN59-fDZ1eybmgsRJh2w%2F20230117%2Fru-central1%2Fs3%2Faws4_request&X-Amz-Date=20230117T034513Z&X-Amz-Expires=86400&X-Amz-Signature=9A2DCF294707313875E58A539316944EB8684096A56E73833C32E40A0E4D55E6&X-Amz-SignedHeaders=host'

APP_IP=$(curl -s $TERRAFORM_STAGE | jq -r .outputs.external_ip_address_app.value)
DB_IP=$(curl -s $TERRAFORM_STAGE | jq -r .outputs.external_ip_address_db.value)

echo '{"all":{"children":["appserver","dbserver"]},"app":{"children":["appserver"]},"db":{"children":["dbserver"]},"appserver":["'${APP_IP}'"],"dbserver":["'$DB_IP'"]}'

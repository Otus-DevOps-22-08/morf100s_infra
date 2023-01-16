#!/bin/bash

TERRAFORM_STAGE='https://storage.yandexcloud.net/terraform-tfstate-stage/terraform.tfstate?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=YCAJEmN59-fDZ1eybmgsRJh2w%2F20230116%2Fru-central1%2Fs3%2Faws4_request&X-Amz-Date=20230116T151645Z&X-Amz-Expires=86400&X-Amz-Signature=1FB3F02AEB06803B2847861E23F57D8603732D7EAC8B410DAE646BE5DCCD228C&X-Amz-SignedHeaders=host'

APP_IP=$(curl -s $TERRAFORM_STAGE | jq -r .outputs.external_ip_address_app.value)
DB_IP=$(curl -s $TERRAFORM_STAGE | jq -r .outputs.external_ip_address_db.value)

echo '{"all":{"children":["appserver","dbserver"]},"app":{"children":["appserver"]},"db":{"children":["appserver"]},"appserver":["'${APP_IP}'"],"dbserver":["'$DB_IP'"]}'

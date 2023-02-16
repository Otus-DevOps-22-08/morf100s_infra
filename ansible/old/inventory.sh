#!/bin/bash

TERRAFORM_STAGE='https://storage.yandexcloud.net/terraform-tfstate-stage/terraform.tfstate?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=YCAJEmN59-fDZ1eybmgsRJh2w%2F20230209%2Fru-central1%2Fs3%2Faws4_request&X-Amz-Date=20230209T073523Z&X-Amz-Expires=2592000&X-Amz-Signature=49661AE789A813651BFBAE154E0C22BD09449CA6D879F6F3467B5B92F9BC2FD2&X-Amz-SignedHeaders=host'

APP_IP=$(curl -s $TERRAFORM_STAGE | jq -r .outputs.external_ip_address_app.value)
DB_IP=$(curl -s $TERRAFORM_STAGE | jq -r .outputs.external_ip_address_db.value)

echo '{"_meta":{"hostvars":{"appserver":{"ansible_ssh_host":"'${APP_IP}'"},"dbserver":{"ansible_ssh_host":"'${DB_IP}'"}}},"all":{"children":["app","db"],"hosts":[]},"app":{"children":[],"hosts":["appserver"]},"db":{"children":[],"hosts":["dbserver"]}}'

#!/bin/bash
#
# Sign all available SSH host keys using Hashicorp Vault

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

SSH_HOST_KEY_PATTERN="${SSH_HOST_KEY_PATTERN:-/etc/ssh/*.pub}"
SSH_KEY_SIGNING_MOUNT_POINT="${SSH_KEY_SIGNING_MOUNT_POINT:-ssh}"  

err() {
  echo "[error]: $*" >&2
  exit 1
}

# Check required global variables
if [ -z "$VAULT_ADDR" ]; then err "Must provide VAULT_ADDR in environment"; exit 2; fi

# Login to Vault using a gicen app role
vault_login_app_role(){

    if [ -z "$SSH_KEY_SIGNING_APP_ROLE_ID" ]; then err "Must provide SSH_KEY_SIGNING_APP_ROLE_ID in environment"; exit 2; fi
    if [ -z "$SSH_KEY_SIGNING_APP_SECRET_ID" ]; then err "Must provide SSH_KEY_SIGNING_APP_SECRET_ID in environment"; exit 2; fi

    echo "[-] Login to vault at: ${VAULT_ADDR}"
	local payload="{\"role_id\":\"${SSH_KEY_SIGNING_APP_ROLE_ID}\",\"secret_id\":\"${SSH_KEY_SIGNING_APP_SECRET_ID}\"}"
	export VAULT_TOKEN=$(curl --silent --show-error -X POST -d ${payload} ${VAULT_ADDR}/v1/auth/approle/login | jq -r ".auth.client_token")

    if [[ -z "$VAULT_TOKEN" ]]; then
        err "Failed to get VAULT_TOKEN $VAULT_TOKEN"
    fi
}

vault_sign_host_key(){
    file=$1
    cert_file=${file/.pub/-cert.pub}

    if [ -z "$SSH_KEY_SIGNING_BACKEND_ROLE_NAME" ]; then err "Must provide SSH_KEY_SIGNING_BACKEND_ROLE_NAME in environment"; exit 2; fi

    echo "[-] Sign host key '$file' using app role '${SSH_KEY_SIGNING_BACKEND_ROLE_NAME}' on mount point '${SSH_KEY_SIGNING_MOUNT_POINT}'"

    tmp_dir=$(mktemp -d)
    echo "{\"cert_type\":\"host\",\"public_key\": \"$(cat $1)\"}" > $tmp_dir/payload.json
    curl -s --fail --show-error --header "X-Vault-Token: ${VAULT_TOKEN}" -X POST -d @$tmp_dir/payload.json \
        ${VAULT_ADDR}/v1/${SSH_KEY_SIGNING_MOUNT_POINT}/sign/${SSH_KEY_SIGNING_BACKEND_ROLE_NAME} | jq -r .data.signed_key | tr -d '\n' > $cert_file;
        
    chmod 0600 $cert_file

    echo "[-] Show  host key certifikate: "
    ssh-keygen -L -f $cert_file

    rm -r $tmp_dir
}

# Login using app role
vault_login_app_role

# Sign all keys matching the pattern
for host_key_file in $SSH_HOST_KEY_PATTERN; do
    vault_sign_host_key $host_key_file
done

#!/bin/sh

# Setup trusted user CA
if [[ -z "${SSH_TRUSTED_USER_CA_KEYS}" ]]; then
  echo "SSH_TRUSTED_USER_CA_KEYS not set"
  exit 1
else
  echo ${SSH_TRUSTED_USER_CA_KEYS} > /etc/ssh/trusted-user-ca-keys.pem
fi

if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	# generate fresh rsa key
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
	# generate fresh dsa key
	ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi

# Add a generic user ops for operations department
addgroup -S ops && adduser -S ops -G ops -s /bin/bash
echo "ops:ops" | chpasswd

mkdir -p /etc/ssh/auth_principals
# Add ops and a demo gitlab project as valid principals for ops
echo $'ops\ngitlab-project-id-22' > /etc/ssh/auth_principals/ops

exec "$@"
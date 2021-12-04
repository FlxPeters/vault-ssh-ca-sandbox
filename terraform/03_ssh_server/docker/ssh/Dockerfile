FROM alpine

RUN apk add sudo openssh bash curl jq

COPY sshd_config /etc/ssh/sshd_config
COPY docker-entrypoint.sh /usr/local/bin
COPY ssh-vault-sign-key.sh /usr/local/bin

ENTRYPOINT ["docker-entrypoint.sh"]

# Start as daemon with logs to stderr
CMD ["/usr/sbin/sshd", "-D", "-e"]

EXPOSE 22
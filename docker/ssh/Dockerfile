FROM alpine

RUN apk add sudo openssh bash

# Add a generic user ops for operations department
RUN addgroup -S ops && adduser -S ops -G ops -s /bin/bash
RUN echo "ops:ops" | chpasswd

COPY sshd_config /etc/ssh/sshd_config
COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]

# Start as daemon with logs to stderr
CMD ["/usr/sbin/sshd", "-D", "-e"]

EXPOSE 22
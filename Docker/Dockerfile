FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    default-mysql-client \
    cron \
    bash \
    gzip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /backup/{current,last,gz}

COPY backup.sh /usr/local/bin/backup.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /usr/local/bin/backup.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

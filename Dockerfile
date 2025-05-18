FROM cgr.dev/chainguard/wolfi-base
COPY config/ /config/
COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

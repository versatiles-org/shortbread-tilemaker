FROM postgis/postgis:17-3.5

RUN apt-get update && apt-get install -y --no-install-recommends \
    osm2pgsql \
    osmium-tool \
  && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

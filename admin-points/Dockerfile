FROM postgis/postgis:17-3.5

RUN apt-get update && apt-get install -y --no-install-recommends \
    aria2 \
    osm2pgsql \
    osmium-tool \
    postgis \
  && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

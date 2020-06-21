
ARG REGISTRY=""
FROM ${REGISTRY}hbase-base:latest

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 16020 16030

CMD ["/run.sh"]

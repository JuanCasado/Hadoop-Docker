
ARG REGISTRY=""
FROM ${REGISTRY}hbase-base:latest

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 16000 16010

CMD ["/run.sh"]

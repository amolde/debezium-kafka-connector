FROM quay.io/strimzi/kafka:0.32.0-kafka-3.2.0
USER root:root
RUN mkdir -p /opt/kafka/plugins/debezium
COPY ./debezium-connector-oracle/debezium-connector-oracle/ /opt/kafka/plugins/debezium/
COPY ./target/debezium-kafka-connector-2.0.0-SNAPSHOT-package/share/java/debezium-kafka-connector/ /opt/kafka/plugins/debezium/
COPY ./oracle-instantclient/instantclient_21_8/ojdbc8.jar /opt/kafka/libs/ojdbc8.jar
USER 1001

FROM quay.io/strimzi/kafka:0.38.0-kafka-3.6.0
USER root:root
RUN mkdir -p /opt/kafka/plugins/debezium
COPY ./debezium-connector-oracle/debezium-connector-oracle/ /opt/kafka/plugins/debezium/
COPY ./target/debezium-kafka-connector-2.4.0.FINAL-package/share/java/debezium-kafka-connector/ /opt/kafka/plugins/debezium/
COPY ./oracle-instantclient/instantclient_21_12/ojdbc11.jar /opt/kafka/libs/ojdbc11.jar
COPY ./oracle-instantclient/instantclient_21_12/ojdbc8.jar /opt/kafka/libs/ojdbc8.jar
USER 1001

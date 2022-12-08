FROM quay.io/strimzi/kafka:0.32.0-kafka-3.2.0
USER root:root
RUN curl https://download.oracle.com/otn_software/linux/instantclient/218000/oracle-instantclient-basic-21.8.0.0.0-1.el8.x86_64.rpm -o /tmp/oracle-instantclient-basic-21.8.0.0.0-1.el8.x86_64.rpm
RUN microdnf install /tmp/oracle-instantclient-basic-21.8.0.0.0-1.el8.x86_64.rpm && rm -rf /tmp/oracle-instantclient-basic-21.8.0.0.0-1.el8.x86_64.rpm
ENV LD_LIBRARY_PATH /usr/lib/oracle/21/client64/lib:$LD_LIBRARY_PATH
RUN mkdir -p /opt/kafka/plugins/debezium
COPY ./debezium-connector-oracle/debezium-connector-oracle/ /opt/kafka/plugins/debezium/
COPY ./target/debezium-kafka-connector-2.1.0-SNAPSHOT-package/share/java/ /opt/kafka/plugins/
COPY ./oracle-instantclient/instantclient_21_8/ojdbc8.jar /opt/kafka/libs/ojdbc8.jar
USER 1001

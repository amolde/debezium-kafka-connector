FROM quay.io/strimzi/kafka:0.22.1-kafka-2.7.0
USER root:root
RUN curl https://download.oracle.com/otn_software/linux/instantclient/211000/oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm -o /tmp/oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm
RUN yum -y localinstall /tmp/oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm
ENV LD_LIBRARY_PATH /usr/lib/oracle/21/client64/lib:$LD_LIBRARY_PATH
RUN mkdir -p /opt/kafka/plugins/debezium
COPY ./debezium-connector-oracle/ /opt/kafka/plugins/debezium/
COPY ./instantclient_21_1/ojdbc8.jar /opt/kafka/libs/ojdbc8.jar
COPY ./target/debezium-kafka-connector-0.0.1-package/share/java/ /opt/kafka/plugins/
USER 1001

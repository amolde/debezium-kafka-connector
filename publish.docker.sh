set -e

docker_tag=$1
if [[ ${docker_tag} == "" ]]
then
    echo "provide docker tag"
    exit 1
fi

jenv global
# 1.8.0.232
jenv version
# 1.8.0.232 (set by /Users/adeshmukh/.jenv/version)
mvn -version

mvn clean package

curl -L 'https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=io.debezium&a=debezium-connector-oracle&v=LATEST&c=plugin&e=tar.gz' --output debezium-connector-oracle.tar.gz
# https://repo1.maven.org/maven2/io/debezium/debezium-connector-oracle/1.6.0.Beta1/debezium-connector-oracle-1.6.0.Beta1.jar
tar xvf debezium-connector-oracle.tar.gz

curl 'https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-basic-linux.x64-21.1.0.0.0.zip' -o instantclient-basic-linux.x64-21.1.0.0.0.zip
unzip instantclient-basic-linux.x64-21.1.0.0.0.zip

ls -lrt instantclient_21_1/ojdbc8.jar 
ls -lrt ./target/debezium-kafka-connector-0.0.1-package/share/java/

# docker build -t amolde/strimzi-kafka-connect:${docker_tag} -t amolde/strimzi-kafka-connect:latest .
docker build -t amolde/debezium-kafka-connect:${docker_tag} .
docker login
docker push amolde/debezium-kafka-connect:${docker_tag}

rm -rf debezium-connector-oracle
rm -rf instantclient_21_1
rm debezium-connector-oracle.tar.gz
rm instantclient-basic-linux.x64-21.1.0.0.0.zip


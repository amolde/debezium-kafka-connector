# % mvn -version
# Apache Maven 3.8.6 (84538c9988a25aec085021c365c560670ad80f63)

# jenv versions
# brew install openjdk@17
# /usr/local/opt/openjdk@17/bin/java -version
# jenv add /usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home 
# jenv shell 17.0.5

# % java -version
# openjdk version "17.0.5" 2022-10-18
# OpenJDK Runtime Environment Homebrew (build 17.0.5+0)
# OpenJDK 64-Bit Server VM Homebrew (build 17.0.5+0, mixed mode, sharing)

# % git -v
# git version 2.37.1 (Apple Git-137.1)


# % docker -v
# Docker version 20.10.7, build f0df350

# =========================================================

instantclientdir=oracle-instantclient

mkdir "${instantclientdir}"
curl -L 'https://download.oracle.com/otn_software/linux/instantclient/218000/instantclient-basic-linux.x64-21.8.0.0.0dbru.zip' --output "${instantclientdir}/instantclient-basic-linux.x64-21.8.0.0.0dbru.zip"
cd "${instantclientdir}"
unzip "instantclient-basic-linux.x64-21.8.0.0.0dbru.zip"
cd ..

mvn install:install-file \
  -DgroupId=com.oracle.instantclient \
  -DartifactId=xstreams \
  -Dversion=21.6.0.0 \
  -Dpackaging=jar \
  -Dfile=${instantclientdir}/instantclient_21_8/xstreams.jar


# Go where https://github.com/amolde/debezium is cloned
cd ../debezium

git checkout 2.0

mvn clean install -pl debezium-connector-oracle -am -Passembly         

ls -lrt debezium-connector-oracle/target/debezium-connector-oracle-2.0.0-SNAPSHOT-plugin.tar.gz  

tar tvf  debezium-connector-oracle/target/debezium-connector-oracle-2.0.0-SNAPSHOT-plugin.tar.gz  

# =========================================================

# Change back to this project
cd -

docker_tag=2.0.0-SNAPSHOT

if [[ ${docker_tag} == "" ]]
then
    echo "provide docker tag"
    exit 1
fi

# curl -L 'https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=io.debezium&a=debezium-connector-oracle&v=LATEST&c=plugin&e=tar.gz' --output debezium-connector-oracle.tar.gz
# https://repo1.maven.org/maven2/io/debezium/debezium-connector-oracle/2.0.0.Alpha2/debezium-connector-oracle-2.0.0.Alpha2.jar

connectorplugindir=debezium-connector-oracle

mkdir "${connectorplugindir}"
cp ../debezium/debezium-connector-oracle/target/debezium-connector-oracle-2.0.0-SNAPSHOT-plugin.tar.gz ./${connectorplugindir}/debezium-connector-oracle.tar.gz

cd "${connectorplugindir}"
tar xvf debezium-connector-oracle.tar.gz
cd -

ls -lrt "${instantclientdir}/instantclient_21_8/ojdbc8.jar"

mvn clean install

ls -lrt ./target/debezium-kafka-connector-2.0.0-SNAPSHOT-package/share/java/

docker build -t amolde/debezium-kafka-connect:${docker_tag} .

# docker login
# docker push amolde/debezium-kafka-connect:${docker_tag}

# rm -rf "${connectorplugindir}"
# rm -rf "${instantclientdir}"


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
curl -L 'https://download.oracle.com/otn_software/linux/instantclient/2112000/instantclient-basic-linux.x64-21.12.0.0.0dbru.zip' --output "${instantclientdir}/instantclient-basic-linux.x64-21.12.0.0.0dbru.zip"
curl -L 'https://download.oracle.com/otn_software/linux/instantclient/2115000/instantclient-basic-linux.x64-21.15.0.0.0dbru.zip' --output "${instantclientdir}/instantclient-basic-linux.x64-21.15.0.0.0dbru.zip"
cd "${instantclientdir}"
unzip "instantclient-basic-linux.x64-21.15.0.0.0dbru.zip"
cd ..

mvn install:install-file \
   -Dfile=/Users/a.deshmukh/work/java/debezium-kafka-connector/oracle-instantclient/instantclient_21_15/xstreams.jar \
   -DgroupId=com.oracle.instantclient \
   -DartifactId=xstreams \
   -Dversion=21.15.0.0 \
   -Dpackaging=jar \
   -DgeneratePom=true


# Go where https://github.com/amolde/debezium is cloned
cd ../debezium

### Following to be run in /Users/a.deshmukh/work/java/debezium
# 
# pwd
# /Users/a.deshmukh/work/java/debezium
# 
# git remote -v
# origin	git@github.com:amolde/debezium.git (fetch)
# origin	git@github.com:amolde/debezium.git (push)
# upstream	https://github.com/debezium/debezium.git (fetch)
# upstream	https://github.com/debezium/debezium.git (push)

git checkout main
git fetch upstream
git pull upstream main --rebase
git pull origin main --rebase
git fetch --tags
git checkout tags/v3.0.0.Final

brew install java
sudo ln -sfn /usr/local/opt/openjdk@22/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk@22
jenv add /Library/Java/JavaVirtualMachines/openjdk.jdk@22/Contents/Home/


#mvn clean verify -Dquick
mvn clean install -pl debezium-connector-oracle -am -Passembly -Dquick -Dinstantclient.dir=/Users/a.deshmukh/work/java/debezium-kafka-connector/oracle-instantclient/instantclient_21_15

ls -lrt debezium-connector-oracle/target/debezium-connector-oracle-3.0.0.Final-plugin.tar.gz

tar tvf  debezium-connector-oracle/target/debezium-connector-oracle-3.0.0.Final-plugin.tar.gz

# =========================================================

# Change back to this project
# cd -

docker_tag=3.0.0.Final-KFKUPGRD
DEBEZIUM_CONNECTOR_VERSION=3.0.0.Final
EDIT_VERSION_IN_POM=3.0.0.Final

if [[ ${docker_tag} == "" ]]
then
    echo "provide docker tag"
    exit 1
fi

# curl -L 'https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=io.debezium&a=debezium-connector-oracle&v=LATEST&c=plugin&e=tar.gz' --output debezium-connector-oracle.tar.gz
# https://repo1.maven.org/maven2/io/debezium/debezium-connector-oracle/2.0.0.Alpha2/debezium-connector-oracle-2.0.0.Alpha2.jar

connectorplugindir=debezium-connector-oracle

mkdir "${connectorplugindir}"
cp ../debezium/debezium-connector-oracle/target/debezium-connector-oracle-${DEBEZIUM_CONNECTOR_VERSION}-plugin.tar.gz ./${connectorplugindir}/debezium-connector-oracle.tar.gz

cd "${connectorplugindir}"
tar xvf debezium-connector-oracle.tar.gz
cd debezium-connector-oracle
curl -sfSL https://repo1.maven.org/maven2/io/debezium/debezium-interceptor/${DEBEZIUM_CONNECTOR_VERSION}/debezium-interceptor-${DEBEZIUM_CONNECTOR_VERSION}.jar -o debezium-interceptor-${DEBEZIUM_CONNECTOR_VERSION}.jar
cd ../..

ls -lrt "${instantclientdir}/instantclient_21_15/ojdbc11.jar"

mvn clean install

ls -lrt ./target/debezium-kafka-connector-${EDIT_VERSION_IN_POM}-package/share/java/

docker build -t amolde/debezium-kafka-connect:${docker_tag} .

# docker login
# docker push amolde/debezium-kafka-connect:${docker_tag}

# rm -rf "${connectorplugindir}"
# rm -rf "${instantclientdir}"


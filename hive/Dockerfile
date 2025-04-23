FROM openjdk:8-jre-alpine

ENV HIVE_VERSION 3.1.2
ENV HIVE_HOME /opt/hive
ENV PATH $HIVE_HOME/bin:$PATH


RUN apk add --no-cache wget \
    && wget -q "https://apache.claz.org/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz" -O /tmp/hive.tar.gz \
    && mkdir -p $HIVE_HOME \
    && tar -xzf /tmp/hive.tar.gz --strip-components=1 -C $HIVE_HOME \
    && rm /tmp/hive.tar.gz

RUN wget -q "https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-hive-runtime/0.12.0/iceberg-hive-runtime-0.12.0.jar" -O /opt/hive/lib/iceberg-hive-runtime-0.12.0.jar

WORKDIR $HIVE_HOME

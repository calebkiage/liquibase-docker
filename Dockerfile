FROM alpine:3.11

MAINTAINER Caleb Kiage <caleb.kiage@gmail.com>

ENV CHANGELOG_FILE=""\
    CLASSPATH=""\
    DATABASE_DRIVER=""\
    DATABASE_HOST=""\
    DATABASE_PASSWORD=""\
    DATABASE_PORT=""\
    DATABASE_URL=""\
    DATABASE_USERNAME=""\
    WAIT_FOR_DATABASE=""\
    WAIT_TIMEOUT=5

# Install JRE
RUN apk add --no-cache openjdk8-jre-base bash

# Add the user and step in their home directory
RUN addgroup -S liquibase && adduser -S -D -h /liquibase -G liquibase liquibase
WORKDIR /liquibase

# Latest Liquibase Release Version
ARG LIQUIBASE_VERSION=3.8.8

# DB engine to fetch jdbc driver for mysql, postgres, mssql
ARG DB_ENGINE=""

COPY entrypoint.sh /scripts/entrypoint.sh
COPY wait-for-it.sh /scripts/wait-for-it.sh

# Download, install, clean up
RUN mkdir ./drivers ./migrations && \
    apk add --no-cache curl && \
    case $DB_ENGINE in \
      "mysql") \
      URL=https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.19.tar.gz \
      && curl -L $URL | tar -xz --no-anchored --wildcards --to-stdout 'mysql-connector-java-*.jar' > ./drivers/mysql-connector-java-8.0.19.jar \
      && echo "driver: com.mysql.jdbc.Driver" >> ./liquibase.properties \
      ;; \
      "mssql") \
      URL=https://download.microsoft.com/download/4/0/8/40815588-bef6-4715-bde9-baace8726c2a/sqljdbc_8.2.0.0_enu.tar.gz \
      && curl -L $URL | tar -xz --no-anchored --wildcards --to-stdout '*jre8*' > ./drivers/mssql-jdbc-8.2.0.jre8.jar \
      && echo "driver: com.microsoft.sqlserver.jdbc.SQLServerDriver" >> ./liquibase.properties \
      ;; \
      "postgres") \
      URL=https://jdbc.postgresql.org/download/postgresql-42.2.12.jar \
      && curl -L $URL -o ./drivers/postgresql-42.2.12.jar \
      && echo "driver: org.postgresql.Driver" >> ./liquibase.properties \
      ;; \
    esac \
    && curl -L https://github.com/liquibase/liquibase/releases/download/v${LIQUIBASE_VERSION}/liquibase-${LIQUIBASE_VERSION}.tar.gz | tar -xz \
    && apk del curl \
    && chown -R liquibase:liquibase ./ /scripts \
    && chmod 0544 ./liquibase /scripts/entrypoint.sh /scripts/wait-for-it.sh

USER liquibase

VOLUME /liquibase/migrations
VOLUME /liquibase/drivers

ENTRYPOINT ["/scripts/entrypoint.sh"]
CMD ["./liquibase", "--version"]
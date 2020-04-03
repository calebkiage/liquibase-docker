### How to build docker image

```shell script
$ docker build [--build-arg LIQUIBASE_VERSION=<version> --build-arg DB_ENGINE=<engine>] -t [tag] .
```

#### ARGS

`LIQUIBASE_VERSION`: The version of the liquibase tool to download when building. Defaults to 3.8.8

`DB_ENGINE`: The database engine to include a jdbc driver for. The default has no driver packaged with the image.

### Running image

```shell script
$ docker run -ti --rm calebkiage/liquibase sh
```

#### Environment Variables

`CHANGELOG_FILE`: Location to the changelog file (required if running a changelog)

`CLASSPATH`: The classpath to use e.g. (used to add a jdbc driver file to the classpath).
By default, the `/liquibase/drivers` directory is scanned for jar files

`DATABASE_DRIVER`: The database driver class name to use (required if running any commands that connect to a database)

`DATABASE_HOST`: The database host to use (required if WAIT_FOR_DATABASE is true)

`DATABASE_PASSWORD`: The database password to use when connecting to the database (required if running any
commands that connect to a password protected database)

`DATABASE_PORT`: The database host to use (required if WAIT_FOR_DATABASE is true)

`DATABASE_URL`: The jdbc connection string to use (required if running any commands that connect to a database)

`DATABASE_USERNAME`: The database username (required if running any commands that connect to a database)

`WAIT_FOR_DATABASE`: Whether to wait until the database is up before running the command

`WAIT_TIMEOUT`: The amount of time to wait for the database to be up before giving up

#### Volumes

`/liquibase/migrations`: A directory for placing migrations

`/liquibase/drivers`: A directory to store JDBC drivers. By default, this directory is scanned on startup
and all the jar files are added to the classpath.

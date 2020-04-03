#!/usr/bin/env sh

DEBUG="${DEBUG:-false}"
DATABASE_HOST="${DATABASE_HOST}"
DATABASE_PORT="${DATABASE_PORT}"
DATABASE_DRIVER="${DATABASE_DRIVER}"
DATABASE_URL="${DATABASE_URL}"

# Call set_liquibase_property key value
set_liquibase_property() {
  KEY=$1
  VALUE=$2
  if [ -z $KEY]; then
    return 1
  fi
  if [ -z $2]; then
    return 1
  fi

  if [ grep -c "^${KEY}:" ]; then
    sed -i "s/^${KEY}:.*$/${KEY}: ${VALUE}/g" ./liquibase.properties
  else
    echo "${KEY}: ${VALUE}" >> ./liquibase.properties
  fi
}

# set -x

CLASSPATH="${CLASSPATH}"

# Check drivers folder for jar files and add them to the classpath
for filename in ./drivers/*.jar; do
  if [ -z "${CLASSPATH}" ]; then
    CLASSPATH="$filename"
  else
    CLASSPATH="${filename}:${CLASSPATH}"
  fi

  set_liquibase_property "classpath" "${CLASSPATH}"
done

set_liquibase_property "driver" "${DATABASE_DRIVER}"
set_liquibase_property "changeLogFile" "${CHANGELOG_FILE}"
set_liquibase_property "password" "${DATABASE_PASSWORD}"
set_liquibase_property "username" "${DATABASE_USERNAME}"
set_liquibase_property "url" "${DATABASE_URL}"

WAIT="false"
case "$WAIT_FOR_DATABASE" in
  y*|t*)
    WAIT="true";;
esac

HOST_PORT

if [ "$WAIT" = "true" ]; then
  echo "Waiting for a connection to the database"
  /scripts/wait-for-it.sh --timeout="$WAIT_TIMEOUT" --strict "$DATABASE_HOST:${DATABASE_PORT:-80}" || exit "$?"
fi

exec "$@"

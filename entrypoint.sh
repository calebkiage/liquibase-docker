#!/usr/bin/env sh

DEBUG="${DEBUG:-false}"
DATABASE_HOST="${DATABASE_HOST}"
DATABASE_PORT="${DATABASE_PORT}"
DATABASE_DRIVER="${DATABASE_DRIVER}"
DATABASE_URL="${DATABASE_URL}"
PATH="/liquibase:${PATH}"

# Call set_liquibase_property key value
set_liquibase_property() {
  KEY="$1"
  VALUE="$2"
  if [ -z "$KEY" ]; then
    return 1
  fi
  if [ -z "$2" ]; then
    return 1
  fi
  
  touch ./liquibase.properties
  grep -q "^${KEY}:" ./liquibase.properties

  if [ $? -eq 0 ]; then
    sed -i "s/^${KEY}:.*$/${KEY}: ${VALUE}/g" ./liquibase.properties
  else
    echo "${KEY}: ${VALUE}" >> ./liquibase.properties
  fi
}

# set -x

CLASSPATH="${CLASSPATH}"

# Check drivers folder for jar files and add them to the classpath
for filename in ./drivers/*.jar; do
  if [ -r "$filename" ]; then
    if [ -z "${CLASSPATH}" ]; then
      CLASSPATH="$filename"
    else
      CLASSPATH="${filename}:${CLASSPATH}"
    fi
  fi
done

set_liquibase_property "classpath" "${CLASSPATH}"
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

if [ "$WAIT" = "true" ]; then
  echo "Waiting for a connection to the database"
  /scripts/wait-for-it.sh --timeout="$WAIT_TIMEOUT" --strict "$DATABASE_HOST:${DATABASE_PORT:-80}" || exit "$?"
fi

exec "$@"

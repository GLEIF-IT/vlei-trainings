#!/usr/bin/env bash

SALLY="${DIRECT_SALLY:-direct-sally}"
SALLY_SALT="${DIRECT_SALLY_SALT:-0ABVqAtad0CBkhDhCEPd514T}"
SALLY_PASSCODE="${DIRECT_SALLY_PASSCODE:-4TBjjhmKu9oeDp49J7Xdy}"
WEBHOOK_HOST="${DIRECT_WEBHOOK_HOST:-http://hook:9923}"
GEDA_PRE="${GEDA_PRE}"

if [ -z "${GEDA_PRE}" ]; then
  echo "GEDA_PRE auth AID is not set. Exiting."
  exit 1
else
  echo "GEDA_PRE auth AID is set to: ${GEDA_PRE}"
fi

# Create Habery / keystore
kli init \
    --name "${SALLY}" \
    --salt "${SALLY_SALT}" \
    --passcode "${SALLY_PASSCODE}" \
    --config-dir /sally/conf \
    --config-file direct-sally.json

# Create sally identifier
kli incept \
    --name "${SALLY}" \
    --alias "${SALLY}" \
    --passcode "${SALLY_PASSCODE}" \
    --config /sally/conf \
    --file "/sally/conf/sally-incept-no-wits.json"

DEBUG_KLI=true sally server start --name "${SALLY}" --alias "${SALLY}" \
  --passcode "${SALLY_PASSCODE}" \
  --config-dir /sally/conf \
  --config-file direct-sally.json \
  --web-hook "${WEBHOOK_HOST}" \
  --auth "${GEDA_PRE}" \
  --loglevel INFO \
  --http ${DIRECT_PORT:-9823} \
  --direct
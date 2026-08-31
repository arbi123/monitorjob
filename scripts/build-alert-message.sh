#!/bin/bash

URL="${MONITOR_URLS:-https://eu.ebileta.al/biglietteria/listaEventiPub.do}"
URL="${URL%%,*}"
TIME=$(date '+%Y-%m-%d %H:%M:%S')

cat <<EOF
An event with Ireland has been added to the ticket website!

Go there and buy your tickets now:
${URL}

Detected at: ${TIME}
EOF

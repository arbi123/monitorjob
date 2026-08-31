#!/bin/bash
set -e

export MONITOR_URLS="${MONITOR_URLS:-https://eu.ebileta.al/biglietteria/listaEventiPub.do}"
export MONITOR_KEYWORDS="${MONITOR_KEYWORDS:-KOSOVE - IRELAND,KOSOVE - IRANDË,KOSOVE - IRLANDË,KOSOVE - IRANDA,IRELAND,IRLANDË,IRLANDA,Irealnd,ireland,Ireland,Irlandë,irlandë,Irlanda,irlanda,Nations league,nations league,NATIONS LEAGUE,Liga e Kombeve,liga e kombeve,LIGA E KOMBEVE,Liga e Kombëve,liga e kombëve,LIGA E KOMBËVE}"

mvn -B clean test
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  MESSAGE="$("$(dirname "$0")/build-alert-message.sh")"
  "$(dirname "$0")/send-alert.sh" "$MESSAGE"
fi

exit $EXIT_CODE

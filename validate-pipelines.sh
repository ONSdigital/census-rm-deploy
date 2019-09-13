#!/usr/bin/env bash

EXIT_STATUS=0
for i in pipelines/*.yml; do
    fly validate-pipeline -c $i
    VALIDATE_STATUS=$?
    if [ $VALIDATE_STATUS -ne 0 ]; then
        EXIT_STATUS=$VALIDATE_STATUS
        echo $EXIT_STATUS
    fi
done
exit $EXIT_STATUS

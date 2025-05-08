#!/bin/bash

mkdir -p /backups/logs
touch /backups/logs/cron.log

cron

echo "Cron started. Logs:"
tail -f /backups/logs/cron.log

#!/bin/bash
# ===============================================
# Telemetry Monitoring Script
# ===============================================
# Author: Saeem Sayyed Ahmed Kadiri
# Description:
#   This script fetches TPS, error counts, and latency 
#   metrics from logs for telemetry monitoring.
# ===============================================

# -------------------------
# CONFIGURATION (EDIT THESE)
# -------------------------

# Log paths
SYSLOG_PATH="/var/log/messages"
APP_LOG_DIR="/data/app_logs/"

# Remote node hostnames/IPs (replace with your own)
NODES=(
  "node1.example.com"
  "node2.example.com"
  "node3.example.com"
  "node4.example.com"
  "node5.example.com"
  "node6.example.com"
  "node7.example.com"
  "node8.example.com"
  "node9.example.com"
)

REMOTE_SCRIPT="tele3.sh"  # Script to run remotely on nodes

# -------------------------
# SCRIPT START
# -------------------------

echo ""
START_TIME="$(date -d '5 minutes ago' '+%H:%M')"
END_TIME="$(date '+%H:%M')"
CURRENT_DATE="$(date '+%b %e')"
TP_DATE="$(date --date='5 minutes ago' | cut -c 5-19)"
DATE_SHORT="$(date | cut -c 5-10)"
CURRENT_DATETIME="$(date)"

echo ""
echo "From $START_TIME to $END_TIME"
echo "TPS Fetched for: $TP_DATE"
echo ""

# -------------------------
# Local TPS Calculation
# -------------------------
TPS_COUNT="$(grep -i "$CURRENT_DATE" "$SYSLOG_PATH" | grep -i "backbase" | grep -i "$TP_DATE" | wc -l)"

# Get latest app log
LATEST_LOG="$(ls -lrth "$APP_LOG_DIR" | tail -1 | awk '{print $9}')"

# Error counters
SYS_ERROR=$(grep -ci "system error" "$APP_LOG_DIR/$LATEST_LOG")
DB_ERROR=$(grep -ci "database error\|database" "$APP_LOG_DIR/$LATEST_LOG")
ORA_ERROR=$(grep -ci "ora-" "$APP_LOG_DIR/$LATEST_LOG")
NOPROC_ERROR=$(grep -ci "noproc" "$APP_LOG_DIR/$LATEST_LOG")
CONN_FAIL=$(grep -ci "failed to connect" "$APP_LOG_DIR/$LATEST_LOG")
NODE_DOWN=$(grep -ci "nodedown" "$APP_LOG_DIR/$LATEST_LOG")
HIGH_DB=$(grep -ci "db connection error\|high_db_time" "$APP_LOG_DIR/$LATEST_LOG")
CASE_CLAUSE=$(grep -ci "case_clause" "$APP_LOG_DIR/$LATEST_LOG")

# -------------------------
# Display Summary
# -------------------------
echo "------------------------------------------------"
echo "Error Summary:"
echo "System Errors   : $SYS_ERROR"
echo "DB Errors       : $DB_ERROR"
echo "ORA Errors      : $ORA_ERROR"
echo "No Proc         : $NOPROC_ERROR"
echo "Failed Connects : $CONN_FAIL"
echo "Node Down       : $NODE_DOWN"
echo "High DB Time    : $HIGH_DB"
echo "Case Clause     : $CASE_CLAUSE"
echo "TPS (Local)     : $TPS_COUNT"
echo "------------------------------------------------"

# -------------------------
# Remote Node Status Check
# -------------------------
echo ""
echo "Fetching telemetry from remote nodes..."
echo "----------------------------------------"

for NODE in "${NODES[@]}"; do
  echo ">>> Connecting to $NODE"
  ssh -q "$NODE" "bash -s" < "$REMOTE_SCRIPT"
  echo "----------------------------------------"
done

echo ""
echo "Telemetry check complete."

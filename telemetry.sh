#!/bin/bash
# =========================================
# Telemetry Script (Open Source Safe Version)
# Author: Saeem S.A. Kadiri
# Description:
#   Collects transaction performance stats (TPS) and error data
#   from system logs for DevOps monitoring purposes.
# =========================================

echo ""
Starttime="$(date -d '5 minutes ago' "+%H:%M")"
Endtime="$(date +"%H:%M")"
current_date="$(date "+%b %e")"

echo "From $Starttime to $Endtime"
echo ""

tpdate="$(date --date='5 minutes ago' | cut -c 5-19)"
current_short_date="$(date | cut -c 5-10)"
dat="$(date)"
echo "TPS fetched for: $tpdate"
echo ""

# ================================
# TPS calculation (local node)
# ================================
tps_count=$(grep -i "$current_date" /var/log/messages | grep -i "backbase" | grep -i "$tpdate" | wc -l)

# Display TPS
echo "Local Node TPS: $tps_count"
echo ""

# ================================
# Error counts
# ================================
latest_log=$(ls -1t /data/logs/ | head -n 1)

sys_err=$(grep -i "system error" /data/logs/$latest_log | wc -l)
db_err=$(grep -Ei "database error|database" /data/logs/$latest_log | wc -l)
ora_err=$(grep -i "ora-" /data/logs/$latest_log | wc -l)
noproc_err=$(grep -i "noproc" /data/logs/$latest_log | wc -l)
ftc_err=$(grep -i "failed to connect" /data/logs/$latest_log | wc -l)
nodedown_err=$(grep -i "nodedown" /data/logs/$latest_log | wc -l)
highdb_err=$(grep -Ei "db connection error|high_db_time" /data/logs/$latest_log | wc -l)
case_clause_err=$(grep -i "case_clause" /data/logs/$latest_log | wc -l)

echo "Error Summary:"
echo "  System Errors       : $sys_err"
echo "  DB Errors           : $db_err"
echo "  Oracle Errors       : $ora_err"
echo "  No Process Errors   : $noproc_err"
echo "  Failed Connections  : $ftc_err"
echo "  Node Down Events    : $nodedown_err"
echo "  High DB Time Errors : $highdb_err"
echo "  Case Clause Errors  : $case_clause_err"
echo ""

# ================================
# Placeholder: Multi-node stats
# ================================
# To fetch from other nodes, configure their IPs in a secure way.
# Example:
#   NODES=("node1_ip" "node2_ip")
#   for NODE in "${NODES[@]}"; do
#       ssh "$NODE" 'bash -s' < telemetry_remote.sh
#   done
echo "Multi-node telemetry check is disabled in this open-source version."
echo ""

echo "Telemetry check completed!"


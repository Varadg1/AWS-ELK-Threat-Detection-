#!/bin/bash

# Replace this with your actual EC2 public IP or hostname
TARGET_IP="YourIP"

echo "Starting extended ML baseline build and DDoS simulation..."

# Helper function to print timestamp
log() {
  echo "[date +"%Y-%m-%d %H:%M:%S"] $1"
}

# Phase 1: Idle wait (warm-up)
log "Phase 1: Idle wait for 10 minutes to stabilize"
sleep 600

# Phase 2: Normal low traffic browsing (45 minutes)
log "Phase 2: Normal browsing traffic (45 minutes)"
end_time=$((SECONDS + 2700))  # 45 minutes = 2700 seconds
while [ $SECONDS -lt $end_time ]; do
  curl -s -o /dev/null http://$TARGET_IP
  sleep 5
done

# Phase 3: Steady moderate traffic (45 minutes)
log "Phase 3: Moderate traffic load (45 minutes)"
end_time=$((SECONDS + 2700))
while [ $SECONDS -lt $end_time ]; do
  ab -n 200 -c 30 http://$TARGET_IP/ > /dev/null 2>&1
  sleep 8
done

# Phase 4: Traffic spikes (30 minutes)
log "Phase 4: Traffic spikes with bursts (30 minutes)"
end_time=$((SECONDS + 1800))
while [ $SECONDS -lt $end_time ]; do
  ab -n 700 -c 80 http://$TARGET_IP/ > /dev/null 2>&1
  sleep 10
done

# Phase 5: Quiet period for ML to consolidate (15 minutes)
log "Phase 5: Quiet period (15 minutes)"
sleep 900

# Phase 6: DDoS Simulation - high volume attack (30 minutes)
log "Phase 6: Simulated DDoS attack - High volume (30 minutes)"
ab -n 8000 -c 300 -t 1800 http://$TARGET_IP/ > /dev/null 2>&1 &

# Wait for attack to complete (background job)
wait

# Phase 7: Low & slow anomaly (30 minutes)
log "Phase 7: Low & slow traffic for stealth detection (30 minutes)"
end_time=$((SECONDS + 1800))
while [ $SECONDS -lt $end_time ]; do
  curl -s -o /dev/null http://$TARGET_IP
  sleep 15
done

# Phase 8: Final moderate traffic (10 minutes)
log "Phase 8: Final moderate traffic (10 minutes)"
end_time=$((SECONDS + 600))
while [ $SECONDS -lt $end_time ]; do
  ab -n 300 -c 50 http://$TARGET_IP/ > /dev/null 2>&1
  sleep 12
done

log "Extended ML baseline and DDoS simulation completed!"

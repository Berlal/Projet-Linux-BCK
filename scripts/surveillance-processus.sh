#!/bin/bash

# Choisir un chemin de log adapté en fonction du OS utilisé
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  LOG_FILE="$HOME/process_monitor.log"
else
  # Ubuntu/Linux
  LOG_FILE="/var/log/process_monitor.log"
fi

# Fonction pour surveiller les processus et enregistrer les informations
monitor_processes() {
  echo "Date: $(date)" >> $LOG_FILE

  if [[ "$OSTYPE" == "darwin"* ]]; then
    # Commande pour macOS avec formatage
    ps aux | awk '{printf "%-10s %-10s %-8s %-8s %s\n", $1, $2, $3, $4, $11}' | column -t | head -n 10 >> $LOG_FILE
  else
    # Commande pour Linux avec formatage
    ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | awk '{printf "%-10s %-10s %-8s %-8s %s\n", $1, $2, $3, $4, $5}' | column -t | head -n 10 >> $LOG_FILE
  fi

  echo "----------------------------------------" >> $LOG_FILE
}

# Intervalle de temps entre les surveillances
INTERVAL=10

# Boucle infinie pour surveiller les processus toutes les X secondes
while true; do
  monitor_processes
  sleep $INTERVAL
done
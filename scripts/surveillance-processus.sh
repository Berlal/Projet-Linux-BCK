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
  echo "PID | USER | %CPU | %MEM | COMMAND" >> $LOG_FILE
  
  # Lister les processus avec ps
  ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 10 >> $LOG_FILE
  
  echo "----------------------------------------" >> $LOG_FILE
}

# Intervalle de temps entre les surveillances
INTERVAL=10

# Boucle infinie pour surveiller les processus toutes les X secondes
while true; do
  monitor_processes
  sleep $INTERVAL
done
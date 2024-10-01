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

  echo "----------------------------------------\n" >> $LOG_FILE
}

# Détéction des differentes anomalies possible:
# Processus utilisant plus de 80% de CPU, Processus executé par un utilisateur inhabituelle et Processus

detection_anomalies() {

  # Détection des processus avec CPU > 80%
  cpu_anomalies=$(ps aux | awk '$3 > 80 {print $2, $1, $3}' | head -n 10)  
  if [ -n "$cpu_anomalies" ]; then
    echo "$cpu_anomalies" | while read -r pid user cpu; do
      echo "ALERTE CPU: Processus PID=$pid, utilisateur=$user utilise $cpu% du CPU." >> $LOG_FILE
      echo "ALERTE CPU: Processus avec une utilisation CPU élevée détecté : PID=$pid, CPU=$cpu%" 

      # Journaliser l'anomalie
      echo "Horodatage: $(date)" >> $LOG_FILE
      echo "Type d'anomalie: Utilisation CPU élevée" >> $LOG_FILE
      echo "PID: $pid, Utilisateur: $user, CPU: $cpu%" >> $LOG_FILE
      echo "Action: Notification envoyée sur la console \n" >> $LOG_FILE
    done
  else
    echo "CPU: Aucun processus utilisant plus de 80% du CPU n'a été détecté." >> $LOG_FILE
    echo "CPU: Aucun processus utilisant plus de 80% du CPU n'a été détecté." 
  fi

  echo "----------------------------------------" >> $LOG_FILE
  echo "----------------------------------------"

  # Détection des processus zombies
  processus_zombie=$(ps aux | awk '$8 == "Z" {print $2, $1, $8}' | head -n 10)  
  if [ -n "$processus_zombie" ]; then
    echo "$processus_zombie" | while read -r pid user stat; do
      echo "ALERTE ZOMBIE: Processus zombie détecté : PID=$pid, utilisateur=$user" >> $LOG_FILE
      echo "ALERTE ZOMBIE: Processus zombie détecté : PID=$pid"
      
      # Journaliser l'anomalie
      echo "Horodatage: $(date)" >> $LOG_FILE
      echo "Type d'anomalie: Processus zombie" >> $LOG_FILE
      echo "PID: $pid, Utilisateur: $user" >> $LOG_FILE
      echo "Action: Notification envoyée sur la console \n" >> $LOG_FILE
    done
  else
    echo "Zombie: Aucun processus zombie détecté. \n" >> $LOG_FILE
    echo "Zombie: Aucun processus zombie détecté."
  fi

  echo "----------------------------------------" >> $LOG_FILE
  echo "----------------------------------------"

  # Détection des processus exécutés par un utilisateur non autorisé
  utilisateur_etranger=$(ps aux | awk '$1 != "root" && $1 != "trusteduser" {print $2, $1}'| head -n 10)  
  if [ -n "$utilisateur_etranger" ]; then
    echo "$utilisateur_etranger" | while read -r pid user; do
      echo "ALERTE UTILISATEUR: Processus critique non autorisé détecté : PID=$pid, utilisateur=$user" >> $LOG_FILE
      echo "ALERTE UTILISATEUR: Processus non autorisé détecté : PID=$pid, utilisateur=$user"

      # Journaliser l'anomalie
      echo "Horodatage: $(date)" >> $LOG_FILE
      echo "Type d'anomalie: Processus non autorisé" >> $LOG_FILE
      echo "PID: $pid, Utilisateur: $user" >> $LOG_FILE
      echo "Action: Notification envoyée sur la console \n" >> $LOG_FILE
    done
  else
    echo "Utilisateur: Aucun processus d'utilisateur non autorisé détecté. \n" >> $LOG_FILE
    echo "Utilisateur: Aucun processus d'utilisateur non autorisé détecté."
  fi

  echo "---------------------------------------------------------------------------------------------\n\n" >>$LOG_FILE
  echo "---------------------------------------------------------------------------------------------\n\n"
}

# Intervalle de temps entre les surveillances
INTERVAL=5

# Boucle infinie pour surveiller les processus toutes les X secondes
while true; do
  monitor_processes
  detection_anomalies
  sleep $INTERVAL
done
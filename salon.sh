#!/bin/bash

# Welcome Message
echo "~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

# Function to display services
display_services() {
  psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT service_id || ') ' || name FROM services ORDER BY service_id;"
}

# Function to validate and get a valid service_id
get_service_id() {
  while true; do
    display_services
    echo -e "\nPlease select a service by entering the service_id:"
    read SERVICE_ID_SELECTED

    SERVICE_EXISTS=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT COUNT(*) FROM services WHERE service_id = '$SERVICE_ID_SELECTED';")
    
    if [[ $SERVICE_EXISTS -eq 1 ]]; then
      break
    else
      echo -e "\nI could not find that service. What would you like today?"
    fi
  done
}

# Get a valid service_id
get_service_id

# Prompt for customer phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Check if the customer exists in the database
CUSTOMER_EXISTS=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT COUNT(*) FROM customers WHERE phone = '$CUSTOMER_PHONE';")

if [[ $CUSTOMER_EXISTS -eq 0 ]]; then
  # If the customer doesn't exist, ask for their name and insert them into the database
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"
else
  # If the customer exists, retrieve their name
  CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
fi

# Get the service name for confirmation
SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED';")

# Prompt for the appointment time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Get the customer_id
CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

# Insert the appointment into the appointments table
psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME');"

# Print the confirmation message
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
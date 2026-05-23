#! /bin/bash
echo -e "\n~~~~~ MY SALON ~~~~~\n"
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -q -c"
OPTIONS=$($PSQL "SELECT service_id, name FROM services")
echo 'Welcome to My Salon, how can I help you?'

# Main Menu
MAIN_MENU() {
while IFS='|' read -r service_id name
do 
  echo "$service_id) $name"
done <<< "$OPTIONS"
read SERVICE_ID_SELECTED
}

# Check if a valid input
MAIN_MENU
until [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] && [[ $($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED") ]]
do
  echo -e "\nI could not find that service. What would you like today?"
  MAIN_MENU
done

# If yes, check if an existing customer
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
if [[ -z $($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'") ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  # Add both name and phone number to the table
  $PSQL "INSERT INTO customers (phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
fi

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')"
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"
MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
 
 SERVICES=$($PSQL "SELECT service_id, name FROM services")

 echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
  echo -e "\r$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED

#if not a number return to menu
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
MAIN_MENU "Please input a number show on the services list"
else
# retrieve name
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# if they picked a number, but it still wasn't on the list
if [[ -z $SERVICE_NAME ]]
then
MAIN_MENU "Sorry, I couldn't find that service. What would you like today?"
else
CUSTOMER_REGISTRATION "$SERVICE_ID_SELECTED" "$SERVICE_NAME"
  fi
fi
}

# get customer info function
CUSTOMER_REGISTRATION(){
  SERVICE_CHOICE=$1
  SERVICE_NAME=$2

# ask for an retrieve customer phone #
echo -e "\nWhat is you phone number?"
read CUSTOMER_PHONE

# If not in database, get name
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]
then 
# ask and add to database name
echo -e "\nI don't have you in our system, what's your name?"
read CUSTOMER_NAME
INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
fi

# retrieve the auto generated customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# ask for their preferred $service, $customer_name
echo -e "\nWhat time would you like your $(echo $SERVICE_NAME, $CUSTOMER_NAME? | sed -E 's/^ +| +$//g')"
read SERVICE_TIME

#create appointment in appointments table
APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# If unsuccessfully scheduled
if [[ $APPOINTMENT_RESULT != "INSERT 0 1" ]]
then
MAIN_MENU "Could not schedule the appointment. Please try again or call the shop"

else
echo -e "\nI have put you down for a $(echo $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME | sed -E 's/^ +| +$//g')."
fi
}


MAIN_MENU

#!/bin/bash

PSQL="psql -t --username=freecodecamp --dbname=salon -c "

startMenu()
{

  showListOfServices
  
  promptForService

}

showListOfServices()
{

  LIST_OF_SERVICES=$($PSQL "SELECT * FROM services;")

  echo "$LIST_OF_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

}

promptForService()
{
  echo -e "\nChoose a service\n"

  read SERVICE_ID_SELECTED

  CHECK_FOR_EXISTENCE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

  if [[ -z $CHECK_FOR_EXISTENCE ]]
  then
    
    echo -e "\nChoose a valid service\n"

    startMenu

    return

  fi

  echo -e "\nEnter your phone number\n"

  read CUSTOMER_PHONE

  CUSTOMER_EXISTS=$($PSQL "SELECT * FROM customers WHERE phone = '$CUSTOMER_PHONE';")

  if [[ -z $CUSTOMER_EXISTS ]]
  then

    echo -e "\nEnter your name\n"

    read CUSTOMER_NAME

    $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"

  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

  echo -e "\nEnter the time you wish to appointment this service\n"

  read SERVICE_TIME

  SUCCESS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;" | sed -E 's/^ *| *$//g')

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;" | sed -E 's/^ *| *$//g')

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"

}

startMenu

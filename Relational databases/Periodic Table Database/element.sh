#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t -c"

if [[ ! $1 ]]
then

  echo "Please provide an element as an argument."

  else
    if [[ $1 =~ [0-9]+ ]]
    then

      INFO=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number)
                INNER JOIN types USING(type_id) WHERE atomic_number = $1;")

    fi

    if [[ $1 =~ [A-Z][a-z]? ]]
    then

      INFO=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number)
                  INNER JOIN types USING(type_id) WHERE symbol = '$1';")

    fi

    if [[ $1 =~ [A-Z][a-z][a-z]+ ]]
    then

      INFO=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number)
                  INNER JOIN types USING(type_id) WHERE name = '$1';")

    fi

    if [[ -z $INFO ]]
    then

      echo "I could not find that element in the database."

    else

      echo "$INFO" | while read TYPE_ID BAR ATOMIC_NUMBER BAR SYMBOL BAR NAME \
                      BAR ATOMIC_MASS BAR MELTING_POINT_CELSIUS BAR \
                      BOILING_POINT_CELSIUS BAR TYPE
      do
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL)." \
        "It's a $TYPE, with a mass of $ATOMIC_MASS amu." \
        "$NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."

      done

    fi

fi

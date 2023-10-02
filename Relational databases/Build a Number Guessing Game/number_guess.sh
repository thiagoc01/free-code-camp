#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

checkUserNameExistence()
{

  userExists=$($PSQL "SELECT user_id FROM users WHERE username = '$1';")

  if [[ -z $userExists ]]
  then
    
    return 0

  fi

  return $userExists

}

treatUser()
{

  echo "Enter your username:"

  read USERNAME

  checkUserNameExistence $USERNAME

  USER_ID=$?

  if [[ $USER_ID -ne 0 ]]
  then

    USER_DATA=$($PSQL "SELECT games_played, max_guesses 
               FROM users WHERE user_id = $USER_ID;")

    GAMES_PLAYED=$(echo $USER_DATA | cut -d\| -f 1)
    MAX_GUESSES=$(echo $USER_DATA | cut -d\| -f 2)

    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $MAX_GUESSES guesses."

  else

    SUCCESS=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")

    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")

    echo "Welcome, $USERNAME! It looks like this is your first time here."

  fi
  
}

receiveInput()
{

  read INPUT

  while [[ ! $INPUT =~ [0-9]+ ]]
  do
    
    echo "That is not an integer, guess again:"

    read INPUT

  done

}

checkGuess()
{

  if [[ $INPUT -lt $SECRET ]]
  then

    echo "It's higher than that, guess again:"

    NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))

  elif [[ $INPUT -gt $SECRET ]]
  then

    echo "It's lower than that, guess again:"

    NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))

  else

    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET. Nice job!"

  fi

}

playRound()
{

  receiveInput

  checkGuess

}

saveProgress()
{
    GAMES_PLAYED=$(($GAMES_PLAYED + 1))

    if [[ $NUMBER_OF_GUESSES -lt $MAX_GUESSES || $MAX_GUESSES -eq 0 ]]
    then

      SUCCESS=$($PSQL "UPDATE users
                    SET games_played = $GAMES_PLAYED, max_guesses = $NUMBER_OF_GUESSES
                    WHERE username = '$USERNAME';")

    else

      SUCCESS=$($PSQL "UPDATE users
                      SET games_played = $GAMES_PLAYED
                      WHERE username = '$USERNAME';")
    
    fi

}

startProgram()
{

  treatUser

  INPUT=""

  NUMBER_OF_GUESSES=1

  SECRET=$((1 + ($RANDOM % 1000)))

  echo "Guess the secret number between 1 and 1000:"

  while [[ $SECRET -ne $INPUT ]]
  do

    playRound

  done

  saveProgress

}

startProgram

#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

while IFS=',' read -r year round winner opponent winner_goals opponent_goals
do
  
  team_id1=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")

  if [[ $team_id1 == "" ]]
  then

    $PSQL "INSERT INTO teams(name) VALUES('$winner');"
    team_id1=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")

  fi

  team_id2=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")

  if [[ $team_id2 == "" ]]
  then

    $PSQL "INSERT INTO teams(name) VALUES('$opponent');"
    team_id2=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")

  fi

  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
          VALUES($year, '$round', $team_id1, $team_id2, $winner_goals, $opponent_goals);"

done < <(tail -n+2 games.csv)

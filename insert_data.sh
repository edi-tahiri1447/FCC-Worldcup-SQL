#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "truncate teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != winner ]]
  then
    # winner in teams table?
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # if not found
    if [[ -z $WINNER_TEAM_ID ]]
    then
      INSERT_WINNER_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      echo "Added into TEAMS table, $WINNER"
    fi
  fi

  if [[ $OPPONENT != opponent ]]
  then
    # OPPONENT in teams table?
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # if not found
    if [[ -z $OPPONENT_TEAM_ID ]]
    then
      INSERT_OPPONENT_TEAM_RESULT=$($PSQL "INSERT into teams(name) VALUES('$OPPONENT')")
      echo "Added into TEAMS table, $OPPONENT"
    fi
  fi

  INSERT_GAME_RESULT=$($PSQL"INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
  VALUES(
  $YEAR,
  '$ROUND',
  (SELECT team_id FROM teams WHERE name='$WINNER'),
  (SELECT team_id FROM teams WHERE name='$OPPONENT'),
  $WINNER_GOALS,
  $OPPONENT_GOALS
  )")
done


#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# delete old entries and reset serial ids
($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WIN_GOALS OPP_GOALS
do
  # skip first line with row names
  if [[ $YEAR == "year" ]]
  then
    continue
  fi

  # get team ids
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  # add teams if not found
  if [[ -z $WINNER_ID ]] # check if id is null
  then
    ($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  fi
  if [[ -z $OPP_ID ]] # check if id is null
  then
    ($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  fi

  ($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) \
  VALUES($YEAR, '$ROUND', $WINNER_ID, $OPP_ID, $WIN_GOALS, $OPP_GOALS)")



done
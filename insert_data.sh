#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Clear tables before each run to avoid duplicates
$PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY CASCADE"

# While reading the data from the csv file
while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  # Ignore the first line
  if [ "$winner" != "winner" ]
  then
    echo "Teams: $winner | $opponent"
    # Insert team names into teams table
    $PSQL "INSERT INTO teams (name) VALUES('$winner') ON CONFLICT (name) DO NOTHING"
    $PSQL "INSERT INTO teams (name) VALUES('$opponent') ON CONFLICT (name) DO NOTHING"

    # Get winner and opponent id from the teams table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    echo "Teams: $WINNER_ID | $OPPONENT_ID"

    # Insert year, round, winner_id, opponent_id, winner_goals
    # and opponent_goals into games table
    echo "Teams: $year | $round | $winner_goals:$opponent_goals"
    $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals)"
  fi
done < games.csv

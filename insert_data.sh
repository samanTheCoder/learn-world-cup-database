#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#truncate tables
TRUNCATE_TABLES=$($PSQL "TRUNCATE TABLE teams, games;")

#restart auto increament
RESTART_TEAM_ID=$($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")
RESTART_GAME_ID=$($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")


#insert teams
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALD OPPONENT_GOALS
do 
  if [[ $WINNER != "winner" ]]
  then
  
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")

    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')") 
    fi

    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')") 
    fi

  fi
done

#insert games
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALD OPPONENT_GOALS
do 
  if [[ $WINNER != "winner" ]]
  then
  
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year = $YEAR AND winner_id = $WINNER_ID AND opponent_id = $OPPONENT_ID;")

    if [[ -z $GAME_ID ]]
    then
      INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES($YEAR, '$ROUND', $WINNER_GOALD, $OPPONENT_GOALS, $WINNER_ID, $OPPONENT_ID);") 
    fi

  fi
done

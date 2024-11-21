#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
	if [[ $YEAR != year ]]
	then
	  #get team_id from winners
	  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
	  #if not found
	  if [[ -z $WINNER_ID ]]
	  then
      #inserisco il team
		  INSERT_WINNER_RESULT = $($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams the winner, $WINNER
	    fi
      # get new team_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    #get team ids of losers
    OPPS_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
	  #if not found
	  if [[ -z $OPPS_ID ]]
    then
  	  $($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams the opponents, $OPPONENT
	    fi
      # get new team_id for losers
      OPPS_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

	#get game_id
	GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year=$YEAR AND round='$ROUND' AND winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID AND winner_goals=$WINNER_GOALS AND opponent_goals=$OPPONENT_GOALS")
	#if not found
	if [[ -z $GAME_ID ]]
	then
	  #insert game
	  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPS_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
	  if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
	  then
		  echo "Inserted into games, $ROUND"
	  fi
    # get game_id
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE round='$ROUND'")
  fi
fi
done

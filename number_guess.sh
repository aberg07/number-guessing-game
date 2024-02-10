#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align --tuples-only -X -c"
echo "Enter your username:"
read USERNAME_INPUT
USERNAME=$($PSQL "SELECT username FROM high_scores WHERE username='$USERNAME_INPUT'")
if [[ -z $USERNAME ]] #Add user to database if the username inputted does not exist
then
  echo -e "\nWelcome, $USERNAME_INPUT! It looks like this is your first time here."
  USER_ENTRY=$($PSQL "INSERT INTO high_scores(username) VALUES('$USERNAME_INPUT')")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM high_scores WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM high_scores WHERE username='$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
SECRET_NUMBER=$((1 + RANDOM % 1000))
NUMBER_OF_GUESSES=0
while [ true ]
do
  echo "Guess the secret number between 1 and 1000:"
  read USER_INPUT
  if [[ $USER_INPUT =~ ^[0-9]*$ ]]
  then
    if [[ $USER_INPUT -lt $SECRET_NUMBER ]]
    then
      NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
      echo "It's higher than that, guess again:"
    elif [[ $USER_INPUT -gt $SECRET_NUMBER ]]
    then
      NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
      echo "It's lower than that, guess again:"
    else
      NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
      echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      GAMES_PLAYED=$(($GAMES_PLAYED+1))
      GAMES_PLAYED_ENTRY=$($PSQL "UPDATE high_scores SET games_played=$GAMES_PLAYED WHERE username='$USERNAME_INPUT'")
      if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME || -z $BEST_GAME ]]
      then
        NEW_RECORD_ENTRY=$($PSQL "UPDATE high_scores SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME_INPUT'")
      fi
      break
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done

#!/bin/bash

# VARIABLES
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))

# FUNCTIONS
GET_USERNAME() 
{
read USERNAME
# IF BIGGER THAN 22 CHAR
if [[ ${#USERNAME} -gt 22  ]]
then
  echo -e "$USERNAME, is too long. No more than 22 characters is allowed. Try again:"
  GET_USERNAME
fi
}

CHECK_GUESS()
{
  NUMBER_OF_GUESSES=$(( $1 + 1 ))

  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+ ]]
  then
    echo -e "That is not an integer, guess again: "
    CHECK_GUESS $NUMBER_OF_GUESSES
  elif [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    SET_USER_SCORE $NUMBER_OF_GUESSES
    echo -e "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo -e "It's higher than that, guess again: "
    CHECK_GUESS $NUMBER_OF_GUESSES
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo -e "It's lower than that, guess again: "
    CHECK_GUESS $NUMBER_OF_GUESSES
  fi
}

SET_USER_SCORE()
{
  #ADD ONE TO GAMES PLAYED
  ADD_TO_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")
  #CHECK IF NUM_GUESSES IS LESS, THAN ADD AS NEW BEST
  ADD_TO_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME' AND (best_game > $NUMBER_OF_GUESSES OR best_game IS NULL);")
}

#RUN

echo -e "Enter your username:"

GET_USERNAME

GET_USER_INFO=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME';")

if [[ -z $GET_USER_INFO ]] # CHECK IF USERNAME EXIST IN DB
  then
    ADD_USER=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME');") # IF NOT ADD TO DB
    #THEN PRINT:
    echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  else
  # ELSE PRINT MESSAGE
  echo "$GET_USER_INFO" | while IFS="|" read USER_ID USERNAME GAMES_PLAYED BEST_GAME
  do
    # THEN PRINT:
    echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

echo -e "\nGuess the secret number between 1 and 1000: "

CHECK_GUESS 0
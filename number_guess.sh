#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"

GAME() {
    #set game variables
    RANDOM_NUMBER=$((1 + RANDOM % 1000))
    NUMBER_OF_GUESSES=0
    
    #ask user for their username
    echo "Enter your username:"
    #read username
    read USERNAME
    
    #check if username exists in DB
    USER_ID=$(echo "$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")" | sed -r 's/^ *| *$//g')
    
    #if username exists
    if ! [[ -z $USER_ID ]]
    then
        #get total_games_played_by_user
        GAMES_PLAYED_BY_USER=$(echo "$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id='$USER_ID'")" | sed -r 's/^ *| *$//g')
        
        #get user's best game
        BEST_GAME_BY_USER=$(echo "$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id='$USER_ID'")" | sed -r 's/^ *| *$//g')
        
        #print welcome back message
        echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED_BY_USER games, and your best game took $BEST_GAME_BY_USER guesses.\n"
        
    else
        #print first time welcome message
        echo -e "Welcome, $USERNAME! It looks like this is your first time here."
        
        #insert username into DB
        USERNAME_INSERT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
        
        #fetch user_id of new user
        USER_ID=$(echo "$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")" | sed -r 's/^ *| *$//g')
    fi
    
    #enter loop
    while true
    do
        echo "Guess the secret number between 1 and 1000:"
        read USER_INPUT
        
        if ! [[ $USER_INPUT =~ ^[0-9]+$ ]]
        then
            echo -e "That is not an integer, guess again: "
            continue
        fi
        
        ((NUMBER_OF_GUESSES++))
        
        #if random_number is LESS than user_input
        if [[ $RANDOM_NUMBER -lt $USER_INPUT ]]
        then
            echo -e "\nIt's lower than that, guess again: "
            
            #else if random_number is GREATER than user_input
        elif [[ $RANDOM_NUMBER -gt $USER_INPUT ]]
        then
            echo -e "\nIt's higher than that, guess again: "
            
            #else if random_number is EQUAL to user_input
        elif [[ $RANDOM_NUMBER -eq $USER_INPUT ]]
        then
            # Insert final stats into DB
            INSERT_RESULT=$($PSQL "INSERT INTO games(user_id, secret_number, guesses) VALUES($USER_ID, $RANDOM_NUMBER, $NUMBER_OF_GUESSES)")
            
            #print success message
            echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
            break
            return
        fi
    done
}

GAME

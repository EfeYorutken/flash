# flash
a CLI tool that enables the user to create and test themselfs on a deck of cards, flash card style
at the moment there are 3 parameters you can pass to the tool
1. -p : the following parameter is the path
1. -k : the known cards will be asked as well (the state of the cards will not change)
1. -a : adding a new card to the given deck with -p

TODO
- divide the code into smaller files
- clear the screen after every answer
- feedback based on weather or not the answer was correct
# the deck file
simple txt file that abides by the following rulse
1. each line is a card
1. each line has 3 parts, each seperated by a comma
- back of the card,front of the card,"n" if you have not learned it yet, "y" if learned

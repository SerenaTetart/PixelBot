# PixelBot

## Table of contents
* [General infos](#general-infos)
* [Requirements](#requirements)
* [PixelBot 1.12.1](#pixelbot-1121)

## General Infos

PixelBot is a combination of an addon and a python program that exploits WoW API in order to automate characters and play the game alone (when you need 5 or 25 people).

This bot works on every versions of the game (1.12.1, 2.4.3, 3.3.5 or even retail) **but** needs some modifications between two versions to work because of the API.

*All the tests are made on a private server.*


### Concept:

The concept is very simple, we use the API of the game to generate colors from a pixel based on the situation: for instance if I have to use a spell the pixel will become green with a specific value, then the Python program will read that pixel and simulate the key toward the respective client.

The combat algorithm is a Decision Tree made by hand: we test multiple conditions iteratively until there is one that is met and we modify the specific color to give an order to the Python program.

## Requirements

You might want to do this on a private server but it's up to you. (There are good repacks on internet which are servers precompiled in C++)

## PixelBot 1.12.1

The addon for this version is called *GodModeVanilla* (yes, a cringe name :joy:), just copy and paste it inside your ".../WoW/Interface/Addons" folder.

This version is special since we need fewer inputs thanks to the API that allows direct spell casting with CastSpellByName("name_of_the_spell").

The downside is we don't have automated movement, it is implemented only after 3.0.2+, but the program is able to:
* Follow the leader
* Rotate characters to face the enemy
* Stop moving when in range of the enemy
* Take some steps back when using a Hunter to have the range to use Bows/Guns (won't do that if being attacked)

<p align="center"> <b>Exemple of dungeon using PixelBot</b> </p>

https://user-images.githubusercontent.com/65224852/170023216-7a54be0d-2e21-4b6a-b61d-57f3dd63d4a0.mp4

*Note that:*
* *In the new version the druid take a few steps to the right in order to not "stack" with others casters (it's just visually more interesting)*
* *I have 4 others screens on my second monitor*

Furthermore in this version I made a scrapper that takes all the items in the game with their respective statistics and put them inside a database in order to compute bonus healing since the API don't give any functions for this.

<p align="center"> <b>The scrapper in action</b> </p>
<p align="center">
<img src="https://user-images.githubusercontent.com/65224852/170027326-1449bb4b-6cb2-468c-aede-91c0fcdeb26a.PNG">
</p>

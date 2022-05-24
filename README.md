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

The concept is very simple, we use the API of the game to generate colors from a pixel based on the situation: for instance if I have to use a spell the pixel will become green with a specific value, then the Python program will read that pixel and simulate the key and finally HotkeyNet (a third program) will redistribute all the inputs toward the respective screens.

The combat algorithm is a Decision Tree made by hand: we test multiple conditions iteratively until there is one that is met and we modify the specific color to give an order to the Python program.

<p align="center"> <b>Exemple of Decision Tree</b> </p>
<p align="center">
<img src="https://www.nvidia.com/content/dam/en-zz/Solutions/glossary/data-science/xgboost/img-2.png">
</p>

## Requirements

You might want to do this on a private server but it's up to you. (There are good repacks on internet which are servers precompiled in C++)

## PixelBot 1.12.1

This version is special since we need lesser inputs thanks to the API that allows direct spell casting with CastSpellByName("name_of_the_spell").

The downside is we don't have automated movement, it is implemented only after 3.0.2+, but the program is able to:
* Follow the leader
* Rotate characters to face the enemy
* Stop moving when in range of the enemy
* Taking some steps back when using a Hunter to have the range to use Bows/Guns (won't do that if being attacked)

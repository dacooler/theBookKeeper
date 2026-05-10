extends Node

var latest_score := 0;

func submit_score(score):
	latest_score = score;
	highscores.append(score);
	highscores.sort();
	highscores.reverse();

var highscores = [];

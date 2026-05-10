extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	$score.text = str(Global.latest_score);
	var highscores = "Highscores:\n";
	for score in Global.highscores:
		highscores += str(score) + '\n';
	$highscores.text = highscores; 

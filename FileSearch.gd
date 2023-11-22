extends Button

@onready var progress_bar = $"../../../../ProgressBar"
@onready var label = $"../../../../Label"


func _on_button_up():
	$"../../../../FileDialog".popup_centered()
	progress_bar.hide()
	label.hide()

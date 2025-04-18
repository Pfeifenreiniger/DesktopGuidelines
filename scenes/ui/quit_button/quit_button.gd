extends Button


#-------METHODS: CALLED AT SCENE ENTRY-------

func _ready() -> void:
	pressed.connect(_on_button_pressed)


#-------METHODS: CONNECTED TO SIGNALS-------

func _on_button_pressed() -> void:
	get_tree().quit()

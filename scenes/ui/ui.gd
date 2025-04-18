extends Control

#-------NODES-------

@onready var guidelines: Control = $Guidelines as Control

@onready var menu_button: Button = $VBoxContainer/MenuButton as Button
@onready var menu: BoxContainer = $VBoxContainer/Menu as BoxContainer


#-------PROPERTIES-------

const y_guideline_scene:PackedScene = preload("res://scenes/ui/guideline/y_guideline.tscn")
const x_guideline_scene:PackedScene = preload("res://scenes/ui/guideline/x_guideline.tscn")


#-------METHODS: CALLED AT SCENE ENTRY-------

func _ready() -> void:
	
	# connect signals
	menu_button.pressed.connect(_on_menu_button_pressed)
	menu.guideline_added.connect(_on_menu_guideline_added)
	menu.guidelines_lock_button_toggled.connect(_on_menu_guidelines_lock_button_toggled)
	menu.remove_all_guidelines.connect(_on_menu_remove_all_guidelines)


#-------METHODS: CONNECTED TO SIGNALS-------

func _on_menu_button_pressed() -> void:
	menu.visible = !menu.visible


func _on_menu_guideline_added(axis, color) -> void:
	
	if axis == Enums.AXIS_VERTICAL:
		var x_guideline:ColorRect = x_guideline_scene.instantiate()
		x_guideline.remove_guideline.connect(_on_remove_guideline)
		x_guideline.modulate = color
		x_guideline.x_position = 300
		guidelines.add_child(x_guideline)
	
	elif axis == Enums.AXIS_HORIZONTAL:
		var y_guideline:ColorRect = y_guideline_scene.instantiate()
		y_guideline.remove_guideline.connect(_on_remove_guideline)
		y_guideline.y_position = 100
		y_guideline.modulate = color
		guidelines.add_child(y_guideline)


func _on_menu_guidelines_lock_button_toggled(status:bool) -> void:
	for guideline in guidelines.get_children():
		guideline.locked = status


func _on_menu_remove_all_guidelines() -> void:
	for guideline in guidelines.get_children():
		guideline.queue_free()


func _on_remove_guideline(guideline_reference:ColorRect) -> void:
	guideline_reference.queue_free()

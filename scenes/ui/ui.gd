extends Control

#-------NODES-------

@onready var guidelines: Control = $Guidelines as Control

@onready var menu_button: Button = $VBoxContainer/MenuButton as Button
@onready var menu: PanelContainer = $VBoxContainer/Menu as PanelContainer


#-------PROPERTIES-------

const y_guideline_scene:PackedScene = preload("res://scenes/ui/guideline/y_guideline.tscn")
const x_guideline_scene:PackedScene = preload("res://scenes/ui/guideline/x_guideline.tscn")
const rect_guideline_scene:PackedScene = preload("res://scenes/ui/guideline/rect_guideline.tscn")
const free_line_guideline_scene:PackedScene = preload("res://scenes/ui/guideline/free_line_guideline.tscn")

const menu_icons:Dictionary[String, CompressedTexture2D] = {
	'burger' : preload("res://assets/icons/menu/burger.png"),
	'x' : preload("res://assets/icons/menu/x.png")
}


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
	
	if menu.visible:
		menu_button.icon = menu_icons['x']
		menu_button.tooltip_text = "close menu"
	else:
		menu_button.icon = menu_icons['burger']
		menu_button.tooltip_text = "open menu"


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
	
	elif axis == Enums.AXIS_RECT:
		var rect_guideline:RectGuideline = rect_guideline_scene.instantiate()
		rect_guideline.remove_guideline.connect(_on_remove_guideline)
		rect_guideline.position = Vector2(
			MonitorState.MONITOR_SIZE.x / 2, MonitorState.MONITOR_SIZE.y / 2
		)
		rect_guideline.color = color
		guidelines.add_child(rect_guideline)
	
	elif axis == Enums.AXIS_FREE_LINE:
		var free_line_guideline:FreeLineGuideline = free_line_guideline_scene.instantiate()
		free_line_guideline.remove_guideline.connect(_on_remove_guideline)
		free_line_guideline.color = color
		guidelines.add_child(free_line_guideline)


func _on_menu_guidelines_lock_button_toggled(status:bool) -> void:
	for guideline in guidelines.get_children():
		guideline.locked = status


func _on_menu_remove_all_guidelines() -> void:
	for guideline in guidelines.get_children():
		guideline.queue_free()
	GuidelinesState.reset_guidelines()


func _on_remove_guideline(guideline_reference:Node) -> void:
	
	var was_locked:bool = guideline_reference.locked
	
	guideline_reference.queue_free()
	GuidelinesState.remove_guideline()
	
	if was_locked:
		menu.add_guideline_button.disabled = true

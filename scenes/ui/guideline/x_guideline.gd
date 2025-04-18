extends ColorRect

#-------CUSTOM SIGNALS-------

signal remove_guideline(self_reference)


#-------NODES-------

@onready var grab_area: ColorRect = $GrabArea as ColorRect
@onready var remove_button: Button = $RemoveButton as Button


#-------PROPERTIES-------

@export var x_position:int = 100
var is_dragging:bool = false

var locked:bool = false:
	get:
		return locked
	set(value):
		locked = value
		if value:
			grab_area.mouse_default_cursor_shape = Control.CURSOR_ARROW
		else:
			grab_area.mouse_default_cursor_shape = Control.CURSOR_DRAG


#-------METHODS: CALLED AT SCENE ENTRY-------

func _ready() -> void:
	
	grab_area.modulate = Color(1, 1, 1, 0.01) # nahezu transparent -> empfaengt so noch Mausinputs
	
	# mouse cursor anpassen
	grab_area.mouse_default_cursor_shape = Control.CURSOR_DRAG
	
	anchor_left = 0
	anchor_right = 0
	
	offset_left = x_position # X-Achsen-Position
	offset_right = x_position + 2
	
	# connect signals
	grab_area.gui_input.connect(_on_grab_area_gui_input)
	remove_button.pressed.connect(_on_remove_button_pressed)


#-------METHODS: CONNECTED SIGNALS-------

func _on_grab_area_gui_input(event:InputEvent) -> void:
	
	if locked:
		return
	
	# damit man nicht zu weit nach links oder rechts zieht
	if global_position.x + 5 >= MonitorState.MONITOR_SIZE.x:
		global_position.x -= 6
		is_dragging = false
		return
	
	if global_position.x - 5 <= 0:
		global_position.x += 6
		is_dragging = false
		return
	
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				get_viewport().set_input_as_handled()
			
			else:
				is_dragging = false
	
	elif event is InputEventMouseMotion and is_dragging:
		position.x = clamp(position.x + event.relative.x, 0, get_viewport_rect().size.x)


func _on_remove_button_pressed() -> void:
	remove_guideline.emit(self)

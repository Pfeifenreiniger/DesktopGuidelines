extends BoxContainer

#-------CUSTOM SIGNALS-------

signal guidelines_lock_button_toggled(status)
signal guideline_added(axis, color)
signal remove_all_guidelines


#-------NODES-------

@onready var screen_option_button: OptionButton = $VBoxContainer/ScreenOptionButton as OptionButton
@onready var lock_check_button: CheckButton = $VBoxContainer/LockCheckButton as CheckButton
@onready var axis_option_button: OptionButton = $VBoxContainer/HBoxContainer/AxisOptionButton as OptionButton
@onready var color_option_button: OptionButton = $VBoxContainer/HBoxContainer/ColorOptionButton as OptionButton
@onready var add_guideline_button: Button = $VBoxContainer/HBoxContainer/AddGuidelineButton as Button


#-------PROPERTIES-------

var axis:String = Enums.AXIS_HORIZONTAL
var color:Color = Enums.COLOR_RED


#-------METHODS: CALLED AT SCENE ENTRY-------

func _ready() -> void:
	
	_init_screens_options()
	
	# connect signals
	screen_option_button.item_selected.connect(_on_screen_option_button_item_selected)
	lock_check_button.toggled.connect(_on_lock_check_button_toggled)
	axis_option_button.item_selected.connect(_on_axis_option_button_item_selected)
	color_option_button.item_selected.connect(_on_color_option_button_item_selected)
	add_guideline_button.pressed.connect(_on_add_guideline_button_pressed)


func _init_screens_options() -> void:
	var screen_count = DisplayServer.get_screen_count()
	for i in range(screen_count):
		screen_option_button.add_item('Screen ' + str(i + 1), i)


#-------METHODS: ADDED TO SIGNALS-------

func _on_lock_check_button_toggled(status:bool) -> void:
	guidelines_lock_button_toggled.emit(status)
	add_guideline_button.disabled = status # wenn gelockt, dann sollen auch keine neuen Guidelines hinzugefuegt werden koennen


func _on_screen_option_button_item_selected(i:int) -> void:
	var monitor_index:int = i
	if monitor_index < 0 or monitor_index >= DisplayServer.get_screen_count():
		push_warning("Ungültiger Monitorindex.")
		return
	
	remove_all_guidelines.emit()
	
	# Bildschirm-Daten holen
	var screen_rect = DisplayServer.screen_get_usable_rect(monitor_index)
	
	# Fenster in den normalen Modus versetzen (falls vorher minimiert oder sowas)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Position setzen auf Anfang des Monitors
	DisplayServer.window_set_position(screen_rect.position)
	
	# Aktives Fenster auf richtigen Monitor verschieben
	DisplayServer.window_set_current_screen(monitor_index)
	
	# Vollbild aktivieren
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	# Transparentes Fenster wieder "durchklickbar" durch C# Methode machen
	MousePassThrough._Ready()
	
	# Monitor State aktualisieren
	MonitorState.reload(monitor_index)


func _on_axis_option_button_item_selected(i:int) -> void:
	if i == 0:
		axis = Enums.AXIS_HORIZONTAL
	elif i == 1:
		axis = Enums.AXIS_VERTICAL


func _on_color_option_button_item_selected(i:int) -> void:
	match i:
		0:
			color = Enums.COLOR_RED
		1:
			color = Enums.COLOR_BLUE
		2:
			color = Enums.COLOR_GREEN
		3:
			color = Enums.COLOR_WHITE
		4:
			color = Enums.COLOR_ORANGE
		5:
			color = Enums.COLOR_BROWN
		6:
			color = Enums.COLOR_YELLOW
		7:
			color = Enums.COLOR_VIOLET
		8:
			color = Enums.COLOR_PINK


func _on_add_guideline_button_pressed() -> void:
	guideline_added.emit(axis, color)

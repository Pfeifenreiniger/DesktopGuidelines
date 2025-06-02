extends PanelContainer

#-------CUSTOM SIGNALS-------

signal guidelines_lock_button_toggled(status)
signal guideline_added(axis, color)
signal remove_all_guidelines


#-------NODES-------

@onready var screen_option_button: OptionButton = $VBoxContainer/ScreenOptionButton as OptionButton
@onready var lock_check_button: CheckButton = $VBoxContainer/HBoxContainer2/LockCheckButton as CheckButton
@onready var pixel_check_button: CheckButton = $VBoxContainer/HBoxContainer2/PixelCheckButton as CheckButton
@onready var hide_guidelines_check_box: CheckBox = $VBoxContainer/HBoxContainer2/HideGuidelinesCheckBox as CheckBox
@onready var axis_option_button: OptionButton = $VBoxContainer/HBoxContainer/AxisOptionButton as OptionButton
@onready var color_option_button: OptionButton = $VBoxContainer/HBoxContainer/ColorOptionButton as OptionButton
@onready var add_guideline_button: Button = $VBoxContainer/HBoxContainer/AddGuidelineButton as Button

@onready var container_rect_size: HBoxContainer = $VBoxContainer/HBoxContainer3 as HBoxContainer
@onready var width_spin_box: SpinBox = $VBoxContainer/HBoxContainer3/MarginContainer/VBoxContainer/WidthSpinBox as SpinBox
@onready var height_spin_box: SpinBox = $VBoxContainer/HBoxContainer3/MarginContainer2/VBoxContainer2/HeightSpinBox as SpinBox


#-------PROPERTIES-------

var axis:String = Enums.AXIS_HORIZONTAL
var color:Color = Enums.COLOR_RED
const hide_icon_1:CompressedTexture2D = preload("res://assets/icons/hide/hide_1.png")
const hide_icon_2:CompressedTexture2D = preload("res://assets/icons/hide/hide_2.png")


#-------METHODS: CALLED AT SCENE ENTRY-------

func _ready() -> void:
	
	_init_screens_options()
	
	#width_spin_box.min_value = GuidelinesState.MIN_SIZE_RECT_GUIDELINES.x
	#height_spin_box.min_value = GuidelinesState.MIN_SIZE_RECT_GUIDELINES.y
	width_spin_box.max_value = MonitorState.MONITOR_SIZE.x - 20
	height_spin_box.max_value = MonitorState.MONITOR_SIZE.y - 20
	
	# connect signals
	screen_option_button.item_selected.connect(_on_screen_option_button_item_selected)
	lock_check_button.toggled.connect(_on_lock_check_button_toggled)
	pixel_check_button.toggled.connect(_on_pixel_check_button_toggled)
	hide_guidelines_check_box.toggled.connect(_on_hide_guidelines_check_box_toggled)
	axis_option_button.item_selected.connect(_on_axis_option_button_item_selected)
	color_option_button.item_selected.connect(_on_color_option_button_item_selected)
	add_guideline_button.pressed.connect(_on_add_guideline_button_pressed)
	width_spin_box.value_changed.connect(_on_spin_box_value_changed.bind('width'))
	height_spin_box.value_changed.connect(_on_spin_box_value_changed.bind('height'))
	
	GuidelinesState.max_amount_reached.connect(_on_guidelines_state_max_amount_reached)
	GuidelinesState.do_block_guideline_adds.connect(_on_guideline_state_do_block_guideline_adds)
	MonitorState.monitor_size_changed.connect(_on_monitor_state_monitor_size_changed)


func _init_screens_options() -> void:
	var screen_count = DisplayServer.get_screen_count()
	for i in range(screen_count):
		screen_option_button.add_item('Screen ' + str(i + 1), i)


#-------METHODS: ADDED TO SIGNALS-------

func _on_lock_check_button_toggled(status:bool) -> void:
	guidelines_lock_button_toggled.emit(status)
	
	if !axis == Enums.AXIS_RECT:
		add_guideline_button.disabled = true if status else (false if not hide_guidelines_check_box.button_pressed else true)
	
	else:
		if height_spin_box.value >= GuidelinesState.MIN_SIZE_RECT_GUIDELINES.y && width_spin_box.value >= GuidelinesState.MIN_SIZE_RECT_GUIDELINES.x:
			if !hide_guidelines_check_box.button_pressed && !lock_check_button.button_pressed:
				add_guideline_button.disabled = false
			
			else:
				add_guideline_button.disabled = true
		
		else:
			add_guideline_button.disabled = true
	
	lock_check_button.tooltip_text = "un-lock guidelines" if status else "lock guidelines"


func _on_pixel_check_button_toggled(status:bool) -> void:
	GuidelinesState.show_pixel_information = status
	
	pixel_check_button.tooltip_text = "hide pixel-information" if status else "show pixel-information"


func _on_hide_guidelines_check_box_toggled(status:bool) -> void:
	hide_guidelines_check_box.icon = hide_icon_2 if status else hide_icon_1
	hide_guidelines_check_box.tooltip_text = "show hidden guidelines" if status else "hide guidelines"
	
	if !axis == Enums.AXIS_RECT:
		add_guideline_button.disabled = true if status else (false if not lock_check_button.button_pressed else true)
	
	else:
		if height_spin_box.value >= GuidelinesState.MIN_SIZE_RECT_GUIDELINES.y && width_spin_box.value >= GuidelinesState.MIN_SIZE_RECT_GUIDELINES.x:
			if !hide_guidelines_check_box.button_pressed && !lock_check_button.button_pressed:
				add_guideline_button.disabled = false
			
			else:
				add_guideline_button.disabled = true
		
		else:
			add_guideline_button.disabled = true
	
	GuidelinesState.hide_guidelines = status


func _on_screen_option_button_item_selected(i:int) -> void:
	var monitor_index:int = i
	if monitor_index < 0 or monitor_index >= DisplayServer.get_screen_count():
		push_warning("Invalid screen index")
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
		container_rect_size.visible = false
		width_spin_box.value = width_spin_box.min_value
		height_spin_box.value = height_spin_box.min_value
		add_guideline_button.disabled = true if hide_guidelines_check_box.button_pressed else (false if not lock_check_button.button_pressed else true)
	elif i == 1:
		axis = Enums.AXIS_VERTICAL
		container_rect_size.visible = false
		width_spin_box.value = width_spin_box.min_value
		height_spin_box.value = height_spin_box.min_value
		add_guideline_button.disabled = true if hide_guidelines_check_box.button_pressed else (false if not lock_check_button.button_pressed else true)
	elif i == 2:
		axis = Enums.AXIS_RECT
		container_rect_size.visible = true
		width_spin_box.value = GuidelinesState.MIN_SIZE_RECT_GUIDELINES.x
		height_spin_box.value = GuidelinesState.MIN_SIZE_RECT_GUIDELINES.y
		width_spin_box.tooltip_text = "select a width of at least %s px" % str(int(GuidelinesState.MIN_SIZE_RECT_GUIDELINES.x))
		height_spin_box.tooltip_text = "select a height of at least %s px" % str(int(GuidelinesState.MIN_SIZE_RECT_GUIDELINES.y))
		if width_spin_box.value < GuidelinesState.MIN_SIZE_RECT_GUIDELINES.x || height_spin_box.value < GuidelinesState.MIN_SIZE_RECT_GUIDELINES.y:
			add_guideline_button.disabled = true
	elif i == 3:
		axis = Enums.AXIS_FREE_LINE
		container_rect_size.visible = false
		width_spin_box.value = width_spin_box.min_value
		height_spin_box.value = height_spin_box.min_value
		add_guideline_button.disabled = true if hide_guidelines_check_box.button_pressed else (false if not lock_check_button.button_pressed else true)


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
	# die maximale Anzahl an Guidelines sollte nicht ueberschritten werden
	if GuidelinesState.amount_of_guidelines >= GuidelinesState.MAX_GUIDELINES:
		return
	
	GuidelinesState.add_guideline()
	
	guideline_added.emit(axis, color)


func _on_guidelines_state_max_amount_reached(status:bool) -> void:
	add_guideline_button.disabled = status
	
	add_guideline_button.tooltip_text = "maximum of guidelines reached" if status else "add guideline"


func _on_guideline_state_do_block_guideline_adds(status:bool) -> void:
	add_guideline_button.disabled = true if hide_guidelines_check_box.button_pressed else (status if not lock_check_button.button_pressed else true)


func _on_spin_box_value_changed(value:float, dimension:String):
	if dimension == 'width':
		if value >= GuidelinesState.MIN_SIZE_RECT_GUIDELINES.x:
			GuidelinesState.size_rect_guidelines.x = int(round(value))
			
			if height_spin_box.value >= GuidelinesState.MIN_SIZE_RECT_GUIDELINES.y:
				if !hide_guidelines_check_box.button_pressed && !lock_check_button.button_pressed:
					add_guideline_button.disabled = false
		
		else:
			add_guideline_button.disabled = true
	
	else:
		if value >= GuidelinesState.MIN_SIZE_RECT_GUIDELINES.y:
			GuidelinesState.size_rect_guidelines.y = int(round(value))
			
			if width_spin_box.value >= GuidelinesState.MIN_SIZE_RECT_GUIDELINES.x:
				if !hide_guidelines_check_box.button_pressed && !lock_check_button.button_pressed:
					add_guideline_button.disabled = false
		
		else:
			add_guideline_button.disabled = true


func _on_monitor_state_monitor_size_changed(new_size:Vector2):
	width_spin_box.max_value = new_size.x - 20
	height_spin_box.max_value = new_size.y - 20
	
	width_spin_box.value = GuidelinesState.MIN_SIZE_RECT_GUIDELINES.x
	height_spin_box.value = GuidelinesState.MIN_SIZE_RECT_GUIDELINES.y

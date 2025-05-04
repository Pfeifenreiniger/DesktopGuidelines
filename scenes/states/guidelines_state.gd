extends Node

#-------CUSTOM SIGNALS-------

signal max_amount_reached(status:bool)
signal do_hide_guidelines(status:bool)
signal do_show_pixel_information(status:bool)


#-------PROPERTIES-------

const MAX_GUIDELINES:int = 30

var amount_of_guidelines:int = 0:
	get:
		return amount_of_guidelines
	set(value):
		amount_of_guidelines = value
		if amount_of_guidelines >= MAX_GUIDELINES:
			max_amount_reached.emit(true)
		else:
			max_amount_reached.emit(false)

var hide_guidelines:bool = false:
	get:
		return hide_guidelines
	set(value):
		hide_guidelines = value
		do_hide_guidelines.emit(value)

var show_pixel_information:bool = true:
	get:
		return show_pixel_information
	set(value):
		show_pixel_information = value
		do_show_pixel_information.emit(value)



#-------METHODS-------

func add_guideline(amount:int = 1) -> void:
	amount_of_guidelines += amount


func remove_guideline(amount:int = 1) -> void:
	amount_of_guidelines -= amount
	amount_of_guidelines = max(0, amount_of_guidelines) # um nicht unter 0 zu fallen


func reset_guidelines() -> void:
	amount_of_guidelines = 0

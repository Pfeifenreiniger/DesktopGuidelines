extends Node

#-------CUSTOM SIGNALS-------

signal max_amount_reached(status:bool)


#-------PROPERTIES-------

const MAX_GUIDELINES:int = 20

var amount_of_guidelines:int = 0:
	get:
		return amount_of_guidelines
	set(value):
		amount_of_guidelines = value
		if amount_of_guidelines >= MAX_GUIDELINES:
			max_amount_reached.emit(true)
		else:
			max_amount_reached.emit(false)


#-------METHODS-------

func add_guideline(amount:int = 1) -> void:
	amount_of_guidelines += amount


func remove_guideline(amount:int = 1) -> void:
	amount_of_guidelines -= amount
	amount_of_guidelines = max(0, amount_of_guidelines) # um nicht unter 0 zu fallen


func reset_guidelines() -> void:
	amount_of_guidelines = 0

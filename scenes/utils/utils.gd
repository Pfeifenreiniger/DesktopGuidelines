extends Node

#-------METHODS-------

func tint_icon(image: Image, tint_color: Color) -> Texture2D:
	if image is Image:
		for y in image.get_height():
			for x in image.get_width():
				var original = image.get_pixel(x, y)
				var tinted = original * tint_color
				tinted.a = original.a # Alpha soll erhalten bleiben
				image.set_pixel(x, y, tinted)
		
		var texture:ImageTexture = ImageTexture.create_from_image(image)
		return texture
	return null

extends Label

export(String) var prefix = "" #enables a prefix to be inserted before label update text

func init(_string):
	self.text = prefix + " " + _string

func update_text(new_text):
	self.text = prefix + " " + new_text

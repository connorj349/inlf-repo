extends TextureProgressBar
## Texture Progress Bar handling
##
## only handles setting the initial value and updating it
## Is only attached to the player's health bar as it's the only TextureProgBar in the game
## REMOVE

func init(current_value, m_value):
	self.max_value = m_value
	self.value = current_value

func update_bar(_value):
	self.value = _value

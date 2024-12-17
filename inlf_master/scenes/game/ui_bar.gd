extends ProgressBar
## ProgressBar handling
##
## Handles initializing the bar's max value and current and updates during gameplay
## maybe just handle this in the individual scripts like the player, etc.?

func init(current_value, m_value):
	self.max_value = m_value
	self.value = current_value

func update_bar(_value):
	self.value = _value

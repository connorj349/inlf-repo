extends ProgressBar

func init(current_value, m_value): #this entire script will handle modifying a progress bar on the player hud
	self.value = current_value
	self.max_value = m_value

func update_bar(value):
	self.value = value

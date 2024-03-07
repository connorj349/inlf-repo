extends ProgressBar
tool

func init(current_value, m_value):
	self.max_value = m_value
	self.value = current_value

func update_bar(value):
	self.value = value

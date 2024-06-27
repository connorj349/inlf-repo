@tool
extends ProgressBar

func init(current_value, m_value):
	self.max_value = m_value
	self.value = current_value

func update_bar(_value):
	self.value = _value

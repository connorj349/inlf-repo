extends HintObject

# player will drop biomass or cropses(illegal) into this machine
# need to hookup generator to this
# when generator is on, this machine will passively create fertilizer if biomass has been inserted

func _ready():
	pass

func _on_ItemDeposit_body_entered(body):
	pass # Replace with function body.

func _on_CreateFertilizerTimer_timeout():
	pass # Replace with function body.

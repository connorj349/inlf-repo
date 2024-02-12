extends ItemData
class_name ItemDataSeed

export(int) var blood = 0
export(int) var water = 0
export(int) var fertilizer = 0
export(int) var exotic = 0
export(Array, Resource) var output_item_data # the item(s) that is produced when successfully grown
export(int) var growth_needed = 0

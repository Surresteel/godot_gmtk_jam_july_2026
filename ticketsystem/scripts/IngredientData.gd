extends Resource

class_name IngredientData

enum COOK { RAW, BAKED, FRIED, MICROWAVED, TOASTED }
enum DONENESS { RAW, RARE, MEDIUMRARE, MEDIUM, WELLDONE, BURNT }
enum PREP { CHOPPED, SUNNYSIDEUP }

@export_group("Meta")
@export var name: String
@export var image: Image
@export var mesh: Mesh

@export_group("Cooking")
@export_subgroup("Style")
@export var cook: Array[COOK]
@export var doneness: Array[DONENESS] = [DONENESS.RAW, DONENESS.WELLDONE]
@export var prep: Array[PREP]
@export_subgroup("CookLevel")
@export var doneness_intervals: Array[float] = [50.0]

@export_group("Specifics")
@export var bounding_box_size: Vector3 = Vector3.ONE
@export var flipped_position: Vector3
@export var laying_position: Vector3
@export var laying_rotation_degrees: Vector3

	

An experimental simple CLI prompt helper

To use this package, first call init function

prompt.init :: proc( use_prompt:string = def_prompt) ->err

	optional argument to change the prompt to anything you want, default is " :"

	Returns .OK or .INVALID_HANDLE


get_number :: proc(message:string, min:int = 0, max:int=0) -> (value:int, ok:err)

	Queries for a number input. Number can be positive or negative 64 bit integer
	Optional min and max values, forces entry of numbers between min and max

	Returns value, .OK or .CANCEL or a .MIN_MAX error (if min is greater than max)


get_options :: proc(message:string, options: ^[]option) -> (value:int, index:int)

	Queries for a response from a list of items. The ^[]option is an array of option
	structs, having key, value pairs.

	option :: struct {
		key		:string,
		value	:int,
	}

	Arrow keys are used to select an item and enter finalizes the choice. Current
	selection is highlited in green.
	
	Returns the value, and an index which can be used to retrieve the key.

get_password :: proc(message:string, min_len:int=0, max_len:int=0, show:bool=false) ->(value:string, ok:err)

	Queries for a password. Accepts all alphanumeric characters and valid symbols
	Optional min_len and max_len forces the user to enter a string in those bounds.
	If show is true, prints '*' characters as user types password, otherwise the cursor doesn't move.

	Returns a string that the caller must free. .OK, .CANCEL or a .MIN_MAX error (if min_len is greater than max_len).

prompt.getch ::proc() ->(rune, err)
	
	Returns an immediate character rune, without waiting for enter to be pressed.
	Returns .OK, .KEY_UP


prompt.get_scan_code ::proc() ->(Scancode, err)

	Returns an immediate scan code (enum), without waiting for enter to be pressed.
	Returns .OK, .KEY_UP




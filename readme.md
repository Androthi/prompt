# Prompt package
## CLI helper functions for getting information from a user
	To use this package, first call init function

### prompt.init :: proc( use_prompt:string = def_prompt) ->err

	optional argument to change the prompt to anything you want, default is " :"

	Returns .OK or .INVALID_HANDLE

### get_number :: proc(message:string, min:int = 0, max:int=0) -> (value:int, ok:err)

	Queries for a number input. Number can be positive or negative 64 bit integer
	Optional min and max values, forces entry of numbers between min and max

	Returns value, .OK or .CANCEL or a .MIN_MAX error (if min is greater than max)

### get_option :: proc(message:string, options: ^[]option) -> (value:int, index:int)

	Queries for a response from a list of items. The ^[]option is an array of option
	structs, having key, value pairs.

	option :: struct {
		key		:string,
		value	:int,
	}

	Arrow keys are used to select an item and enter finalizes the choice. Current
	selection is highlited in green.
	
	Returns the value, and an index which can be used to retrieve the key.

### get_options :: proc(message:string, options: ^[]multi_option) -> (index:int)

	Lists options for the user to select from an array of multi-option structs.

	multi_option :: struct {
		option		:string,
		is_selected	:bool,
	}

	Arrow keys are used to move cursor up and down, space bar is used to select options.
	Selected options appear as "X" 

	On return, all the selected options are set to true


### get_password :: proc(message:string, min_len:int=0, max_len:int=0, show:bool=false) ->(value:string, ok:err)

	Queries for a password. Accepts all alphanumeric characters and valid symbols
	Optional min_len and max_len forces the user to enter a string in those bounds.
	If show is true, prints '*' characters as user types password, otherwise the cursor doesn't move.

	Returns a string that the caller must free. .OK, .CANCEL or a .MIN_MAX error (if min_len is greater than max_len).

### prompt.getch ::proc() ->(rune, err)
	
	Returns an immediate character rune, without waiting for enter to be pressed.
	Returns .OK, .KEY_UP


### prompt.get_scan_code ::proc() ->(Scancode, err)

	Returns an immediate scan code (enum), without waiting for enter to be pressed.
	Returns .OK, .KEY_UP


# Console package

console_info ::struct {
	hStdin	:w.HANDLE,
	hStdout	:w.HANDLE,
	scr_buf :w.CONSOLE_SCREEN_BUFFER_INFO,
}

### init :: proc() -> bool
	Sets up the console input and output handles

### flush :: proc( handle:w.HANDLE)
	Flushes the input or output handle passed as argument.

### get_cursor_pos :: proc() -> [2]i16
	returns cursor position in column, row format.

### get_console_key_event :: proc() -> console_key_event
	Returns a key event filled with the relavant information.

	console_key_event :: struct {
		char		:rune,
		scan_code	:u16,
		repeat_count:u16,
		is_key_down	:bool,
	}

	The scan_code can be cast to a Scancode enum type if you wish to use the
	incomplete Scancodes contained in the console package.

### scroll_down :: #force_inline proc (n:int)
	Scrolls the display. Note, cursor position will change.

### scroll_up :: #force_inline proc (n:int)
	Scrolls the display. Note, cursor position will change.

### cursor_up :: #force_inline proc (n:int)

### cursor_down :: #force_inline proc (n:int)

### cursor_up_lines :: #force_inline proc (n:int)

### cursor_down_lines :: #force_inline proc (n:int)

### cursor_forward :: #force_inline proc (n:int)

### cursor_back :: #force_inline proc (n:int)

### back_space :: #force_inline proc()

### delete_to_bol :: #force_inline proc ()
	Delets from cursor column position to beginning of line.

### delete_to_eol :: #force_inline proc ()
	Delets from cursor column position to end of line.

### delete_line :: #force_inline proc ()
	Delets the entire line regardless of cursor position.

### clear_screen	:: #force_inline proc()
	Clears the screen. Does no move cursor to home position.

### cursor_to :: #force_inline proc(column:i16 = 1, row:i16 = 1)
	Move the cursor to desired column, row.

### cursor_home	:: #force_inline proc()
	Moves the cursor to home position (column = row = 1)

### cls	:: #force_inline proc()
	Clears the screen and moves cursor to home position.

### cursor_to_column :: #force_inline proc(n:int)

### cursor_to_bol :: #force_inline proc()

### set_sgr_attribute ::#force_inline proc(attribute:string)
	Set a graphics attribute not covered by any other procedure.

### set_color_ansi ::#force_inline proc(color:string)
	Set the text color to one of the FG_XXX or BG_XXX color enums from the ansi package.

### reset ::#force_inline proc()
	Resets all graphics attributes

### show_cursor :: #force_inline proc()

### hide_cursor :: #force_inline proc()

### set_forground_color8 :: #force_inline proc(color:u8)

### set_background_color8 :: #force_inline proc(color:u8)

### set_forground_color24 :: #force_inline proc(r,g,b:u8)

### set_background_color24 :: #force_inline proc(r,g,b:u8)

### set_underline :: #force_inline proc()
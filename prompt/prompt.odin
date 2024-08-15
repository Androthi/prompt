package prompt

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import w "core:sys/windows"
import con "../console"
import ansi "core:encoding/ansi"

option :: struct {
	key		:string,
	value	:int, // TODO: this should be generic?
}

err	:: enum {
	OK = 1,
	CANCEL,
	INVALID_HANDLE,
	CONSOLE_MODE,
	MIN_MAX,
  KEY_UP,
}

def_prompt :: " :"
prompt : string = def_prompt
prompt_cursor_pos :[2]i16
cursor_pos        :[2]i16

init :: proc( use_prompt:string = def_prompt) ->err {
  
  if ok:= con.init(); !ok do return .INVALID_HANDLE
	prompt = use_prompt
	return .OK
}

get_options :: proc(message:string, options: ^[]option) -> (value:int, index:int) {
	
	update_options :: proc(index:int, options:^[]option) {
    
    cursor_pos = prompt_cursor_pos
    cursor_pos.y += 1
    num_options := len(options)
		for i in 0..<num_options {
			cursor_pos.y += 1
      con.cursor_to(0, cursor_pos.y)
      if i == index do con.set_color_ansi(ansi.FG_GREEN)
			fmt.print(prompt, options[i].key)
			con.reset()
		}
    con.reset()
  }

	value = 0
	index = 0
	num_options := len(options)
	if num_options == 0 do return

	// make space below for printing the options and the prompt
	line_feed(num_options+1)
  cursor_pos = con.get_cursor_pos()
  con.cursor_to( 0, cursor_pos.y - i16(num_options+1))

	fmt.print(message, prompt, "")
  prompt_cursor_pos = con.get_cursor_pos()	

  con.hide_cursor()
  defer con.show_cursor()
  update_options(index, options)

	myfor:for {
		
		scan_code, ok := get_scan_code()
		if ok == .KEY_UP do	continue

		#partial switch scan_code {
			case .num_8: // up
			if index > 0 do index -= 1
			
			case .num_2: // down
			if index < num_options-1 do index += 1
			
			case .enter:
				value = options[index].value
        con.cursor_to(prompt_cursor_pos.x, prompt_cursor_pos.y+1)
        fmt.print(options[index].key)
				break myfor
			}

			update_options(index, options)
    }

    // scroll below the options to continue
    for i in 0..=num_options {
      fmt.println()
    }

	return
}

line_feed :: #force_inline proc(n:int) { for i:=0; i<n; i+=1 do fmt.println() }

// caller must free returned string
get_password :: proc(message:string, min_len:int=0, max_len:int=0, show:bool=false) ->(value:string, ok:err) {

	if min_len > max_len do return "", .MIN_MAX
	ok = .OK
	str: strings.Builder
	defer strings.builder_destroy(&str)
	strings.builder_init(&str, 0, 50)
	fmt.print(message, prompt, "")
	prompt_cursor_pos = con.get_cursor_pos()
	cursor_pos = prompt_cursor_pos
	// make room for error message under prompt
	con.scroll_up(1)
	input_char :rune
	strbuf	:[300]u8

	if !show {
		
		con.hide_cursor()
		defer con.show_cursor()
	 }
		myfor:for {
			con.cursor_to(cursor_pos.x, cursor_pos.y)
			input_char, ok = getch()
    if ok == .KEY_UP do continue
		switch input_char {
			case rune(ascii.ENTER):
				print_error("")
				
				strlen := strings.builder_len(str)
				if strlen == 0 {
					ok = .CANCEL
					break myfor
				}

				if min_len > 0 && strlen < min_len {
					print_error(fmt.bprintf(strbuf[:], "Length of password must be at least %v characters", min_len))
					continue
				}

				if max_len > 0 && strlen > max_len {
					print_error(fmt.bprintf(strbuf[:], "Length of password must not exceed %v characters", max_len))
					continue
				}
				
				break myfor
						
			case rune(ascii.BACKSPACE):
				if strings.builder_len(str) > 0 {
					strings.pop_rune(&str)
					if show {
						con.back_space()
          	cursor_pos.x -= 1
					}
				}
				print_error("")

			case 32..=126:
				if show {
					fmt.print("*")
					cursor_pos.x += 1
				}

				strings.write_rune(&str, input_char)
				print_error("")

			case: 
				// ignore modifier keys
				continue
		}
	}

	return strings.clone(strings.to_string(str)), ok
}

get_number :: proc(message:string, min:int = 0, max:int=0) -> (value:int, ok:err) {
	
	if min > max do return 0, .MIN_MAX
	ok = .OK
	str :strings.Builder
	defer strings.builder_destroy(&str)
	strings.builder_init(&str, 0, 50)
	fmt.print(message, prompt, "")

  prompt_cursor_pos = con.get_cursor_pos()
  cursor_pos = prompt_cursor_pos
 	// make sure there is an empty line below the current cursor for error information
	con.scroll_up(1)
	
	strbuf	:[300]u8
	input_char :rune

	myfor:for {
    con.cursor_to(cursor_pos.x, cursor_pos.y)
    input_char, ok = getch()
    if ok == .KEY_UP do continue
		switch input_char {
			case rune(ascii.ENTER):
				print_error("")
				if strings.builder_len(str) == 0 {
					ok = .CANCEL
					break myfor
				}

				value= strconv.atoi(strings.trim_null(strings.to_string(str)))
				if min == 0 && max == 0 do break myfor
				
				// this format doesn't allow for only a min value or only a max value.
				// it's both or nothing.
				if value > max || value < min {
					print_error(fmt.bprintf(strbuf[:], "Number must be between %v and %v", min, max))
					continue
				}
				break myfor
				
			case '0'..='9':
				
				// need to add error checking to
				// not exceed maximum digits of int
				fmt.print(input_char)
				strings.write_rune(&str, input_char)
        cursor_pos.x += 1
				print_error("")
			
			case rune(ascii.MINUS):
				if strings.builder_len(str) > 0 {
					print_error("'-' can only be used as a prefix to a number")
					continue
				}
				
				fmt.print(input_char)
				strings.write_rune(&str, input_char)
        cursor_pos.x += 1
        print_error("")

			case rune(ascii.BACKSPACE):
				if strings.builder_len(str) > 0 {
					strings.pop_rune(&str)
					con.back_space()
          cursor_pos.x -= 1
				}
				print_error("")

			case: //not valid
				print_error("")
				if min >0 {
					print_error(fmt.bprintf(strbuf[:], "Enter a number between %v and %v", min, max))
				} else {
					print_error("Enter a valid possitive or negative number")
				}
				continue
		}
	}
	return value, ok
}

@(private)
print_error ::proc(message:string) {

	@static last_len := 0
  save_cursor := cursor_pos
  con.set_color_ansi(ansi.FG_RED)
  con.cursor_to(0, save_cursor.y+1)
	
	if last_len > 0 {
    con.delete_line()
    last_len = 0
	}	
	
	fmt.print(message)
	last_len = len(message)
	con.reset()
}


get_scan_code ::proc() ->(con.Scancode, err) {
	key := con.get_console_key_event()
	if !key.is_key_down do return con.Scancode(key.scan_code), .KEY_UP
	return con.Scancode(key.scan_code), .OK
}

getch ::proc() ->(rune, err) {
	key := con.get_console_key_event()
	if !key.is_key_down do return key.char, .KEY_UP
	return key.char, .OK
}

ascii :: enum u8 {
  NUL  = 0,  // Null character
  SOH  = 1,  // Start of Heading
  STX  = 2,  // Start of Text
  ETX  = 3,  // End of Text
  EOT  = 4,  // End of Transmission
  ENQ  = 5,  // Enquiry
  ACK  = 6,  // Acknowledge
  BEL  = 7,  // Bell
  BACKSPACE   = 8,  // Backspace
  TAB  = 9,  // Horizontal Tab
  LF   = 10, // Line Feed
  VT   = 11, // Vertical Tab
  FF   = 12, // Form Feed
  ENTER   = 13, // Carriage Return
  SO   = 14, // Shift Out
  SI   = 15, // Shift In
  DLE  = 16, // Data Link Escape
  DC1  = 17, // Device Control One (XON)
  DC2  = 18, // Device Control Two
  DC3  = 19, // Device Control Three (XOFF)
  DC4  = 20, // Device Control Four
  NACK = 21, // Negative Acknowledge
  SYN  = 22, // Synchronous Idle
  ETB  = 23, // End of Transmission Block
  CAN  = 24, // Cancel
  EM   = 25, // End of medium
  SUB  = 26, // Substitute
  ESC  = 27, // Escape
  FS   = 28, // File Separator
  GS   = 29, // Group Separator
  RS   = 30, // Record Separator
  US   = 31, // Unit Separator
MINUS= 45,
}


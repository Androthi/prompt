package prompt

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import w "core:sys/windows"


hStdin  : w.HANDLE
hStdout	: w.HANDLE
rec_buf	:w.INPUT_RECORD

def_prompt :: " :"

err	:: enum {
	OK = 1,
	CANCEL,
	INVALID_HANDLE,
	CONSOLE_MODE,
	MIN_MAX,
  NO_KEY,
}

// maybe switch to a type... do we need more than one of these?
console_info ::struct {
  hStdin	:w.HANDLE,
	hStdout	:w.HANDLE,
	prompt	:string,
	scr_buf :w.CONSOLE_SCREEN_BUFFER_INFO,
}
c_info :console_info

init :: proc( use_prompt:string = def_prompt) ->err {
  
	c_info.hStdin = w.GetStdHandle(w.STD_INPUT_HANDLE)
	if c_info.hStdin == w.INVALID_HANDLE do return .INVALID_HANDLE
	c_info.hStdout = w.GetStdHandle(w.STD_OUTPUT_HANDLE)
	if c_info.hStdout == w.INVALID_HANDLE do return .INVALID_HANDLE
	c_info.prompt = use_prompt

	// don't need these yet. 
	//if ! w.GetConsoleMode(hStdin, &old_mode) do return .CONSOLE_MODE
	w.FlushConsoleInputBuffer(c_info.hStdin)
	w.FlushConsoleInputBuffer(c_info.hStdout)
	return .OK
}

getch ::proc() ->(char:rune, ok:err) {
	num_read	:u32
  ok = .OK
	for {
		if w.PeekConsoleInputW(c_info.hStdin, &rec_buf, 1, &num_read) {
			w.ReadConsoleInputW(
				c_info.hStdin,
				&rec_buf, 1,
				&num_read)
					if rec_buf.Event.KeyEvent.bKeyDown {
            char = rune(rec_buf.Event.KeyEvent.uChar.UnicodeChar)
          } else {
            ok = .NO_KEY
          }
				break
		}
	}
	w.FlushConsoleInputBuffer(c_info.hStdin)
	return char, ok
}

@(private)
print_error ::proc(message:string) {

	@static last_len := 0
	w.GetConsoleScreenBufferInfo(c_info.hStdout,&c_info.scr_buf)
	w.SetConsoleTextAttribute(c_info.hStdout, w.FOREGROUND_RED)
	w.SetConsoleCursorPosition(c_info.hStdout, {0, c_info.scr_buf.dwCursorPosition.Y+1})
	
	if last_len > 0 {
		for x:=0; x < last_len; x+=1 {
			fmt.print(' ')
		}
		last_len = 0
	}	
	
	fmt.print(message)
	last_len = len(message)
	w.SetConsoleTextAttribute(c_info.hStdout, c_info.scr_buf.wAttributes)
	w.SetConsoleCursorPosition(c_info.hStdout, { c_info.scr_buf.dwCursorPosition.X, c_info.scr_buf.dwCursorPosition.Y})
}

get_number :: proc(message:string, min:int = 0, max:int=0) -> (ret_val:int, ok:err) {
	
	if min > max do return 0, .MIN_MAX
	
	ok = .OK
	str :strings.Builder
	defer strings.builder_destroy(&str)
	strings.builder_init(&str, 0, 50)
	fmt.print(message, c_info.prompt)
	min := min
	max := max
	w.GetConsoleScreenBufferInfo(c_info.hStdout,&c_info.scr_buf)
	current_index := c_info.scr_buf.dwCursorPosition
	// make sure there is an empty line below the current cursor for error information
	fmt.println()
	current_index.Y -= 1

	strbuf	:[300]u8
	input_char :rune

	myfor:for {
		w.SetConsoleCursorPosition(c_info.hStdout, {current_index.X, current_index.Y})
		input_char, ok = getch()
    if ok == .NO_KEY do continue
		switch input_char {
			case rune(ascii.ENTER):
				print_error("")
				if strings.builder_len(str) == 0 {
					ok = .CANCEL
					break myfor
				}

				ret_val= strconv.atoi(strings.trim_null(strings.to_string(str)))
				if max > 0 {
					if ret_val < min || ret_val > max{
						print_error(fmt.bprintf(strbuf[:], "Number must be between %v and %v", min, max))
						continue
					}
				}
        ok = .OK
				break myfor
				
			case '0'..='9':
				
				// need to add error checking to
				// not exceed maximum digits of int
				fmt.print(input_char)
				strings.write_rune(&str, input_char)
				current_index.X += 1
				print_error("")
			
			case rune(ascii.MINUS):
				if strings.builder_len(str) > 0 {
					print_error("'-' can only be used as a prefix to a number")
					continue
				}
				
				fmt.print(input_char)
				strings.write_rune(&str, input_char)
				current_index.X += 1
				print_error("")

			case rune(ascii.BACKSPACE):
				if strings.builder_len(str) > 0 {
					strings.pop_rune(&str)
					//w.SetConsoleCursorPosition(hStdout, {current_index.X-1, current_index.Y})
					w.SetConsoleCursorPosition(c_info.hStdout, {current_index.X-1, current_index.Y})
					fmt.print(' ')
					current_index.X-=1
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
	return ret_val, ok
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

/*
Scancode :: enum {
	
		unknown = 0x00,
    escape = 0x01,    
		one = 0x02,
    two = 0x03,
    three = 0x04,
    four = 0x05,
    five = 0x06,
    six = 0x07,
    seven = 0x08,
    eight = 0x09,
    nine = 0x0A,
    ten = 0x0B,
    minus = 0x0C,
    equals = 0x0D,
    backspace = 0x0E,
    tab = 0x0F,
    q = 0x10,
    w = 0x11,
    e = 0x12,
    r = 0x13,
    t = 0x14,
    y = 0x15,
    u = 0x16,
    i = 0x17,
    o = 0x18,
    p = 0x19,
    bracket_left = 0x1A,
    bracket_right = 0x1B,
    enter = 0x1C,
    control_left = 0x1D,
    a = 0x1E,
    s =0x1F,
    d = 0x20,
    f = 0x21,
    g = 0x22,
    h = 0x23,
    j = 0x24,
    k = 0x25,
    l = 0x26,
    semicolon = 0x27,
    apostrophe = 0x28,
    grave = 0x29,
    shift_left = 0x2A,
    backslash = 0x2B,
    z = 0x2C,
    x = 0x2D,
    c = 0x2E,
    v = 0x2F,
    b = 0x30,
    n = 0x31,
    m = 0x32,
    comma = 0x33,
    preiod = 0x34,
    slash = 0x35,
    shift_right = 0x36,
    num_multiply = 0x37,
    alt_left = 0x38,
    space = 0x39,
    capsLock = 0x3A,
    f1 = 0x3B,
    f2 = 0x3C,
    f3 = 0x3D,
    f4 = 0x3E,
    f5 = 0x3F,
    f6 = 0x40,
    f7 = 0x41,
    f8 = 0x42,
    f9 = 0x43,
    f10 = 0x44,
    num_lock = 0x45,
    scroll_lock = 0x46,
    num_7 = 0x47,
    num_8 = 0x48,
    num_9 = 0x49,
    num_minus = 0x4A,
    num_4 = 0x4B,
    num_5 = 0x4C,
    num_6 = 0x4D,
    num_plus = 0x4E,
    num_1 = 0x4F,
    num_2 = 0x50,
    num_3 = 0x51,
    num_0 = 0x52,
    num_period = 0x53,
    alt_print_screen = 0x54, /* Alt + print screen. MapVirtualKeyEx( VK_SNAPSHOT, MAPVK_VK_TO_VEX, 0 ) returns scancode 0x54. */
    bracket_angle = 0x56, /* Key between the left shift and Z. */
    f11 = 0x57,
    f12 = 0x58,
    oem_1 = 0x5a, /* VK_OEM_WSCTRL */
    oem_2 = 0x5b, /* VK_OEM_FINISH */
    oem_3 = 0x5c, /* VK_OEM_JUMP */
    erase_EOF = 0x5d,
    oem_4 = 0x5e, /* VK_OEM_BACKTAB */
    oem_5 = 0x5f, /* VK_OEM_AUTO */
    zoom = 0x62,
    help = 0x63,
    f13 = 0x64,
    f14 = 0x65,
    f15 = 0x66,
    f16 = 0x67,
    f17 = 0x68,
    f18 = 0x69,
    f19 = 0x6a,
    f20 = 0x6b,
    f21 = 0x6c,
    f22 = 0x6d,
    f23 = 0x6e,
    oem_6 = 0x6f, /* VK_OEM_PA3 */
    katakana = 0x70,
    oem_7 = 0x71, /* VK_OEM_RESET */
    f24 = 0x76,
    sbcschar = 0x77,
    convert = 0x79,
    nonconvert = 0x7B, /* VK_OEM_PA1 */

    media_previous = 0xE010,
    media_next = 0xE019,
    num_enter = 0xE01C,
    control_right = 0xE01D,
    volume_mute = 0xE020,
    launch_app2 = 0xE021,
    media_play = 0xE022,
    media_stop = 0xE024,
    volume_down = 0xE02E,
    volume_up = 0xE030,
    browser_home = 0xE032,
    num_divide = 0xE035,
    print_screen = 0xE037,
    alt_right = 0xE038,
    cancel = 0xE046, /* CTRL + Pause */
    home = 0xE047,
    arrow_up = 0xE048,
    page_up = 0xE049,
    arrow_left = 0xE04B,
    arrow_right = 0xE04D,
    end = 0xE04F,
    arrow_down = 0xE050,
    page_down = 0xE051,
    insert = 0xE052,
    delete = 0xE053,
    meta_left = 0xE05B,
    meta_right = 0xE05C,
    application = 0xE05D,
    power = 0xE05E,
    sleep = 0xE05F,
    wake = 0xE063,
    browser_search = 0xE065,
    browser_favorites = 0xE066,
    browser_refresh = 0xE067,
    browser_stop = 0xE068,
    browser_forward = 0xE069,
    browser_back = 0xE06A,
    launch_app1 = 0xE06B,
    launch_email = 0xE06C,
    launch_media = 0xE06D,

    pause = 0xE11D45,
    /*
    pause:
    - make: 0xE11D 45 0xE19D C5
    - make in raw input: 0xE11D 0x45
		- break: none
    - No repeat when you hold the key down
    - There are no break so I don't know how the key down/up is expected to work. Raw input sends "keydown" and "keyup" messages, and it appears that the keyup message is sent directly after the keydown message (you can't hold the key down) so depending on when GetMessage or PeekMessage will return messages, you may get both a keydown and keyup message "at the same time". If you use VK messages most of the time you only get keydown messages, but some times you get keyup messages too.
    - when pressed at the same time as one or both control keys, generates a 0xE046 (cancel) and the string for that scancode is "break".
    */
}
*/

package console

import w "core:sys/windows"
import "core:fmt"
import "core:encoding/ansi"

// maybe switch to a type... do we need more than one of these?
console_info ::struct {
	hStdin	:w.HANDLE,
	hStdout	:w.HANDLE,
	scr_buf :w.CONSOLE_SCREEN_BUFFER_INFO,
}

@(private)
info :console_info

console_key_event :: struct {
	char		:rune,
	scan_code	:u16,
	repeat_count:u16,
	is_key_down	:bool,
}

// needs linux version
init :: proc() -> bool{
    
    info.hStdin = w.GetStdHandle(w.STD_INPUT_HANDLE)
	if info.hStdin == w.INVALID_HANDLE do return false
	info.hStdout = w.GetStdHandle(w.STD_OUTPUT_HANDLE)
	if info.hStdout == w.INVALID_HANDLE do return false
	
    flush(info.hStdin)
    flush(info.hStdout)

    return true
}

// need linux version
flush :: proc( handle:w.HANDLE) {
    w.FlushConsoleInputBuffer(handle)
}

get_cursor_pos :: proc() -> [2]i16 {
	w.GetConsoleScreenBufferInfo(info.hStdout, &info.scr_buf)
    return { info.scr_buf.dwCursorPosition.X, info.scr_buf.dwCursorPosition.Y }
}

// needs linux version
get_console_key_event :: proc() -> console_key_event {
	num_read	:u32
	rec_buf	:w.INPUT_RECORD

	for {
		if w.PeekConsoleInputW(info.hStdin, &rec_buf, 1, &num_read) {
			w.ReadConsoleInputW(info.hStdin, &rec_buf, 1,	&num_read)
			if rec_buf.EventType != .KEY_EVENT do continue
			break
		}
	}
	return console_key_event{
		char = rune(rec_buf.Event.KeyEvent.uChar.UnicodeChar),
		scan_code = rec_buf.Event.KeyEvent.wVirtualScanCode,

        repeat_count = rec_buf.Event.KeyEvent.wRepeatCount,
		is_key_down = bool(rec_buf.Event.KeyEvent.bKeyDown),
	}
}

// scroll up and scroll down mess with the cursor position 
scroll_down :: #force_inline proc (n:int) {
	fmt.printf("%s%v%s", ansi.CSI, n, ansi.SD )
}

// scroll up and scroll down mess with the cursor position
scroll_up :: #force_inline proc (n:int) {
	fmt.printf("%s%v%s", ansi.CSI, n, ansi.SU )
}

cursor_up :: #force_inline proc (n:int) {
	fmt.printf("%s%v%s", ansi.CSI, n, ansi.CUU )
}

cursor_down :: #force_inline proc (n:int) {
	fmt.printf("%s%v%s", ansi.CSI, n, ansi.CUD )
}

cursor_up_lines :: #force_inline proc (n:int) {
	fmt.printf("%s%v%s", ansi.CSI, n, ansi.CPL )
}

cursor_down_lines :: #force_inline proc (n:int) {
	fmt.printf("%s%v%s", ansi.CSI, n, ansi.CNL )
}

cursor_forward :: #force_inline proc (n:int) {
	fmt.printf("%s%v%s", ansi.CSI, n, ansi.CUF )
}

cursor_back :: #force_inline proc (n:int) {
	fmt.printf("%s%v%s", ansi.CSI, n, ansi.CUB )
}

back_space :: #force_inline proc() {
	cursor_back(1)
	fmt.printf(" ")
	cursor_back(1)
}

delete_to_bol :: #force_inline proc () {
	fmt.printf("%s1%s", ansi.CSI, ansi.EL)
}

delete_to_eol :: #force_inline proc () {
	fmt.printf("%s0%s", ansi.CSI, ansi.EL)
}

delete_line :: #force_inline proc () {
	fmt.printf("%s2%s", ansi.CSI, ansi.EL)
}

// 2 = entire display
// 0 = cursor to end of screen
// 1 = cursor to beginning of screen
clear_screen	:: #force_inline proc() {
	fmt.printf("%s2%s", ansi.CSI, ansi.ED)
}

cursor_to :: #force_inline proc(column:i16 = 1, row:i16 = 1) {
	fmt.printf("%s%v;%v%s", ansi.CSI, row, column, ansi.CUP)
}

cursor_home	:: #force_inline proc() {
	cursor_to()
}

cls	:: #force_inline proc() {
	clear_screen()
	cursor_home()
}

cursor_to_column :: #force_inline proc(n:int) {
	fmt.printf("%s%v%s", ansi.CSI, n, ansi.CHA )
}

cursor_to_bol :: #force_inline proc() {
	cursor_to_column(1)
}

set_sgr_attribute ::#force_inline proc(attribute:string) {
	// setting bold, italic, colors, etc.
	fmt.printf("%s%s%s", ansi.CSI, attribute, ansi.SGR)
}

set_color_ansi ::#force_inline proc(color:string) {
	set_sgr_attribute(color)
}

reset ::#force_inline proc() {
	set_sgr_attribute(ansi.RESET)
}

show_cursor :: #force_inline proc() {
	fmt.printf("%s%s", ansi.CSI, ansi.DECTCEM_SHOW)
}

hide_cursor :: #force_inline proc() {
	fmt.printf("%s%s", ansi.CSI, ansi.DECTCEM_HIDE)
}

set_forground_color8 :: #force_inline proc(color:u8) {
	fmt.printf("%s%s;%v%s", ansi.CSI, ansi.FG_COLOR_8_BIT, color, ansi.SGR)
}

set_background_color8 :: #force_inline proc(color:u8) {
	fmt.printf("%s%s;%v%s", ansi.CSI, ansi.BG_COLOR_8_BIT, color, ansi.SGR)
}

set_forground_color24 :: #force_inline proc(r,g,b:u8) {
	fmt.printf("%s%s;%v;%v;%v%s", ansi.CSI, ansi.FG_COLOR_24_BIT, r, g, b, ansi.SGR)
}

set_background_color24 :: #force_inline proc(r,g,b:u8) {
	fmt.printf("%s%s;%v;%v;%v%s", ansi.CSI, ansi.BG_COLOR_24_BIT, r, g, b, ansi.SGR)
}

Scancode :: enum u16 {
	
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

//pause = 0xE11D45,
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

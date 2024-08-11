// example using the prompt.odin package

package main

import "core:fmt"
import p "prompt"
import "core:encoding/ansi"
import "core:strings"

colors := []p.option{
	{"Red",    0x00_FF_00_00},
	{"Green",  0x00_00_FF_00},
	{"Blue",   0x00_00_00_FF},
}

scroll_down :: #force_inline proc (n:int) {
	fmt.printf("%s%v%s", ansi.CSI, n, ansi.SD )
}

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

cursor_to :: #force_inline proc(x:int = 1, y:int = 1) {
	fmt.printf("%s%v;%v%s", ansi.CSI, x, y, ansi.CUP)
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

main :: proc (){
	
	ok:p.err
	num :int

	cls()
	set_color_ansi(ansi.FG_CYAN)
	fmt.print("Hellope")
	reset()
	cursor_back(3)
	delete_to_bol()
	cursor_to_bol()
	fmt.print("\n\n")
	cursor_to(10,10)
	set_background_color8(60)
	set_forground_color24(0, 255, 0)
	fmt.print("here?")
	reset()

	/*
	//	fmt.print("?")
	ok = p.init("->")
	if ok != .OK do fmt.println("error: ", ok)

	num, ok = p.get_number("\n\n\nEnter a number") 
	if ok == .OK do fmt.println("\nEntered->", num)

	num, ok = p.get_number("\nEnter a number between 10 and 20", 10, 20)
	if ok == .OK do fmt.println("\nEntered->", num)
	fmt.println()

	value, index:= p.get_options("\nPick a Color", &colors)
	fmt.println("selected", colors[index].key, "with value of ", value)
*/
}
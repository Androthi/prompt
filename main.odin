// example using the prompt.odin package

package main

import "core:fmt"
import p "prompt"
import con "console"
import "core:strings"
import "core:encoding/ansi"

colors := []p.option{
	{"Red",    0x00_FF_00_00},
	{"Green",  0x00_00_FF_00},
	{"Blue",   0x00_00_00_FF},
}

main :: proc (){
	
	ok:p.err
	num :int
/*
	con.cls()
	con.set_color_ansi(ansi.FG_CYAN)
	fmt.print("Hellope")
	con.reset()
	con.cursor_back(3)
	con.delete_to_bol()
	con.cursor_to_bol()
	fmt.print("\n\n")
	con.cursor_to(10,10)
	con.set_background_color8(60)
	con.set_forground_color24(0, 255, 0)
	fmt.println("green")
	con.reset()
	fmt.println()
*/	
	//con.init()
	//con.cls()
/*
	fmt.print("\n\n     :")
	pos := con.get_cursor_pos()
	fmt.print("cursor :", pos.x," : ", pos.y)
	con.cursor_to(pos.x, pos.y)
	fmt.print("]")
*/
	ok = p.init("->")
	if ok != .OK do fmt.println("error: ", ok)

	num, ok = p.get_number("\n\n\nEnter a number") 
	if ok == .OK do fmt.println("\nEntered->", num)

	num, ok = p.get_number("\nEnter a number between 10 and 20", 10, 20)
	if ok == .OK do fmt.println("\nEntered->", num)
	fmt.println()

	value, index:= p.get_options("\nPick a Color", &colors)
	fmt.println("selected", colors[index].key, "with value of ", value)
	
}
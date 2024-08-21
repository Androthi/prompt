// example using the prompt.odin package

package main

import "core:fmt"
import p "prompt"
import con "console"
import "core:strings"
import "core:encoding/ansi"

colors := []p.option(u32) {
	{"Red",    0x00_FF_00_00},
	{"Green",  0x00_00_FF_00},
	{"Blue",   0x00_00_00_FF},
}



f:: false
options	:= []p.multi_option {
	{"Mix the Fludgebar", f},
	{"Sanitize Pliffle Balls", f},
	{"Polish the Florp Bucket", f},
	{"Straighten Mugglewart", true}, // we can set initial setting to true
	{"Defizzle Buckwarden", f},
}

main :: proc (){
	
	ok:p.err
	num :int
	str :string
	
	con.init()
	con.cls()
	sz := con.get_screen_size()
	con.write_text("Hellope", (sz.x-(len("Hellope"))/2)/2, sz.y/2, u8(10), u8(22))
	fmt.println("\n")
	/*
	con.init()
	con.cls()
	sz := con.get_screen_size()
	con.write_text("message", (sz.x-(len("message"))/2)/2, sz.y/2, u8(100), u8(200))
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

ok = p.init("->")
	if ok != .OK do fmt.println("error: ", ok)

	num, ok = p.get_number("\n\n\nEnter a number") 
	if ok == .OK do fmt.println("\nEntered->", num)

	num, ok = p.get_number("\nEnter a number between 10 and 20", 10, 20)
	if ok == .OK do fmt.println("\nEntered->", num)
	fmt.println()
	

	value, index:= p.get_option("\nPick a Color", &colors)
	fmt.println("selected", colors[index].key, "with value of ", value)

	str, ok = p.get_password("Enter a password ", 6, 10, true)
	if ok == .OK do fmt.println("\nEntered->", str)

	str, ok = p.get_password("Enter a password ")
	if ok == .OK do fmt.println("\nEntered->", str)

	p.get_options("\nSelect all that apply", &options )
	for i := 0; i < len(options); i +=1 {
		if options[i].is_selected {
			fmt.println( options[i].option, " is selected")
		} else do fmt.println(options[i].option, " is not selected")
	}
}
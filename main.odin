// example using the prompt.odin package

package main

import "core:fmt"
import p "prompt"

colors := []p.option{
  {"Red",    0x00_FF_00_00},
  {"Green",  0x00_00_FF_00},
  {"Blue",   0x00_00_00_FF},
}

main :: proc (){
	
  ok:p.err
  num :int

  ok = p.init("->")
  if ok != .OK do fmt.println("error: ", ok)

  num, ok = p.get_number("\n\n\nEnter a number") 
  if ok == .OK do fmt.println("\nEntered->", num)
  fmt.println()

  num, ok = p.get_number("Enter a number between 10 and 20", -19, 0)
  if ok == .OK do fmt.println("\nEntered->", num)
  fmt.println()

  value, index:= p.get_options("\nPick a Color", &colors)
  fmt.println("selected ", colors[index].key, " with value of ", value)

}
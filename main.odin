package main

import "core:fmt"
import c "core:c/libc"
import p "prompt"

main :: proc (){
	
  ok:p.err
  num :int
  ok = p.init("->")
  if ok != .OK do fmt.println("error: ", ok)
	
  c.system("@cls||clear")

  
  num, ok = p.get_number("Enter a number") 
  if ok == .OK do fmt.println("\nEntered->", num)
  fmt.println()
  num, ok = p.get_number("Enter a number between 10 and 20", 10, 20)
  if ok == .OK do fmt.println("\nEntered->", num)
}
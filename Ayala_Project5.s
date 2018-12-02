.data                                                                                           #Section holding data that the program will use
records: .space 480                                                                             #Space allocated for the array that will hold the arrray of records
recordsSpace: .word 480                                                                         #The size of bytes allocated for the array holding the records
recordBitSize: .word 48                                                                         #The size of bytes for a single record
recordsSize: .word 10                                                                           #The ammount or records held in the array
menu: .asciiz "\nMenu\n1) Swap two records.\n2) Exit\nPlease choose one of the above options: " #Menu informing user of operation options
firstRecordPrompt: .asciiz "Which record do you select first? "                                 #String prompting user for first record to swap
secondRecordPrompt: .asciiz "Which record do you want to swap it with? "                        #String prompting user for the second record to swap first record with
recordString: .asciiz "Record "                                                                 #String containing the string "Record"
newLine: .byte '\n'                                                                             #Character representing a new line to print a new line and also used to remove new lines from the array


.text 	                                        #Section of the program holding the instructions to run the program
	                                                
main:											#Main function that will hold the loop that runs the program
	lw $s5, recordBitSize                       #Loading the size of bytes for a single record
	lw $s6, recordsSpace                        #Loading the amount bytes allocated for the array holding the records
	lw $s7, recordsSize                         #Loading the size of amount of records in array
	
	jal FillArray                               #Jumping to function responsible for initially filling the array
	addi $0, $0, 0                              #No-Op instruction
	
	jal Print                                   #Jumping to function responsible for printing the array
	addi $0, $0, 0                              #No-Op instruction
	
	menu_loop:                                  #Loop that will run the program until the user exits
		li $v0, 4                               #Loading syscall to print a string
		la $a0, menu                            #Loading the menu string to be printed
		syscall                                 #Prints the menu
	
		li $v0,5                                #Loads syscall to read a integer
		syscall                                 #Reads an integer from the user
	
		beq $v0, 1, jumpToSwap                  #If user enters 1, program jumps to the swap fucntion
		beq $v0, 2, jumpToExit                  #If user enters 2, program jumps to the exit program function
		
	jumpToSwap:                                 #Part of program that will ask user for which records to swap
		li $v0, 4                               #Loads syscall to print a string
		la $a0, firstRecordPrompt               #Loads the string prompting the user for the first record to swap
		syscall                                 #Prints the first record swap string
			
		li $v0, 5                               #Loads syscall to read an integer
		syscall                                 #Reads input from the user
		sub $a1,$v0, 1                          #Subtracts 1 from user input for calulating the record address and loading it into a parameter register
			
		li $v0, 4                               #Loads syscall to print a string
		la $a0, secondRecordPrompt              #Loads String that prompts user for second record to swap
		syscall                                 #Prints the second recrod swap string
			
		li $v0, 5                               #Loads syscall to read an integer from user
		syscall                                 #Reads intreger from the user
		sub $a2,$v0, 1                          #Subtracts 1 from user input for calulating the record address and loading it into a parameter register
			    	
		jal Swap                                #Jumps and links to the function that will swap records
		addi $0, $0, 0                          #No-Op
		jal Print                               #Jumps and links to the function that prints the array to the user
		addi $0, $0, 0                          #No-Op
		
		b menu_loop                             #Branching back to the menu loop to create a loop that will run the program
			    
	jumpToExit: 
		jal Exit                                #Jumps to the fucntion that exits and ends the program
	
	
	
	
###################################################################################################################################################################	
	
FillArray:                                      #Fucntion that initially fills the array
	li $t0, 0                                   #Array adress pointer
	li $t1, 0                                   #Loop counter
	
	fill_loop:                                  #Loop that fills the array
	
		beq $t1,$s7,removeLine                  #Once array is filled, Program will remove the new lines that are read when the suer ends a string
	
		li $v0, 8                               #Loads syscall to read a string from user
		la $a0, records($t0)                    #Address where the read string will be loaded
		li $a1, 40                              #String can only be 40 bytes in length
		syscall                                 #Reads string from the user
	
		addi $t0,$t0, 40                        #Adds 40 to the address pointer 
	
		li $v0, 5                               #loads syscall to read integer
		syscall                                 #reads integer from user
		sw $v0, records($t0)                    #Saves the read integer into the array
	
		addi $t0,$t0, 4                         #Adds 4 to the array address pointer
	
		li $v0, 5                               #loads syscall to read integer
		syscall                                 #reads integer from user
		sw $v0, records($t0)                    #Saves the read integer into the array
	
		addi $t0,$t0, 4                         #Adds 4 to the array address pointer
		addi $t1, $t1, 1                        #Adds 1 to the loop counter
		
		b fill_loop                             #branches back to the loop that fills the array
	
	removeLine:                                 #Removes new line that is saved when user enters a string
		li $t0, 0                               #Address pointer
		li $t1, 0                               #Checking if equal
		lb $t2, newLine                         #character represeting a new line
		li $t3, 0                               #byte holder
		
		searchLoop:                             #Seaches through the whole array
	
			beq $t0,$s6,endFill             	#Once array is searched, finish ending
			lb $t3, records($t0)            	#Loads current byte into byte hodler register
			seq $t1,$t3,$t2                 	#Checks if bytes are equal
			bgt $t1,0,change                	#If there is a new line, it will be changed
			addi $t0, $t0, 1                	#Adds 1 to the address pointer
			
			b searchLoop                    	#Branches to the search looop
	
	change:                                     #Chages new line to 0
		sb $0, records($t0)                     #Saves 0 to address where new line is
		b searchLoop                            #Branches back to the search loop
	
	endFill:                                    #Ending the filling function
		jr $ra                                  #Jumps back to the linked instruction from which the program jumped from

	
##################################################################################################################################################		
			
				
				
Print:                                          #Fucntion that prings the array		
	
	li $t0, 0                                   #address pointer
	li $t1, 0                                   #loop counter
	li $t2, 1                                   #Print record integer
	
	print_loop:                                 #Loop that will print the array
		beq $t1, $s7, endPrint                  #End printing once whole array is prt=inted
	
	
		li $v0, 4                               #Loads syscall to print a string
		la $a0, recordString                    #Loads record string
		syscall                                 #Prints "Record"
		
		li $v0, 1                               #Loads syscall to print an integer
		move $a0, $t2                           #Moves record integer to action register
		syscall                                 #Prints record integer
	
		li $v0, 11                              #Loads syscall to print a character
		li $a0, 58                              #Loads a : character
		syscall                                 #Prints :
	
		li $v0, 11                              #Loads the system call to print a character
		li $a0, 32                              #The character loaded is the index for the "space" character
		syscall                                 #Prints a space to the console
	
		li $v0, 4                               #Loads syscall to print a sting
		la $a0, records($t0)                    #Loads the current array adress
		syscall                                 #Prints the string part of teh records
	
		addi $t0,$t0,40                         #Adds 40 to the adress pointer
	
		li $v0, 11                              #Loads the system call to print a character
		li $a0, 32                              #The character loaded is the index for the "space" character
		syscall                                 #Prints a space to the console
	
		li $v0, 1                               #Loads syscall to print an integer
		lw $a0, records($t0)                    #Loads the current array address
		syscall                                 #Prints the first integer part of the record
	
		addi $t0,$t0,4                          #Adds 4 to adress pointer
	
		li $v0, 11                              #Loads the system call to print a character
		li $a0, 32                              #The character loaded is the index for the "space" character
		syscall                                 #Prints a space to the console
	
		li $v0, 1                               #Loads syscall to print an integer
		lw $a0, records($t0)                    #Loads the current array address
		syscall                                 #Prints the second integer part of the record
	
		addi $t0, $t0, 4                        #Adds 4 to the address pointer
	
		li $v0, 4                               #Loads syscall to print a string
		la $a0, newLine                         #Loads a new line
		syscall                                 #Prints a new line
	
		addi $t1, $t1, 1                        #Adds 1 to loop counter
		addi $t2, $t2, 1                        #Adds 1 to the record integer
	
		b print_loop                            #Branches back to the print loop
	
	endPrint:                                   #Ends the printing function
		jr $ra                                  #Jumps back to instruction from which the print function was called from
	
##################################################################################################################################	
	
Swap:                                           #Fucntion repsonisble for swaping records
	
	li $t0, 0                                   #First record user inputed address
	li $t1, 0                                   #Second record user inputed adress
	li $t2, 0                                   #First record calculated adress
	li $t3, 0                                   #Second recored calculated adress
	li $t6, 0                                   #loop counter
	li $t7, 0                                   #Byte Holder
	                                      

	move $t0, $a1                               #First Swap name String Index
	move $t1, $a2                               #Second Swap name String Index
	mul $t2, $t0, 48                            #First Swap name String Index Address
	mul $t3, $t1, 48                            #First Swap name String Index Address
	move $t0, $t2                               #Moves calculated first address
	move $t1, $t3                               #Moves calculated second address
	
	
	copy_one_to_stack_loop:                     #Copies first record to the stack
		beq $t6, $s5, endCopyToStackLoop        #once coppied, move on to copy 2 to 1
		
		lb $t7, records($t0)                    #Loads current byte from array into register
		sub $sp, $sp, 1                         #Subtracts 1 from stack pointer
		sb $t7, 0($sp)                          #Saves byte in register to the stack
		
		addi $t0, $t0, 1                        #Add 1 to the address pointer
		addi $t6, $t6, 1                        #Add 1 to the loop counter
		
		b copy_one_to_stack_loop                #Branch to the loop copying 1 to the stack	
	
	
	endCopyToStackLoop:                         #Starting to copy 2 to q
	li $t6, 0                                   #Loop counter
	move $t0, $t2                               #Move calculated first recrod address to register
	
	copy_two_to_one_loop:                       #Loop that coppoies the second record into the first records address space
		beq $t6, $s5, endCopyTwoToOneLoop       #Once coppied, move on to copy from stack to second record address
		
		lb $t7, records($t1)                    #Loads current byte from current address into register
		sb $t7, records ($t0)                   #saves byte in register to congruent address in record 1
		addi $t0, $t0, 1                        #Adds 1 to first record address pointer
		addi $t1, $t1, 1                        #Adds 1 to second record adress pointer
		addi $t6, $t6, 1                        #Adds 1 to the loop counter
		
		b copy_two_to_one_loop                  #Branches to the copy 2 to 1 loop
	
	endCopyTwoToOneLoop:                        #Once done, Program will copy from stack back into record 2 address
	move $t1, $t3                               #Move caluclated second address back to address pointer
	addi $t1, $t1, 47                           #Adds 47 to address pointer
	li $t6, 0                                   #Byte counter
	
	copy_stack_to_two_loop:                     #Loop that copies stack to second register address
		beq $t6, $s5, endCopyStackToTwo         #Once done, swaping is over
		
		lb $t7, 0($sp)                          #Loads byte from current space in stack
		sb $t7, records($t1)                    #Saves byte from stack into byte from second record
		addi $sp, $sp, 1                        #Adds 1 to the stack pointer
		sub $t1, $t1, 1                         #Subtracts 1 from the second record address pointer
		addi $t6, $t6, 1                        #Adds 1 to the byte counter
		
		b copy_stack_to_two_loop                #Branches to loop copying stack to second record address
		
	endCopyStackToTwo:                          #ends swapping
		jr $ra                                  #Jumps back to instructions that called the swap function
	
	

##################################################################################################################################	

Exit:                                           #Fucntion that ends teh program
	li $v0, 10                                  #Loads syscall to end program
	syscall                                     #Ends the program



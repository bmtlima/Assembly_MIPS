.data
    promptStr: .asciiz "input string:"
    promptInt: .asciiz "input int:"
    newline: .asciiz "\n"
    str: .asciiz "DONE\n"
    space: .asciiz " "

.text

main:
    addi $sp, $sp, -28
    sw $ra, 0($sp)
    sw $s0, 4($sp) # mem address of head node
    sw $s1, 8($sp) # mem address of dummie node
    sw $s6, 12($sp) # mem address to loop and print in the end
    sw $s3, 16($sp) # number of nodes
    sw $s4, 20($sp) # to loop when adding node
    sw $s5, 24($sp) # next element for looping through list

    #########################################################

    # mem alloc; creates head node on mem address $s0

    li $v0, 9
    la $a0, 72 #64 for string, 4 for number, 4 for mem address of next node
    syscall 

    move $s0, $v0

    # ask and store string on first 64 bytes of head

    li $v0, 4           
    la $a0, promptStr       # ask user for string
    syscall

    li $v0, 8           
    move $a0, $s0
    la $a1, 63
    syscall

    move $t3, $s0

    strlen_loopi:

    li $t7, 10         # initialize "\n"

    lb $t5, 0($t3)

    beq $t7, $t5, cuti
    addi $t3, $t3, 1
    j strlen_loopi        # continue looping

    cuti:
    sb $zero, 0($t3)

    #sb $zero, 64($s0)

    # getting 3 ints:

    li $v0, 4           
    la $a0, promptInt       # ask user for int
    syscall

    li $v0, 5               # read int
    syscall
    move $t0, $v0           # putting int on t0

    #

    li $v0, 4           
    la $a0, promptInt       # ask user for int
    syscall

    li $v0, 5               # read int
    syscall
    move $t1, $v0           # putting int on t1

    #

    li $v0, 4           
    la $a0, promptInt       # ask user for int
    syscall

    li $v0, 5               # read int
    syscall
    move $t2, $v0           # putting int on t2

    sub $t0, $t0, $t1
    add $t0, $t0, $t2          # t0 has number

    #li $v0, 1
    #move $a0, $t0
    #syscall

    sw $t0, 64($s0)         # load number to position 64 of s0

    #########################################################

    #move $a0, $s0
    #jal loop 
    #move $s0, $v0               # updating s0 as v0
    #move $s1, $v1               # seeting s1

    #move $s1, $s0
    li $s3, 1

    li $v0, 9
    la $a0, 72 #64 for string, 4 for number, 4 for mem address of next node
    syscall 

    move $s1, $v0 #s1 is dummie

    sw $s0, 68($s1)

    #li $t4, 3


list_loop:

    # IDEA: create node and assign its next by inserting it in right position

    #beq $t4, $zero, end


    ########################################################################
    #         CHECKING IF STRING IS "DONE" AND GETTING STRING
    ########################################################################

    la $t4, str

    # mem alloc; creates head node on mem address $s0

    li $v0, 9
    la $a0, 72 #64 for string, 4 for number, 4 for mem address of next node
    syscall 

    move $t6, $v0 #t6 is new guy

    # ask and store string on first 64 bytes of head

    li $v0, 4           
    la $a0, promptStr       # ask user for string
    syscall

    li $v0, 8           
    move $a0, $t6           # t6 has string
    la $a1, 63
    syscall

    move $a0, $t4
    move $a1, $t6 
    jal strcmp
    move $t8, $v0

    beqz $t8, end

    #t6


    move $t3, $t6

    strlen_loop:

    li $t7, 10         # initialize "\n"

    lb $t5, 0($t3)

    beq $t7, $t5, cut
    addi $t3, $t3, 1
    j strlen_loop        # continue looping

    cut:
    sb $zero, 0($t3)

    ########################################################################

    li $v0, 4           
    la $a0, promptInt       # ask user for int
    syscall

    li $v0, 5               # read int
    syscall
    move $t0, $v0           # putting int on t0

    #

    li $v0, 4           
    la $a0, promptInt       # ask user for int
    syscall

    li $v0, 5               # read int
    syscall
    move $t1, $v0           # putting int on t1


    li $v0, 4           
    la $a0, promptInt       # ask user for int
    syscall

    li $v0, 5               # read int
    syscall
    move $t2, $v0           # putting int on t2

    sub $t0, $t0, $t1
    add $t0, $t0, $t2          # t0 has number

    sw $t0, 64($t6)         # load number to position 64 of t6

    sw $zero, 68($t6)

    # now just add it to right position

    move $s4, $s1           # setting s4

    addi $s3, 1
# t6 is the new node 

insert:

    #t6 needs to be greater equal than s4 next (s5)
    
    lw $s5, 68($s4)

    beq $s5, $zero, last_node #s4 is last node

    move $a0, $t6
    move $a1, $s5 
    jal nodecmp
    move $t9, $v0 

    loopy:

    blez $t9, add_node
    lw $s4, 68($s4)
    j insert 

    last_node: 
    sw $t6, 68($s4)
    j list_loop

    add_node:

    #t3 and t5; s4 next is t6 and t6 next is s5

    sw $t6, 68($s4)
    sw $s5, 68($t6)
    j list_loop

nodecmp:

    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s1, 4($sp) # val of a0
    sw $s2, 8($sp) # val of a1
    sw $s3, 12($sp) #a0 
    sw $s4, 16($sp) #a1
    sw $s5, 20($sp) #result of strcmp

    move $s3, $a0
    move $s4, $a1

    lw $s1, 64($s3)
    lw $s2, 64($s4)

    bgt $s1, $s2, num_less
    blt $s1, $s2, num_greater
    beq $s1, $s2, num_equal

    num_less:

    li $v0, -1

    lw $s5, 20($sp) #result of strcmp
    lw $s4, 16($sp)
    lw $s3, 12($sp)
    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 24
    jr $ra       

    num_greater:

    li $v0, 1

    lw $s5, 20($sp) #result of strcmp
    lw $s4, 16($sp)
    lw $s3, 12($sp)
    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 24
    jr $ra    

    num_equal:

    move $a0, $s3
    move $a1, $s4 
    jal strcmp  
    move $s5, $v0 

    blez $s5, num_less 
    bgez $s5, num_greater


strcmp:

    addi $sp, $sp, -4
    sw $ra, 0($sp)

    loop:

    lbu $t1, ($a0)      # load byte from string 1
    lbu $t2, ($a1)      # load byte from string 2
    beq $t1, $t2, equal # if bytes match, go to equal
    bne $t1, $t2, notequal # if bytes don't match, go to notequal

    equal:

    beqz $t1, done      # if end of string, strings are equal
    addiu $a0, $a0, 1   # increment string 1 pointer
    addiu $a1, $a1, 1   # increment string 2 pointer
    j loop              # jump to loop

    notequal:

    sub $v0, $t1, $t2   # return difference between bytes
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra              # return to calling function

    done:

    li $v0, 0           # return 0 if strings are equal

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra              # return to calling function

end:

    # printing everything

    move $s6, $s1
    lw $s6, 68($s6)

    move $t5, $s3

# assume the address of the string is in $a0

# calculate the length of the string

print_loop:

    beq $t5, $zero, exit
    lw $t3, 64($s6)

    li $v0, 4
    move $a0, $s6
    syscall

    li $v0, 4
    la $a0, space
    syscall

    #lw $t7, 65($s2)

    li $v0, 1
    move $a0, $t3
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    lw $s6, 68($s6)

    addi $t5, $t5, -1
    j print_loop

exit:

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s6, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    addi $sp, $sp, 28

    jr $ra

.data

##  Your name and ID etc go here
#Isabelle Lai
#919259175


X_string: .string "X = "
Y_string: .string "Y = "
result_string: .string "X x Y = "

newln:    .string "\n"

# X and Y are the inputs

X:  .word     0x3c24    #0x4020
Y:  .word     0x3ca4    #0x40a8


# .text means the rest of the stuff is a program or instructions to the computer
.text
.globl main                         # make main available to all project files

main:                               # There should be one main

# Don't Touch this (BEGIN)
# Code to print X_string
    la a1, X_string
    li a0, 4
    ecall 

# Code to print X. The syscall code 34 in register a0, results in printing the number in hexadecimal notation. 
    lw a1, X
    li a0, 34
    ecall 

# Code to print newln
    la a1, newln
    li a0, 4
    ecall 

# Code to print Y_string
la a1, Y_string
    li a0, 4
    ecall 

# Code to print Y. The syscall code 34 in register a0, results in printing the number in hexadecimal notation. 
    lw a1, Y
    li a0, 34
    ecall 
# Code to print newln
    la a1, newln
    li a0, 4
    ecall


###    Pass X in a1,  Pass Y in a2, call the function bfmult and store result in a3
    lw a1, X
    lw a2, Y
    jal x1, bfmult


# Code to print result_string
    la a1, result_string
    li a0, 4
    ecall 

# Code to print result. The syscall code 34 in register a0, results in printing the number in hexadecimal notation. 
    add a1, x0, a3
    li a0, 34
    ecall 
# Code to print newln
    la a1, newln
    li a0, 4
    ecall
    j exit

# Don't touch this (END)





### BEGIN YOUR CODE  (Make sure the result is in register a3, remember X and Y are in a1 and a2)
bfmult:

    addi sp, sp, -12         #save original values in stack
    sw a1, 0(sp)
    sw a2, 4(sp)

  ######### add exponents, adjust  bias

  #NOT ACCOUNTING FOR OVERFLOW
  #bias = 127; same numer of exponent bits as single precision 
  #127 in hex = 0x7F
    
    srli a1, a1, 7          #sign bit and exponent 
    srli a2, a2, 7
    andi a1, a1, 0xFF       #only exponnent
    andi a2, a2, 0xFF
    add a3, a1, a2
    addi a3, a3, -127       #subtract bias
    slli a3, a3, 7          #put exp in exp place value
    sw a3, 8(sp)

  ########## multiply significands

    #a1 = multiplier(lsb of a3 = prod), a2 = multiplicand 
    #right 7 bits = fract

    lw a1, 0(sp)            #restore a1 and a2
    lw a2, 4(sp)

    andi a1, a1, 0x7F      #get only the fraction part = 7 bits, add 1 into it to get significand
    addi a1, a1, 0x80

    andi a2, a2, 0x7F
    addi a2, a2, 0x80

    slli, a2, a2, 8     #adjust multiplicand to line up with the product
    
    add a3, a1, x0      #put multiplier in lsb of prod reg; a3 = prod reg 
    
    addi a4, x0, 0x8       #count iterations

    Multiply:
        addi a4, a4, -1         #increment counter
        andi a1, a3, 0x1        #get lsb of multiplier
        bne a1, x0, AddMcand
        j Done
        AddMcand:
            add a3, a3, a2      #add multiplicand to product
    Done:
        srli a3, a3, 1      #shift over product and multiplier
        bne a4, x0, Multiply   #loop as long as 7 iterations have not fully happened

    #product in a3; 13 decimal places

    srli a3, a3, 7              #get rid of 7 lsb of fraction to get product with 7 frac place vals
    srli a1, a3, 7              #a1 = whole val of product
    andi a3, a3, 0x7F           #a3 = frac of product (7 place vals)

    lw a2, 8(sp)                #a2 = exponent in exponent place values
    add a2, a2, a3              #add fraction to it in correct lsb place values
    sw a2, 8(sp)                #put back in stack where a3 is stored; a2 = exp, frac

    #slli a1, a1, 7              #move whole value of product back in nright place
    #add a3, a1, a3              #a3 = product; add whole val and frac together

    #a3 will always be at least 1
    AdjustDec:
        andi a3, a1, 0x1        #a3 = lsb of whole value of the prod
        srli a1, a1, 1          #shift a1 (whole val) over
        beq a1, x0, SetSign     #if a3 = 0 after shift right 1, then don't adjust dec
        
        lw a2, 8(sp)            #a2 = exp, frac
        addi a2, a2, 0x80       #add 1 to exponent, a2 = exp, frac
        sw a2, 8(sp)            #save to stack
        andi a2, a2, 0x7F       #a2 = frac 
        srli a2, a2, 1          #shift fraction to the right
        slli a3, a3, 7          #shift lsb of whole value to be msb of frac
        add a2, a2, a3          #add to update frac
        lw a3, 8(sp)            #a3 = adjusted exp, unadjusted frac
        srli a3, a3, 7          #clear frac part to 0 
        slli a3, a3, 7
        add a3, a3, a2          #a3 = adjusted fp value
        sw a3, 8(sp)            #save to stack

        j AdjustDec             #loop unconditionnally


  ######## set sign bit
    SetSign:
        lw a1, 0(sp)
        lw a2, 4(sp)
        lw a3, 8(sp)
        srli a1, a1, 15     #get sign bits of a1 and a2 in lsb position of a1 and a2
        srli a2, a2, 15
        xor a1, a1, a2      #xor = 1 = negative if a1 is not equal to a2
        slli a1, a1, 15
        add a3, a3, a1      #add to final answer

        addi sp, sp, -12
        j Exit


    Exit:
        jr x1










####  END YOUR CODE

# Don't modify anything below this.  It is just to exit the program gracefully.

   la a1, newln
    li a0, 4
    ecall

exit:
    addi a0, zero, 10 
    ecall
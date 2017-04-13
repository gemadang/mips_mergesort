# MIPS: MERGESORT PART 2
# CIS 341 - MINA JUNG
# GERI MADANGUIT
	
	.data
Array1:		.word	56	3	46	47	34	12	1	5	10	8	33	25	29	31	50	43
size:		.word 16
Array2:		.word	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0

unsort:		.asciiz "Unsorted Array"
sort:		.asciiz "Sorted Array"
newline:	.asciiz "\n"
space:		.asciiz " "

	.text
main:
	j printstart
	
printstart:
	#print unsorted message
	li $v0, 4
	la $a0, unsort
	syscall

	#print newline message
	li $v0, 4
	la $a0, newline
	syscall
printloopstart:
	lw $t1, size				# load array length
	bge $t0, $t1, printlines			# end program if the current index >= size

	sll $t2, $t0, 2				# index * 4
	la $a1, Array1
	add $t2, $a1, $t2
	lw $a0, 0($t2)				# get pointer

	li $v0, 1				# print integer
	syscall
	
	la $a0, space				# set value to print space

	li $v0, 4
	syscall					# print space

	addi $t0, $t0, 1			# increment current index
	j printloopstart

printlines:
	la $a0, newline				# set value to print space
	li $v0, 4
	syscall					# print new line
	
	la $a0, newline				# set value to print space
	li $v0, 4
	syscall					# print new line

secondmain:
	la $a0, Array1				# load start adress of a[]
	add $a1, $zero, $zero			# low = 0
	lw $t0, size
	addi $a2, $t0, -1 			# high
	
	jal mergesort
	j printend
	
mergesort:
	addi $sp, $sp, -16			# Adjust stack pointer for 4 items
	sw $ra, 0($sp)				# return address
	sw $a0, 4($sp)				# a[]
	sw $a1, 8($sp)				# low 
	sw $a2, 12($sp)				# high
	
	slt $t0, $a1, $a2			#if (low<high) 
	beq $t0, $zero, mergedone		# branch to mergesortend if high<=low 
	
	add $t0, $a1, $a2			# low + high
	srl $a2, $t0, 1				# mid = (low + high) / 2
	
	addi $sp, $sp, -4			# push mid
	sw $a2, 0($sp)	 			# mid
	jal mergesort				# call recursively of first half of array (a[],low,mid)

	lw $a0, 8($sp)				# load a[]
	lw $a1, 0($sp)				# load mid
	lw $a2, 16($sp)				# load high
	addi $a1, $a1, 1			# mid + 1
	
	jal mergesort				# call recursively of first half of array (a[],mid+1,high)
	
	lw $a0, 8($sp)				# load a[]
	lw $a1, 12($sp)				# load low
	lw $a2, 16($sp)				# load high
	lw $a3, 0($sp)				# load mid
	
	jal merge				# merge two halves (a, low, high, mid)
	
	addi $sp, $sp, 4			# pop mid
mergedone:
	lw $ra, 0($sp)				# pops everything
	lw $a0, 4($sp)
	lw $a1, 8($sp) 
	lw $a2, 12($sp)
	
	addi $sp, $sp, 16			# return stack pointer to top
	jr $ra					# Return
			
merge:
	add $s0, $zero, $a0			# base adress of a[]
	add $s1, $a1, $zero			# $s1 = low
        add $s2, $a2, $zero 			# $s2 = high
	add $s3, $a3, $zero 			# $s3 = mid

	add $t1, $s1, $zero			# $t1 = i
							#i= low
	add $t2, $s1, $zero 			# $t2 = k
							#k = low
	addi $t3, $s3, 1			# $t3 = j
							#j = mid +1
	
	j while1
	
while1:						# while (i <= mid && j <= high)
	slt $t4, $s3, $t1			# (mid < i) 
	bne $t4, $zero, while2			# jump to while2 if (mid < i)
	slt $t5, $s2, $t3			# (high < j)
	#or $t9, $t4, $t5
	bne $t5, $zero, while2			# jump to while2 if (high < j)

	sll $t6, $t1, 2				# i*4
	add $t6, $s0, $t6			# address of a[i]
	lw $s4, 0($t6)				# get contents of a[i]

	sll $t7, $t3, 2				# j*4
	add $t7, $s0, $t7			# address of a[j]
	lw $s5, 0($t7)				# get contents of a[j]
						
	slt $t4, $s4, $s5			# (a[i] < a[j])
	beq $t4, $zero, else			# jump to else if (a[i] >= a[j])

	sll $t8, $t2, 2				# k*4
	la $a0, Array2				# load address of c[]
	add $t8, $a0, $t8			# address of c[k]
	sw $s4, 0($t8)				# c[k] = a[i]	
	
	addi $t2, $t2, 1			# k++
	addi $t1, $t1, 1			# i++
	j while1
else:
	sll $t8, $t2, 2				# k*4
	la $a0, Array2				# load address of c[]
	add $t8, $a0, $t8			# address of c[k]
	sw $s5, 0($t8)				# c[k] = a[j]

	addi $t2, $t2, 1			# k++
	addi $t3, $t3, 1			# j++
	j while1
	
while2:						#while (i <= mid)
	slt $t4, $s3, $t1			# (mid < i) 
	bne $t4, $zero, while3			# jump to while3 if (mid < i)

	sll $t6, $t1, 2				# i*4
	add $t6, $s0, $t6			# address of a[i]
	lw $s4, 0($t6)				# get contents of a[i]

	sll $t8, $t2, 2				# k*4
	la $a0, Array2				# load address of c[]
	add $t8, $a0, $t8			# address of c[k]
	sw $s4, 0($t8)				# c[k] = a[i]

	addi $t2, $t2, 1			# k++
	addi $t1, $t1, 1			# i++
	j while2
	
while3:						# while (j <= high)
	slt $t5, $s2, $t3			# (high < j)
	bne $t5, $zero, forloop			# jump to forloop if (high < j)

	sll $t7, $t3, 2				# j*4
	add $t7, $s0, $t7			# address of a[j]
	lw $s5, 0($t7)				# get contents of a[j]

	sll $t8, $t2, 2				# k*4
	la $a0, Array2				# load address of c[]
	add $t8, $a0, $t8			# address of c[k]
	sw $s5, 0($t8)				# c[k] = a[j]

	addi $t2, $t2, 1			# k++
	addi $t3, $t3, 1			# j++
	j while3
	
forloop:
	add $t1, $zero, $zero			# i = low
loop:
	slt $t5, $t1, $t2			# i < k
	beq $t5, $zero, goback		# jump to printend if (i >= k)

	sll $t6, $t1, 2				# i*4
	add $t6, $s0, $t6			# address of a[i]
	
	sll $t8, $t1, 2				# i*4
	la $a0, Array2				# load address of c[]
	add $t8, $a0, $t8			# address of c[i]
	lw $s7, 0($t8)				# get contents of c[i]

	sw $s7, 0($t6)				# a[i] = c[i]

	addi $t1, $t1, 1
	j loop
goback:
	jr $ra
printend:
	#print unsorted message
	li $v0, 4
	la $a0, sort
	syscall

	#print newline message
	li $v0, 4
	la $a0, newline
	syscall

	add $t0, $zero, $s1 			# initialize current index
printloopend:
	lw $t1, size				# load array length
	bge $t0, $t1, exit			# end program if the current index >= size

	sll $t2, $t0, 2				# index * 4
	la $a1, Array1
	add $t2, $a1, $t2
	lw $a0, 0($t2)				# get pointer

	li $v0, 1				# print integer
	syscall
	
	la $a0, space				# set value to print space

	li $v0, 4
	syscall					# print space

	addi $t0, $t0, 1			# increment current index
	j printloopend
exit:	
	li $v0, 10
	syscall

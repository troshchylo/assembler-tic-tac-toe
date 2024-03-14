.data
	tab: .byte '1', '2', '3', '4', '5', '6', '7', '8', '9'
	text1: .asciiz " | "
	text2: .asciiz "\n---------\n"
	text3: .asciiz "\nKolko czy krzyzyk?(0 - X, 1 - O)\n"
	text4: .asciiz "\nIle gier gramy? [1, 5]\n"
	text5: .asciiz "\nUzytkownik wygrywa!"
	text6: .asciiz "\nKomputer wygrywa!"
	text7: .asciiz "\nRemis!"
	text8: .asciiz "\nWynik na koniec gry: "
	text9: .asciiz "\n"
	text10: .asciiz "\nWpisz numer pola[1,9]: "
# t3 - znak uzytkownika
# t4 - znak komputera
# t2 - ile gier sie skonczylo
# t6 - ile gier wygral uzytkownik
# t7 - ile gier wygral komputer
# t5 - ile gier musimy grac
.text
main:
	la $a0, text3
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
							#odczytujemy O albo X
	beq $v0, 0, krzyz
	bne $v0, 1, main
	add $t3, $zero, 79 # O
	add $t4, $zero, 88 # X
	j ileGier
krzyz:
	add $t3, $zero, 88
	add $t4, $zero, 79
ileGier: 						# odczytujemy ile gier bedziemy mieli
	la $a0, text4
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	blt $v0, 1, ileGier
	bgt $v0, 5, ileGier
	add $t5, $zero, $v0
newGame: 						# uruchamiamy gre
	beq $t2, $t5, endStats
	
	jal clearTab 					#oczyszczamy tablice znakow
	nextChoice:  					#kolejne kroki
		jal nextLine
		jal print
		
		la $a0, text10
		li $v0, 4
		syscall
							#pytamy uztkownika gdzie on che umieszcic znak
		li $v0, 5
		syscall
							#sprawdzamy czy mozna wrzuczic znak na podane miejsce
		blt $v0, 1, nextChoice
		bgt $v0, 9, nextChoice
		
		sub $v0, $v0, 1
		lb $t0, tab($v0)
		bgt $t0, 78, nextChoice
		
		sb $t3, tab($v0)
							#sprawdzamy czy po kroku uzytkownika ktos wygral
		jal whoWin
							#jak nie to komputer wybiera gdzie umiesci swoj znak
		jal aiChoice
							#sprawdzamy czy ktos wygral
		jal whoWin
							#jak nie to przechodzimy na nastepny krok
		j nextChoice
endStats:
	la $a0, text2
	li $v0, 4
	syscall
							#sprawdzamy kto wygral
	bgt $t6, $t7, userWin
	bgt $t7, $t6, aiWin
							#ty wypisujemy ze mamy remis
	la $a0, text7
	li $v0, 4
	syscall
							#wyswietlamy wynik
	j showResult
aiWin: 							#wygral komputer
	la $a0, text6
	li $v0, 4
	syscall
	
	j showResult
userWin:						#wygral uzytkownik
	la $a0, text5
	li $v0, 4
	syscall
showResult:						#wyswietlenie wyniku
	la $a0, text8
	li $v0, 4
	syscall
	
	add $a0, $zero, $t6
	li $v0, 1
	syscall
	
	la $a0, text1
	li $v0, 4
	syscall
	
	add $a0, $zero, $t7
	li $v0, 1
	syscall
	
	j end
whoWin:							#sprawdzenie czy ktos wygral
	add $t0, $zero, -3
	lineLoop:					#sprawdzamy wierzy
		add $t0, $t0, 3
		bgt $t0, 6, columnCheck
		add $s0, $t0, 0
		add $s1, $t0, 1
		add $s2, $t0, 2
		
		lb $s0, tab($s0)
		lb $s1, tab($s1)
		lb $s2, tab($s2)
		
		beq $s0, $s1, skipf
		j lineLoop
		skipf:
			beq $s1, $s2, winner
			j lineLoop
	columnCheck:					#sprawdzamy kolumny
	add $t0, $zero, -1
	columnLoop:
		add $t0, $t0, 1
		bgt $t0, 2, diagonalCheck
		add $s0, $t0, 0
		add $s1, $t0, 3
		add $s2, $t0, 6
		
		lb $s0, tab($s0)
		lb $s1, tab($s1)
		lb $s2, tab($s2)
		
		beq $s0, $s1, skipc
		j columnLoop
		skipc:
			beq $s1, $s2, winner
			j columnLoop
	diagonalCheck:					#sprawdzamy przekatne
		add $s0, $zero, 0
		add $s1, $zero, 4
		add $s2, $zero, 8
		
		lb $s0, tab($s0)
		lb $s1, tab($s1)
		lb $s2, tab($s2)
		
		beq $s0, $s1, skipd
		j nextTry
		skipd:
			beq $s1, $s2, winner
			j nextTry
		nextTry:
		add $s0, $zero, 2
		add $s1, $zero, 4
		add $s2, $zero, 6
		
		lb $s0, tab($s0)
		lb $s1, tab($s1)
		lb $s2, tab($s2)
		
		beq $s0, $s1, skiph
		j lastCheck
		skiph:
			beq $s1, $s2, winner
			j lastCheck
	lastCheck:					#sprawdzamy czy sa wolne miejsca
		add $s0, $zero, 0
		loop1:
			bgt $s0, 8, draw
			lb $s1, tab($s0)
			blt $s1, 77, back
			add $s0, $s0, 1
			j loop1
	draw:						#remis
		jal print
		la $a0, text7
		li $v0, 4
		syscall
		add $t2, $t2, 1
		j newGame
	winner:						#wypisujemy kto wygral
		add $t2, $t2, 1
		jal print
		beq $s0, $t3, user
		la $a0, text6				#komputer
		li $v0, 4
		syscall
		add $t7, $t7, 1
		j newGame
		user:					#uzytkownik
			la $a0, text5
			li $v0, 4
			syscall
			add $t6, $t6, 1
			j newGame
clearTab:						#oczyszczamy tablice
	add $t8, $zero, 0
	clearLoop:
		addi $t9, $t8, 49
		sb $t9, tab($t8)
		addi $t8, $t8, 1
		ble $t8, 8, clearLoop
	jr $ra
aiChoice:						#krok komputera
	add $t8, $zero, $t4
	lineChoice:					#sprawdzamy wierszy
		add $t0, $zero, -3
		loop2:
			add $t0, $t0, 3
			bgt $t0, 6, loop3
			add $s0, $t0, 0
			add $s1, $t0, 1
			
			lb $s0, tab($s0)
			lb $s1, tab($s1)
			beq $s0, $s1, mbWin
			j loop2
			mbWin:
				bne $s0, $t8, loop2
				add $s1, $t0, 2
				
				lb $s1, tab($s1)
				bgt $s1, 78, loop2
				
				add $s1, $t0, 2
				sb $t4, tab($s1)
				jr $ra
		loop3:
			sub $t0, $t0, 3
			blt $t0, 0, loop7
			add $s0, $t0, 1
			add $s1, $t0, 2
			
			lb $s0, tab($s0)
			lb $s1, tab($s1)
			beq $s0, $s1, mbWin2
			j loop3
			mbWin2:
				bne $s0, $t8, loop3
				add $s1, $t0, 0
				
				lb $s1, tab($s1)
				bgt $s1, 78, loop3
				
				add $s1, $t0, 0
				sb $t4, tab($s1)
				jr $ra
		loop7:
			add $t0, $t0, 3
			bgt $t0, 6, columnChoice
			add $s0, $t0, 0
			add $s1, $t0, 2
			
			lb $s0, tab($s0)
			lb $s1, tab($s1)
			beq $s0, $s1, mbWin6
			j loop7
			mbWin6:
				bne $s0, $t8, loop7
				add $s1, $t0, 1
				
				lb $s1, tab($s1)
				bgt $s1, 78, loop7
				
				add $s1, $t0, 1
				sb $t4, tab($s1)
				jr $ra
	columnChoice:					#sprawdzamy kolumny
		add $t0, $zero, -1
		loop4:
			add $t0, $t0, 1
			bgt $t0, 2, loop5
			add $s0, $t0, 0
			add $s1, $t0, 3
			
			lb $s0, tab($s0)
			lb $s1, tab($s1)
			beq $s0, $s1, mbWin3
			j loop4
			mbWin3:
				bne $s0, $t8, loop4
				add $s1, $t0, 6
				
				lb $s1, tab($s1)
				bgt $s1, 78, loop4
				
				add $s1, $t0, 6
				sb $t4, tab($s1)
				jr $ra
		loop5:
			sub $t0, $t0, 1
			blt $t0, 0, loop8
			add $s0, $t0, 3
			add $s1, $t0, 6
			
			lb $s0, tab($s0)
			lb $s1, tab($s1)
			beq $s0, $s1, mbWin4
			j loop5
			mbWin4:
				bne $s0, $t8, loop5
				add $s1, $t0, 0
				
				lb $s1, tab($s1)
				bgt $s1, 78, loop5
				
				add $s1, $t0, 0
				sb $t4, tab($s1)
				jr $ra
		loop8:
			add $t0, $t0, 1
			bgt $t0, 2, diagonalChoice
			add $s0, $t0, 0
			add $s1, $t0, 6
			
			lb $s0, tab($s0)
			lb $s1, tab($s1)
			beq $s0, $s1, mbWin7
			j loop8
			mbWin7:
				bne $s0, $t8, loop8
				add $s1, $t0, 3
				
				lb $s1, tab($s1)
				bgt $s1, 78, loop8
				
				add $s1, $t0, 3
				sb $t4, tab($s1)
				jr $ra
	diagonalChoice:					#sprawdzamy przekatne
		lb $s0, tab+4
		lb $s1, tab+0
		lb $s2, tab+2
		lb $s3, tab+6
		lb $s4, tab+8
		
		bne $s0, $t8, ch4
		bne $s0, $s1, ch1
		bgt $s4, 78, ch1
		sb $t4, tab+8
		j back
		ch1:
		bne $s0, $s2, ch2
		bgt $s3, 78, ch2
		sb $t4, tab+6
		j back
		ch2:
		bne $s0, $s3, ch3
		bgt $s2, 78, ch3
		sb $t4, tab+2
		j back
		ch3:
		bne $s0, $s4, ch4
		bgt $s1, 78, ch4
		sb $t4, tab+0
		j back
		ch4:
		bne $s1, $s4, ch5
		bgt $s0, 78, ch5
		sb $t4, tab+4
		j back
		ch5:
		bne $s2, $s3, ch6
		bgt $s0, 78, ch6
		sb $t4, tab+4
		j back
	ch6:						#sprawdzamy dla znaku uzytkownika
		beq $t8, $t3, firstPosChoice
		add $t8, $zero, $t3
		j lineChoice
	firstPosChoice:					#jak nie mamy nic, szukamy pierwszej pustej pozycji
		add $t0, $zero, -1
		loop6:
			add $t0, $t0, 1
			lb $s0, tab($t0)
			bgt $s0, 78, loop6
			sb $t4, tab($t0)
			j back
print:							#wyswietamy tablice
	addi $t0, $zero, 0
	printloop:
	add $t1, $zero, 3
	div $t0, $t1
	mfhi $t1
	beq $t0, 8, endloop
	bne $t1, 2, skip

	lb $a0, tab($t0)
	li $v0, 11
	syscall
	
	la $a0, text2
	li $v0, 4
	syscall
	
	
	add $t0, $t0, 1
	
	j printloop
	endloop:
		lb $a0, tab($t0)
		li $v0, 11
		syscall
		
		j back
	skip:
		lb $a0, tab($t0)
		li $v0, 11
		syscall
		
		la $a0, text1
		li $v0, 4
		syscall
		
		add $t0, $t0, 1
		
		j printloop
nextLine:							#nastepny wierz
	la $a0, text9
	li $v0, 4
	syscall
	
	j back
back:
	jr $ra
end:
	li $v0, 10
	syscall

		.data
campo:			.space		324   # esta versão suporta campo de até 9 x 9 posições de memória
salva_S0:		.word		0
salva_ra:		.word		0
salva_ra1:		.word		0
space:			.string		" "
blankline:		.string		"\n"	
CHidden:		.space		256
Hifen:			.string		"-"
NCol:			.word		0				
Flg:			.string		"F"	
Output0:		.string	"Digite 1 para selecionar uma posicao ou Digite 2 para colocar ou remover uma bandeira:"
Output1:		.string	"Digite o numero da linha:"
Output2:		.string "Digite o numero da coluna:"		
Output3:		.string	"Por favor digite uma opcao valida!!!"			
Output4:		.string "------------------------------Game Over------------------------------"
Output5:		.string "Debug"
Output6:		.string "Selecione uma posicao valida!!!"
Output7:		.string	"Parabens voce ganhou!!!"
BMB:			.string "B"

		.text 
		
main:
	la 	a0, campo
	addi	a1, zero, 8
	jal 	INSERE_BOMBA
	j 	Fill		#Chama a funcao de preencher o campo


INSERE_BOMBA:
		la	t0, salva_S0
		sw  	s0, 0 (t0)		# salva conteudo de s0 na memoria
		la	t0, salva_ra
		sw  	ra, 0 (t0)		# salva conteudo de ra na memoria
		
		add 	t0, zero, a0		# salva a0 em t0 - endereço da matriz campo
		add 	t1, zero, a1		# salva a1 em t1 - quantidade de linhas 

QTD_BOMBAS:
		addi 	t2, zero, 15 		# seta para 15 bombas	
		add 	t3, zero, zero 	# inicia contador de bombas com 0
		
		addi 	a7, zero, 30 		# ecall 30 pega o tempo do sistema em milisegundos (usado como semente
		ecall 				
		
		add 	a1, zero, a0		# coloca a semente em a1
INICIO_LACO:
		beq 	t2, t3, FIM_LACO
		add 	a0, zero, t1 		# carrega limite para %	(resto da divisão)
		jal 	PSEUDO_RAND
		add 	t4, zero, a0		# pega linha sorteada e coloca em t4
		add 	a0, zero, t1 		# carrega limite para % (resto da divisão)
   		jal 	PSEUDO_RAND
		add 	t5, zero, a0		# pega coluna sorteada e coloca em t5
		
LE_POSICAO:	
		mul  	t4, t4, t1
		add  	t4, t4, t5  		# calcula (L * tam) + C
		add  	t4, t4, t4  		# multiplica por 2
		add  	t4, t4, t4  		# multiplica por 4
		add  	t4, t4, t0  		# calcula Base + deslocamento
		lw   	t5, 0(t4)   		# Le posicao de memoria LxC
VERIFICA_BOMBA:		
		addi 	t6, zero, 9		# se posição sorteada já possui bomba
		beq  	t5, t6, PULA_ATRIB	# pula atribuição 
		sw   	t6, 0(t4)		# senão coloca 9 (bomba) na posição
		addi 	t3, t3, 1		# incrementa quantidade de bombas sorteadas
PULA_ATRIB:
		j	INICIO_LACO

FIM_LACO:					# recupera registradores salvos
		la	t0, salva_S0
		lw  	s0, 0(t0)		# recupera conteudo de s0 da memória
		la	t0, salva_ra
		lw  	ra, 0(t0)		# recupera conteudo de ra da memória		
		jr 	ra			# retorna para funcao que fez a chamada
		
PSEUDO_RAND:
		addi t6, zero, 125  		# carrega constante t6 = 125
		lui  t5, 682			# carrega constante t5 = 2796203
		addi t5, t5, 1697 		# 
		addi t5, t5, 1034 		# 	
		mul  a1, a1, t6			# a = a * 125
		rem  a1, a1, t5			# a = a % 2796203
		rem  a0, a1, a0			# a % lim
		bge  a0, zero, EH_POSITIVO  	# testa se valor eh positivo
		addi t4, zero, -1           	# caso não 
		mul  a0, a0, t4		    	# transforma em positivo
EH_POSITIVO:	
		ret				# retorna em a0 o valor obtido

#####################################################################################################################
						#Funcao para preencher o campo com -
Fill:		li a1, 8			
		li t1, 1
		li t0, 1		
		lw a0, Hifen			#coloca o - no reg a0
		la a2, CHidden			#pega a primeira posicao do campo
		
fillF1:		bgt  t0, a1, PosPB
fillF2:		bgt t1, a1 endFF		
		sw a0, 0(a2)			#coloca o - na posicao atual do campo
		addi a2, a2, 4			#avanca em 1 a posicao do campo
		addi t1, t1, 1
		j fillF2
endFF:		addi t0, t0, 1
		li t1, 1
		j fillF1

########################################################################################################################
PosPB:		la 	a0, campo		
		addi	a1, zero, 8		#carrega em a1 o numero de linhas
		addi	a3, zero, 9		#carrega uma bomba em a3
		sw	a3, 4(a0)
		addi 	t0, zero, 1		#carrega t0,t1,t2,t3 com 1 para o For
		addi	t1, zero, 1
		addi 	t2, zero, 1		#t2,t3,t4,t5 serve para saber se a posicao esta na borda
		addi	t3, zero, 1
		addi	t4, zero, 8
		addi	t5, zero, 8
		mv 	a2, a0			#carrega em a2 o endereco do campo
##########################################################################################################	
for1:		bgt t0, a1, imprime_bomba	#for de t0<a1 (1<8)
for2:		bgt t1, a1, endfor		#for de t1<a1 (1<8) pula pro final do 2o for
		
		lw a0, 0(a2)
		bge  a0, a3, BombP		#If se a posicao atual for uma bomba
RetBomb:		
		addi a2, a2, 4			#avanca 1 posicao em a2
		addi t1, t1, 1			#aumenta em 1 o t1
		j for2				#retorna para o comeco do for2
	
endfor:		addi t0, t0, 1			#aumenta em 1 o t2
		addi t1, zero, 1		#'seta' para 1 o t1
		
		j for1				#pula para o comeco do for1
#####################################################################################################
BombP:		beq t0, t2 COL1			#Se for a primeira linha
		beq t0, t5 COL8			#Se for a ultima linha
		bne t0, t2 COL27		#Se for entre as linhas 2-7
		
		
		j RetBomb

COL1:		beq t1, t3 L1C1			#Primeira linha da primeira coluna
		beq t1, t5 L1C8			#Ultima coluna da primeira linha
						#----------------------------------------------------------------
		lw a4, -4(a2)			
		addi a4, a4, 1
		sw a4, -4(a2)
		
		lw a4, 4(a2)
		addi a4, a4, 1
		sw a4, 4(a2)
		
		lw a4, 28(a2)
		addi a4, a4, 1			#adiciona +1 para as 5 posicoes perto da bomba
		sw a4, 28(a2)
		
		lw a4, 32(a2)
		addi a4, a4, 1
		sw a4, 32(a2)
		
		lw a4, 36(a2)
		addi a4, a4, 1
		sw a4, 36(a2)
					       #----------------------------------------------------------------
		j RetBomb

L1C1:		lw a4, 4(a2)			#Adiciona +1 para as 3 posicoes perto do canto superior esquerdo
		addi a4, a4, 1
		sw a4, 4(a2)
		
		lw a4, 32(a2)
		addi a4, a4, 1
		sw a4, 32(a2)
		
		lw a4, 36(a2)
		addi a4, a4, 1
		sw a4, 36(a2)
		j RetBomb
						#----------------------------------------------------------------
L1C8:		lw a4, -4(a2)			#Adiciona +1 para as 3 posicoes perto do canto superior direito
		addi a4, a4, 1
		sw a4, -4(a2)
		
		lw a4, 28(a2)
		addi a4, a4, 1
		sw a4, 28(a2)
		
		lw a4, 32(a2)
		addi a4, a4, 1
		sw a4, 32(a2)
		j RetBomb
						#----------------------------------------------------------------


COL27:		beq t1, t3 L27C1			#Primeira coluna das linhas 2-7
		beq t1, t5 L27C8			#Ultima coluna das linha 2-7
		
		lw a4, -4(a2)			#------------------------------------------------------------------
		addi a4, a4, 1
		sw a4, -4(a2)
		
		lw a4, 4(a2)
		addi a4, a4, 1
		sw a4, 4(a2)
		
		lw a4, 28(a2)
		addi a4, a4, 1			#adiciona +1 para as 9 posicoes perto da bomba
		sw a4, 28(a2)
		
		lw a4, 32(a2)
		addi a4, a4, 1
		sw a4, 32(a2)
		
		lw a4, 36(a2)
		addi a4, a4, 1
		sw a4, 36(a2)
		
		lw a4, -36(a2)
		addi a4, a4, 1
		sw a4, -36(a2)
		
		lw a4, -32(a2)
		addi a4, a4, 1
		sw a4, -32(a2)
		
		lw a4, -28(a2)
		addi a4, a4, 1
		sw a4, -28(a2)
		j RetBomb
L27C1:						#------------------------------------------------------------------
		lw a4, -32(a2)			
		addi a4, a4, 1
		sw a4, -32(a2)
		
		lw a4, -28(a2)			
		addi a4, a4, 1
		sw a4, -28(a2)
		
		lw a4, 4(a2)			
		addi a4, a4, 1				#adiciona +1 para as 5 posicoes perto da borda esquerda
		sw a4, 4(a2)
		
		lw a4, 32(a2)			
		addi a4, a4, 1
		sw a4, 32(a2)
		
		lw a4, 36(a2)			
		addi a4, a4, 1
		sw a4, 36(a2)
		j RetBomb
						#------------------------------------------------------------------
L27C8:								
		lw a4, -32(a2)			
		addi a4, a4, 1
		sw a4, -32(a2)
		
		lw a4, -36(a2)			
		addi a4, a4, 1
		sw a4, -36(a2)
		
		lw a4, -4(a2)			
		addi a4, a4, 1				#adiciona +1 para as 5 posicoes perto da borda direita
		sw a4, -4(a2)
		
		lw a4, 32(a2)			
		addi a4, a4, 1
		sw a4, 32(a2)
		
		lw a4, 28(a2)			
		addi a4, a4, 1
		sw a4, 28(a2)
		j RetBomb
						#------------------------------------------------------------------
COL8:		beq t1, t3 L8C1			#Ultima linha da primeira coluna
		beq t1, t5 L8C8			#Ultima coluna da utlima linha
						#------------------------------------------------------------------
		lw a4, -4(a2)			
		addi a4, a4, 1
		sw a4, -4(a2)
		
		lw a4, 4(a2)
		addi a4, a4, 1
		sw a4, 4(a2)
		
		lw a4, -28(a2)
		addi a4, a4, 1			#adiciona +1 para as 5 posicoes perto da bomba
		sw a4, -28(a2)
		
		lw a4, -32(a2)
		addi a4, a4, 1
		sw a4, -32(a2)
		
		lw a4, -36(a2)
		addi a4, a4, 1
		sw a4, -36(a2)
		j RetBomb
						#------------------------------------------------------------------
L8C1:		lw a4, 4(a2)			#Adiciona +1 para as 3 posicoes perto do canto inferior esquerdo
		addi a4, a4, 1
		sw a4, 4(a2)
		
		lw a4, -32(a2)
		addi a4, a4, 1
		sw a4, -32(a2)
		
		lw a4, -28(a2)
		addi a4, a4, 1
		sw a4, -28(a2)
		j RetBomb
		
						#------------------------------------------------------------------
L8C8:		lw a4, -4(a2)			#Adiciona +1 para as 3 posicoes perto do canto inferior direito
		addi a4, a4, 1
		sw a4, -4(a2)
		
		lw a4, -32(a2)
		addi a4, a4, 1
		sw a4, -32(a2)
		
		lw a4, -36(a2)
		addi a4, a4, 1
		sw a4, -36(a2)
		j RetBomb		
########################################################################################################## 
imprime_bomba:	
		la a0, space			#print de espaco em branco
		li a7, 4
		ecall
		
		la a0, space			#print de espaco em branco
		li a7, 4
		ecall
		
		la a0, space			#print de espaco em branco
		li a7, 4
		ecall
		
		li t0, 1
		li a1, 8

PrintFor:	bgt t0, a1 IDK			#print os numeros das colunas
		lw a0, NCol
		li a7, 1
		ecall
		la a0, NCol			
		sw t0, 0(a0)
		
		la a0, space			#print de espaco em branco
		li a7, 4
		ecall
		la a0, space			#print de espaco em branco
		li a7, 4
		ecall
		
		addi t0, t0, 1
		j PrintFor

IDK:		
		
		la a0, blankline		
		li a7, 4			#printa linha em branca
		ecall
		
		
		addi 	t0, zero, 0		
		la 	a0, NCol
		
		sw	t0, 0(a0)
		la 	a0, CHidden		
		addi	a1, zero, 8		#carrega em a1 o numero de linhas
		addi	t1, zero, 1		#carrega t0 e t1 com 1 para o For
		addi	t0, zero,1
		mv 	a2, a0			#carrega em a2 o endereco do campo
		li	t6, 45			#carrega 45 para ver se � um -
		li 	t5, 250			#carrega 250 para ver se � um numero
		li	s2, 66			#carrega com 66 para ver se � uma bomba

for3:		bgt t0, a1, input		#for de t0<a1 (1<8)
		la a0, space			#print de espaco em branco
		li a7, 4
		ecall

		lw a0, NCol
		li a7, 1
		ecall
		la a0, NCol			
		sw t0, 0(a0)
		la a0, space			#print de espaco em branco
		li a7, 4
		ecall


for4:		bgt t1, a1, endfor4		#for de t1<a1 (1<8) pula pro final do 2o for
		lw a0, 0(a2)
		
		beq a0, s2, PrintB		#se for uma bomba
		beq a0, t6, PrintC		#se for um traco ele pula
		bge t5, a0, PrintN		#se for um N ele pula
		
PrintB:		
		mv a0, a2
		li a7, 4			#printa o valor que esta no endereco de a2 que vai ser uma letra
		ecall
		
		j EndPrint
		
PrintC:		
		li a7, 11
		ecall				#printa o valor que esta no endereco de a2 que vai ser um -
		j EndPrint

PrintN:		
		li a7, 1			#printa o valor que esta no endereco de a2 que vai ser um numero
		ecall
		
		
EndPrint:		
		addi a2, a2, 4			#avanca 1 posicao em a2
		
		addi t1, t1, 1			#aumenta em 1 o t1
		
		la a0, space			#print de espaco em branco
		li a7, 4
		ecall
		la a0, space			#print de espaco em branco
		li a7, 4
		ecall
	
		j for4				#retorna para o comeco do for2
	
endfor4:	addi t0, t0, 1			#aumenta em 1 o t2
		addi t1, zero, 1		#'seta' para 1 o t1
		
		la a0, blankline		
		li a7, 4			#printa linha em branca
		ecall
		j for3				#pula para o comeco do for1

################################################################################################################################
input:
		li t0, 8
		li t1, 2
		beq t0, s5, end			#verifica se n � game over
		beq t1, s4  win			#verifica se ganhou
		
		la a0, NCol			
		li t0, 0
		sw t0, 0(a0)
		
		
		la a0, blankline		
		li a7, 4			#printa linha em branca
		ecall
		
		la a0, Output0			#printa para o usuario selecionar uma opcao
		li a7, 4
		ecall
		
		la a0, blankline		
		li a7, 4			#printa linha em branca
		ecall
		
		li a0, 0
		li, a7, 5
		ecall
		li t0, 1
		li t1, 2
		
		mv a5, a0
		beq a0, t0 Select
		beq a0, t1, Select
		
		
		la a0, blankline		
		li a7, 4			#printa linha em branca
		ecall
		
		la a0, Output3
		li a7,4				#Caso o usuario tenha digitado algo diferente de 1,2
		ecall
		j input
#######################################################################################################		
Select:					#Funcao para o usuario selecionar a posicao que quer abrir
		
		
		li t0,7				#t0 serve para verificar se o usuario n digitou um numero maior doq o numero de colunas/linhas
		
		la a0, blankline		
		li a7, 4			#printa linha em branca
		ecall
		
		la a0, Output1			#Usuario digitar a linha
		li a7, 4
		ecall
		
		la a0, blankline		
		li a7, 4			#printa linha em branca
		ecall
		
		li a0, 0
		li a7, 5
		ecall
		mv a1, a0			#move a linha em a0 para a1
		
		la a0, blankline		
		li a7, 4			#printa linha em branca
		ecall
		
		la a0, Output2			#usuario digitar a coluna
		li a7, 4
		ecall
		
		la a0, blankline		
		li a7, 4			#printa linha em branca
		ecall
		
		li a0, 0
		li a7, 5
		ecall
		mv a2, a0			#move a coluna de a0 para a2
						######pegar a posicao########
		bgt a2, t0, PosERROR
		bgt a1, t0, PosERROR
		
		addi t1, zero, 8		#8 colunas totais no campo
		mul a1, a1, t1			#Multiplica o total de colunas com a coluna passada 
		add a1, a1, a2			#Soma com a linha passada
		addi t1, zero, 4		
		mul a1, a1, t1			#Multiplica por 4 para saber a posicao na memoria
						############################

		
		j ShowCamp
		
########################################################################################################
ShowCamp:	
		addi t1, zero, 0
		addi t0, zero, 0
		addi a2, zero, 7
		addi t3, zero, 0
		addi t4, zero, 9
		addi t5, zero, 100
		addi t6, zero, 2
		addi s0, zero, 200
		la a3, campo
		la a4, CHidden		#carrega pra saber a posicao que precisa substituir os valores

SFor:		bgt t0, a2, imprime_bomba
SFor2:		bgt t1, a2, Sforend

		lw a0, 0(a3)
		beq t3, a1, found
		addi t3, t3, 4		#encontrar a posicao na matriz
		addi a3, a3, 4		#avanca uma posicao no campo	
		addi a4, a4, 4		#avanca uma posicao no campo do print
		addi t1, t1, 1
		j SFor2
Sforend:	
		addi t0, t0, 1
		addi t1, zero, 0						
		j SFor								
######################################Encontrou a posicao###############################################################												
found:		
		bge a0, s0, RmvFlag	#verifica se a posicao � uma flag
		bge a0, t5, PosERROR	#verifica se a posicao ja n foi aberta
		beq t6, a5, flag	#verifica se o usuario queria colocar uma bandeira
		bge a0,t4, gameover	#verifica se � uma bomba
		
		sw a0, 0(a4)		#substitui o valor que esta no campo para o campo do print
		li t6, 100
		lw t5, 0(a3)
		add t5, t5, t6
		sw t5, 0(a3)		#substui o valor aberto por +100
		addi s4, s4, 1
		
		j imprime_bomba																
																				
######################################Posicao ja aberta######################################################################		
PosERROR:
		la a0, blankline		
		li a7, 4			#printa linha em branca
		ecall
		
		la a0, Output6
		li a7, 4			#printa pro usuario colocar uma posicao valida
		ecall
		j Select


###################################################add flag##########################################################
flag:		
		lw a0, Flg
		sw a0, 0(a4)		#Substitui o valor do campo print por F
		lw t5, 0(a3)
		li t6, 200
		add t5, t5, t6
		sw t5, 0(a3)		#substui o valor aberto por +200
		j imprime_bomba
####################################################remove flag############################################################
RmvFlag:
		li t0, 2 
		bne t0, a5, PosERROR   #evita que o usuario tente abrir uma flag
		
		lw a0, Hifen
		sw a0, 0(a4)	#substitui o F por -		
		lw t5, 0(a3)
		li t6, 200
		sub t5, t5, t6
		sw t5, 0(a3)
		j imprime_bomba		#substitui o valor aberto por -200

#######################################################################se perdeu#########################################
gameover:	
		
		la a0, blankline		
		li a7, 4			#printa linha em branca
		ecall
		
		la a0, Output4
		li a7, 4
		ecall
		
		li t0, 1
		li a1, 64
		li t1, 9
		li t2, 100
		la a3, campo		
		la a4, CHidden
		li s5, 8			#indica q � game over
		
		
		la a0, blankline		
		li a7, 4			#printa linha em branca
		ecall
	##############Substitui os valores dos - por B e as bombas por perto para o ultimo print###################	
GOfor:		
		bgt t0, a1, imprime_bomba
		lw a0, 0(a3)
		
		bge a0, t2, isFlagN		#se a posicao � uma flag ou ja foi aberta
		bge a0, t1, isBomb		#se a posicao � uma bomba
		sw  a0, 0(a4)
		j isFlagN
		
isBomb:						
		lb a0, BMB			#troca o numero por B
		sb a0, 0(a4)
isFlagN:		
		addi t0, t0, 1
		addi a3, a3, 4
		addi a4, a4, 4
		
		j GOfor
########################################################################################################################		
win:		
		la a0, blankline		
		li a7, 4			#printa linha em branca
		ecall
		
		la a0, Output7
		li a7, 4			#printa que ganhou
		ecall

end:		nop

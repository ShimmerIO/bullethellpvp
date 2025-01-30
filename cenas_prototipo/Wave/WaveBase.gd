extends Node

#Pra fazer uma wave, você tem que encontrar os padrões que você quer, e escrever eles como uma array
#na qual a primeira entrada é o índice, e a segunda a dificuldade, 0 = FÁCIL, 1 = MÉDIO, 2 = MÓDIFÍCIL
# ou seja, o Padrão4 MÉDIO seria a array [4,1]
# depois disso, você tem que colocar quanto tempo você quer que o padrão fique ativo, por exemplo, 5.0
# é bom colocar .0 por que tempo é float, previne erro mais tarde
#depois disso, você coloca ele como a array inteira, com a primeira entrada sendo a array do padrão
#e a segunda entrada sendo o tempo, então no nosso exemplo ficaria [[4,1],5.0]
#depois disso, coloca PatternToSend.append(), com a array final dentro
#o exemplo completo vai ficar ali, deletar ele e esse comentário depois
# pra colocar mais padrões só coloca abaixo, ele vai colocar em ordem, o primeiro como primeiro
#segundo como segundo, etc.

static func send_pattern():
	var PatternToSend:Array
	PatternToSend.append([[4,1],5.0])
	return PatternToSend

require 'matrix'

class Matrix
  def setElement(i, j, x)
  @rows[i][j] = x
 end
end


# m.element(1,1)
#m = Matrix.rows(m.to_a << [1,0])
#i =  Matrix.identity(2)

#puts(m * Matrix[[2,2],[2,2]])
# b = Matrix.column_vector(m);

def relativeCosts(a, transposedLambda, nonBasicCosts, nonBasicVariabels)
  relativeCostsNonBasic = []

  for i in (0...nonBasicCosts.column_count) do
    relativeCostsNonBasic << (nonBasicCosts.column(i) - transposedLambda * a.column(nonBasicVariabels[i])).to_a
    relativeCostsNonBasic[i] = relativeCostsNonBasic[i][0].to_f
  end

  relativeCostsNonBasic
end

def multiplicatorSimplexArray(c,basic)
  # puts basic.row_count,basic.column_count,c.row_count,c.column_count
  c.transpose*basic.inverse
end   

def basicSolition(basicVariabels, nonBasicVariabels, basic, nonBasic,b)
  result = (basic.inverse * b.transpose)

  xB = []  

  for i in (0...result.row_count) do
  xB << result.element(i,0).to_f
  end

  xN = Array.new(nonBasic.size,0)

  xHat =[]
  for i in (0..xB.size + xN.size) do
    xHat[] = 
  end
  return xB, xN
end

numberOfVariables = 2
numberOfRestrictions = 2

_colums = 2
_rows = 2

# m = Matrix.build(numberOfVariables,numberOfRestrictions){|x| 
#   x = gets.chomp.to_f
#   x = numberOfRestrictions
# }

#Use Exemplo 
#Min -x1 -x2
#sa:
#2x1+1<=8
#x1+2x2<=3

a = Matrix[[2,1],[1,2]]
b = Matrix[[8,3]]
costs = Matrix[[-1,-1]]

#Aumentando matriz A
a = Matrix.hstack(a,Matrix.identity(numberOfRestrictions));
#Aumentando a matriz dos custos
costs = Matrix.hstack(costs,Matrix.build(1,numberOfRestrictions){0})

#Colocando nas variaveis nao basicas as variaveis da matriz a
nonBasicVariabels = (0...numberOfRestrictions).to_a
#Colocando na base as variaveis que formam a identidade
basicVariabels = (numberOfRestrictions..a.column_count-1).to_a

#Colocando as colunas das variaveis nao basicas na matrix variavel nao basica
nonBasicMatrix = []
nonBasicCosts = []
for i in (0...nonBasicVariabels.size) do
  nonBasicMatrix << a.column(nonBasicVariabels[i]).to_a
  nonBasicCosts << costs.column(nonBasicVariabels[i]).to_a
end

#Colocando as colunas das variaveis basicas na matrix variavel basica
basicMatrix = []
basicCosts = []
for i in (0...basicVariabels.size) do
  basicMatrix << a.column(basicVariabels[i]).to_a
  basicCosts << costs.column(basicVariabels[i]).to_a
end

#Passo 1: {cálculo da solução básica}
xHatBasics , xHatNonBasics, xHat = basicSolition(Matrix.columns(basicMatrix),nonBasicMatrix,b) 

#Passo 2: {cálculo dos custos relativos}

#(2.1) {vetor multiplicador simplex}
transposedLambda = multiplicatorSimplexArray(Matrix.rows(basicCosts),Matrix.columns(basicMatrix));
puts transposedLambda

#(2.2) {custos relativos}
costsHatNonBasic = relativeCosts(a, transposedLambda, Matrix.columns(nonBasicCosts), nonBasicVariabels)
puts costsHatNonBasic.inspect

# (2.3) {determinação da variável a entrar na base}

basicMatrix = Matrix.columns(basicMatrix)
# basicMatrix = Matrix.build(basicVariabels.size){0}
# for i in (0..basicVariabels.size) do
#   basicMatrix = a.column(basicVariabels[i])
# end


# a = Matrix.hstack(m,Matrix.identity(numberOfRestrictions))
# b = Matrix[a.column(basicVariabels[0]).to_a,a.column(basicVariabels[1]).to_a]


# for i in (0...numberOfRestrictions) do
#   m << a.row(i).to_a
# end

# puts m.class

# t = Matrix.rows([m])

# puts t
#  for i in (0..numberOfRestrictions) do
#    t.setElement(i,0,99) 
#  end


#a.map{ puts a}

#a.each do |column|
#  puts column[0]
#end
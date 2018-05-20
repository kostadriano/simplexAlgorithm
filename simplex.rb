require 'matrix'
require 'pp'

def updateMatrix(basicMatrix,nonBasicMatrix,k,l)
  temp = basicMatrix[l]
  basicMatrix[l] = nonBasicMatrix[k] 
  nonBasicMatrix[k] = temp
  
  return basicMatrix, nonBasicMatrix
end

def updateCosts(basicVariabels, nonBasicVariabels,k,l,basicCosts,nonBasicCosts,costs)

  temp = basicVariabels[l]
  basicVariabels[l] = nonBasicVariabels[k]
  nonBasicVariabels[k] = temp

  for i in (0...nonBasicVariabels.size) do
    nonBasicCosts[i] = costs.column(nonBasicVariabels[i]).to_a
  end
  
  for i in (0...basicVariabels.size) do
    basicCosts[i] = costs.column(basicVariabels[i]).to_a
  end

  return basicVariabels, nonBasicVariabels, basicCosts, nonBasicCosts
end

def variabelLeavesBase(y, xB)
  if(y.to_a.min <= 0)
    abort("problema não tem solução ótima finita f (x) → −∞ ")
  end

  y = y.to_a

  temp = []
  for i in (0...xB.size) do
    temp << xB[i]/y[i].to_f
  end

  temp.each_with_index.min
end

def simplexDirection(basicMatrix,k,a)
  basicMatrix.inverse * a.column(k)
end

def variabelEntryBase(costsHatNonBasic)
  costsHatNonBasic.each_with_index.min
end

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

def basicSolition(basicVariabels, nonBasicVariabels, basicMatrix, nonBasic,b)
  result = (basicMatrix.inverse * b.transpose)

  xB = []  
  for i in (0...result.row_count) do
  xB << result.element(i,0).to_f
  end

  xN = Array.new(nonBasic.size,0)

  xHat = Array.new(xB.size + xN.size,0)
  for i in (0...basicVariabels.size) do
    xHat[basicVariabels[i]] = xB[i]  
  end

  for i in (0...nonBasicVariabels.size) do
    xHat[nonBasicVariabels[i]] = xN[i]  
  end

  return xB, xN, xHat
end

numberOfVariables = 2
numberOfRestrictions = 2

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

it = 1
loop do
  puts "\nIteracao #{it}"
  puts "Variaveis da Base = #{basicVariabels.inspect}"
  puts "Variaveis nao Basicas = #{nonBasicVariabels.inspect}"
  

  print "Base = "
  puts basicMatrix.transpose.inspect  
  
  #Passo 1: {cálculo da solução básica}
  xHatBasics , xHatNonBasics, xHat = basicSolition(basicVariabels,nonBasicVariabels,Matrix.columns(basicMatrix),nonBasicMatrix,b) 
  puts "X^ = #{xHat}"

  #Passo 2: {cálculo dos custos relativos}

  #(2.1) {vetor multiplicador simplex}
  transposedLambda = multiplicatorSimplexArray(Matrix.rows(basicCosts),Matrix.columns(basicMatrix));
  puts "Lambda Transposto = #{transposedLambda.map(&:to_f).to_a}"

  #(2.2) {custos relativos}
  costsHatNonBasic = relativeCosts(a, transposedLambda, Matrix.columns(nonBasicCosts), nonBasicVariabels)
  puts "Custo relativo das nao basicas = #{costsHatNonBasic.inspect}"

  # (2.3) {determinação da variável a entrar na base}
  cnk, k = variabelEntryBase(costsHatNonBasic)
  puts "Ĉnk = #{cnk}; k = #{k}"

  # Passo 3: {teste de otimalidade}
  if cnk>=0
    puts "\nA solucao atual eh a otima"
    puts "X^ = #{xHat}"

    solution = 0
    for i in (0...xHat.size) do
      solution += costs.element(0,i) * xHat[i]
    end

    puts "Solution #{solution}"
    exit
  end

  # Passo 4: {cálculo da direção simplex}
  y = simplexDirection(Matrix.columns(basicMatrix),k,a)
  puts "Direcao Simplex y = #{costsHatNonBasic.inspect}"

  # Passo 5: {determinação do passo e variável a sair da base}
  episolom, l = variabelLeavesBase(y,xHatBasics)
  puts "ε = #{episolom}, l = #{l}"

  # Passo 6: {atualização: nova partição básica, troque a l-ésima coluna de B pela k-ésima
  #   coluna de N}
  basicMatrix, nonBasicMatrix = updateMatrix(basicMatrix,nonBasicMatrix,k,l)
  basicVariabels, nonBasicVariabels, basicCosts, nonBasicCosts = updateCosts(basicVariabels, nonBasicVariabels,k,l, basicCosts, nonBasicCosts,costs)
  
  it = it+1
end

require 'matrix'
require 'pp'
require 'bigdecimal'
class Simplex
  def initialize(numberOfVariables, numberOfRestrictions, a, b, isMax, costs, basicVariabels, nonBasicVariabels, isArtificialProblem, artificialVariables,flag)
    @a = a
    @numberOfVariables = numberOfVariables
    @numberOfRestrictions = numberOfRestrictions
    @b = b
    @isMax = isMax
    @costs = costs
    @nonBasicVariabels = nonBasicVariabels
    @basicVariabels = basicVariabels
    @isArtificialProblem = isArtificialProblem
    @artificialVariables = artificialVariables
    @flag = flag
  end

  def updateMatrix(basicMatrix,nonBasicMatrix,k,l)
    basicMatrix[l],nonBasicMatrix[k] = nonBasicMatrix[k],basicMatrix[l] 
    
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
    if(y.to_a.max <= 0)
      abort("problema não tem solução ótima finita f (x) → −∞ ")
    end
  
    y = y.to_a
  
    temp = []
    for i in (0...xB.size) do
      if(y[i].to_f > 0)
        temp << xB[i]/y[i].to_f
      else
        temp << BigDecimal('Infinity')
      end
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
      # nonBasicCosts.column(i) - (transposedLambda * a.column(nonBasicVariabels[i])
      relativeCostsNonBasic << (nonBasicCosts.column(i) - (transposedLambda * a.column(nonBasicVariabels[i]))).to_a
      relativeCostsNonBasic[i] = relativeCostsNonBasic[i][0].to_f
    end
  
    relativeCostsNonBasic
  end
  
  def multiplicatorSimplexArray(c,basic)
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

  def calculate
    a = Matrix.rows(@a)
    b = Matrix.rows([@b])
    costs = Matrix.rows([@costs])
    
    numberOfRestrictions = @numberOfRestrictions
    numberOfVariables = @numberOfVariables

    if(@flag)
      #Aumentando matriz A
      a = Matrix.hstack(a,Matrix.identity(numberOfRestrictions));
    end

    #Aumentando a matriz dos custos
    # costs = Matrix.hstack(costs,Matrix.build(1,numberOfRestrictions){0})
    puts "\nA:"
    puts a.to_a.map(&:inspect)
      
    #Colocando nas variaveis nao basicas as variaveis da matriz a
    nonBasicVariabels = @nonBasicVariabels
    #Colocando na base as variaveis que formam a identidade
    basicVariabels = @basicVariabels
    
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
    
      puts "Base = "
      puts basicMatrix.to_a.map(&:inspect)
      
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
        if(@isArtificialProblem)
          basicVariabels.each do |x| 
            if !(@artificialVariables.include? x)
              _nonBasicVariabels = []
              for i in 0...nonBasicVariabels.size do
                if !(@artificialVariables.include? (nonBasicVariabels[i]))
                  _nonBasicVariabels << nonBasicVariabels[i]
                end
              end
              return basicVariabels, _nonBasicVariabels
            end
          end
          abort("problema não tem solução ótima finita f (x) → −∞ ")
        end

        puts "\nA solucao atual eh a otima"
        puts "X^ = #{xHat}"
    
        solution = 0
        for i in (0...xHat.size) do
          solution += costs.element(0,i) * xHat[i]
        end

        solution = @isMax ? -solution : solution
    
        puts "Solution #{solution}"
        exit
      end
    
      # Passo 4: {cálculo da direção simplex}
      y = simplexDirection(Matrix.columns(basicMatrix),k,a)
      puts "Direcao Simplex y = #{y.inspect}"
    
      # Passo 5: {determinação do passo e variável a sair da base}
      episolom, l = variabelLeavesBase(y,xHatBasics)
      puts "ε = #{episolom}, l = #{l}"
    
      # Passo 6: {atualização: nova partição básica, troque a l-ésima coluna de B pela k-ésima
      #   coluna de N}
      basicMatrix, nonBasicMatrix = updateMatrix(basicMatrix,nonBasicMatrix,k,l)
      basicVariabels, nonBasicVariabels, basicCosts, nonBasicCosts = updateCosts(basicVariabels, nonBasicVariabels,k,l, basicCosts, nonBasicCosts,costs)
      
      it = it+1
    end  
  end  

  def self.bIsNegative(b,arrayOfRestrictions,a)
    b.map!.with_index{|x,i| 
      if x<0
        a[i].map!{|n| n*-1}
        arrayOfRestrictions[i] = arrayOfRestrictions[i] == ">=" ? "<=" : ">="
        -1*x
      else
        1*x 
      end
    }
  end
  def self.main
    puts("Problema: ")
    problem = gets.chomp.split(" ")
    originalCosts = problem[(1...problem.size)].map(&:to_f)

    isMax = problem[0] == "max" ? true : false;

    puts("Numero de restricoes: ")
    numberOfRestrictions = gets.to_i

    numberOfVariables = problem.size-1

    a = []
    arrayOfRestrictions = []
    b = []
    puts ("Restricoes: ")
    for i in (0...numberOfRestrictions) do
      restrictions = gets.chomp.split(" ")

      a << restrictions[(0...numberOfVariables)].map(&:to_f)
      arrayOfRestrictions << restrictions[-2]
      b << restrictions[-1].to_f  
    end

    # a = [[-1,1],[1,1],[2,-1]]
    # b = [3,27,-3]
    # arrayOfRestrictions = [">=","<=","<="]

    b = bIsNegative(b,arrayOfRestrictions,a)

    if(isMax)
      for i in 0...originalCosts.size do
        originalCosts[i] = originalCosts[i]*-1
      end
    end

    isArtificialProblem = false;

    if((arrayOfRestrictions.include? ('>=')) || (arrayOfRestrictions.include? ('='))) 
      isArtificialProblem = true;
    end

    if(isArtificialProblem)
      for i in 0...a.size do
        if(arrayOfRestrictions[i] != '=')
          for j in 0...numberOfRestrictions do
            a[i] << 0
          end
        end
        if(arrayOfRestrictions[i] == '>=')
          a[i][numberOfVariables+i] = -1
        end
        if(arrayOfRestrictions[i] == '<=')
          a[i][numberOfVariables+i] = 1
        end
      end
    end

    for i in 0...a[0].size-numberOfVariables do
      originalCosts << 0
    end

    if(!isArtificialProblem)
      #Colocando nas variaveis nao basicas as variaveis da matriz a
      nonBasicVariabels = (0...numberOfVariables).to_a
      #Colocando na base as variaveis que formam a identidade
      basicVariabels = (numberOfVariables...a[0].size-numberOfVariables).to_a
    else
      nonBasicVariabels = (0...a[0].size).to_a
      basicVariabels = (nonBasicVariabels.size...nonBasicVariabels.size+numberOfRestrictions).to_a
      artificialVariables = (nonBasicVariabels.size...nonBasicVariabels.size+numberOfRestrictions).to_a

      costs = originalCosts.collect{|x| x*0} 
      for i in 0...numberOfRestrictions do
        costs << 1
      end
    end

    flag = true

    if(isArtificialProblem)
      puts "FASE I"
      simplex = Simplex.new(numberOfVariables, numberOfRestrictions, a, b, isMax, costs, basicVariabels, nonBasicVariabels, true, artificialVariables,true)
      basicVariabels, nonBasicVariabels = simplex.calculate
      flag = false
    end

    puts "\nFASE II"
    simplex = Simplex.new(numberOfVariables, numberOfRestrictions, a, b, isMax, originalCosts, basicVariabels, nonBasicVariabels, false, artificialVariables,flag)
    simplex.calculate
  end
end

Simplex.main
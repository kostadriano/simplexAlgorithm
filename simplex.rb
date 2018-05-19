require 'matrix'

# m.element(1,1)
#m = Matrix.rows(m.to_a << [1,0])
#i =  Matrix.identity(2)

#puts(m * Matrix[[2,2],[2,2]])
# b = Matrix.column_vector(m);

=begin
def multiplicatorSimplexArray(c,basic)
  c.transpose*basic.inverse
end   

def basicSolition(basic,b)
  xB = basic.inverse * b
  xN.map!{|x| x = 0}
end
=end
numberOfVariables = 2
numberOfRestrictions = 2

_colums = 2
_rows = 2

m = Matrix.build(numberOfVariables,numberOfRestrictions){|x| 
  x = gets.chomp.to_f
  #x = numberOfRestrictions
}
basicVariabels = [0,1,2]

a = Matrix.hstack(m,Matrix.identity(numberOfRestrictions))
b = Matrix[a.column(basicVariabels[0]).to_a,a.column(basicVariabels[1]).to_a]

#puts a.row(1).class
 puts b
# m = Matrix.rows(m << Matrix.identity(2))
puts a

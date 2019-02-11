require 'parser'
require 'ast'

class Calculator
  attr_accessor :memory, :vars

  def initialize
    @memory = 0
    @vars = {}
  end

  def eval(expr)
    parser = Parser.new(StringIO.new(expr))
     ast = parser.parse()
    return ast.evaluate()
  end

  def compileInicial
    valor = @memory.to_s
    return "\t\t\t#Instrucciones antes del recorrido del arbol abstracto sintactico\nSTART:\n\t\t\tSP := 4000\n\t\t\tONE := 1\n\t\t\tZERO := 0\n\t\t\tmemory := " + valor + "\n"
  end

  def compile expr
    expr1 = expr
    if expr == "\n" then expr1 = "" end
    valor = @memory.to_s
    inicio = "\t\t\t# Expresion " + expr1 
    var = ""
    n = ""
    @vars.each do  |clave, valor|
    #  valor = ""
      n = clave
      var = var + "" + n + " := " + valor.to_s + "\n"
    end

    inicio = inicio + var

    parser = Parser.new(StringIO.new(expr))
    ast = parser.parse
    return inicio + ast.compile + "\n\t\t\t# Write Result\n\t\t\tR0 := M[SP+0]\n\t\t\tSP := SP - ONE\n\t\t\twriteInt(R0)\n";
  end

  def compileFinal
    final = "END:\n\t\t\thalt\nequ memory M[0]\nequ ONE M[1]\nequ ZERO M[2]\nequ R0 M[3]\nequ R1 M[4]\nequ SP M[5]\n";
    var = ""
    n = ""
    acum = 6
    valor = ""
    @vars.each do  |clave, valor|
      n = clave
      valor = ""
      valor = acum.to_s
      var = var + "equ " + n + " M[" + valor + "]\n"
      acum = acum + 1
    end
    return final + var + "equ stack M[1000]\n"
  end
end

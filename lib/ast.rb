require 'set'

class BinaryNode
  attr_reader :left, :right

  def initialize left,right
    @left = left
    @right = right
  end
end

class UnaryNode
  attr_reader :subTree

  def initialize subTree
    @subTree = subTree
  end
end

class AddNode < BinaryNode
  def initialize left, right
    super(left,right)
  end
  def evaluate
    @left.evaluate + @right.evaluate
  end

  def compile
    line = @left.compile + @right.compile
    return line + "\t\t\t# AddNode\n\t\t\tR1 := M[SP+0]\n\t\t\tR0 := M[SP+1]\n\t\t\tR0 := R0 + R1\n\t\t\tSP := SP + ONE\n\t\t\tM[SP+0] := R0\n"
  end
end

class SubNode < BinaryNode
  def initialize left, right
    super left,right
  end

  def evaluate
    @left.evaluate - @right.evaluate
  end

  def compile
    line = @left.compile + @right.compile
    return line + "\t\t\t# AddNode\n\t\t\tR1 := M[SP+0]\n\t\t\tR0 := M[SP+1]\n\t\t\tR0 := R0 - R1\n\t\t\ttSP := SP + ONE\n\t\t\tM[SP+0] := R0\n"
  end
end

class TimesNode < BinaryNode
  def initialize left, right
    super left,right
  end

  def evaluate
    @left.evaluate * @right.evaluate
  end

  def compile
    line = @left.compile + @right.compile
    return line + "\t\t\t# AddNode\n\t\t\tR1 := M[SP+0]\n\t\t\tR0 := M[SP+1]\n\t\t\tR0 := R0 * R1\n\t\t\tSP := SP + ONE\n\t\t\tM[SP+0] := R0\n"
  end
end

class DivideNode < BinaryNode
  def initialize left, right
    super left,right
  end

  def evaluate
    @left.evaluate / @right.evaluate
  end

  def compile
    line = @left.compile + @right.compile
    return line + "\t\t\t\t# AddNode\n\t\t\t\tR1 := M[SP+0]\n\t\t\t\tR0 := M[SP+1]\n\t\t\t\tR0 := R0 / R1\n\t\t\t\tSP := SP + ONE\n\t\t\t\tM[SP+0] := R0\n"
  end
end

class ModNode < BinaryNode
  def initialize left, right
    super left,right
  end

  def evaluate
    @left.evaluate % @right.evaluate
  end

  def compile
    line = @left.compile + @right.compile
    return line + "\t\t\t\t# AddNode\n\t\t\t\tR1 := M[SP+0]\n\t\t\t\tR0 := M[SP+1]\n\t\t\t\tR0 := R0 % R1\n\t\t\t\tSP := SP + ONE\n\t\t\t\tM[SP+0] := R0\n"
  end
end

class NumNode
  def initialize num
    @num = num
  end

  def evaluate
    return @num
  end

  def compile
    line = @num.to_s
    return "\t\t\t\t#NumNode(" + line + ")\n\t\t\t\tSP := SP - ONE\n\t\t\t\tR0 := " + line + "\n\t\t\t\tM[SP+0] := R0\n";
  end
end

class StoreNode < UnaryNode
  def initialize sub
    super sub
  end
  
  def evaluate
    $calc.memory = @subTree.evaluate
  end

  def compile
    $calc.memory = @subTree.evaluate
    line = @subTree.compile
    return line + "# StoreNode\n\tmemory := M[SP+0]\n"
  end
end

class PlusNode < UnaryNode
  def initialize sub
    super sub
  end

  def evaluate
    $calc.memory = $calc.memory + @subTree.evaluate
  end

  def compile
    $calc.memory = $calc.memory + @subTree.evaluate
    line = @subTree.compile
    return line + "\t\t\t\t# PlusNode\n\t\t\t\tR1 := M[SP+0]\n\t\t\t\tmemory := memory + R1\n\t\t\t\tM[SP+0] := memory\n"
  end
end

class MinusNode < UnaryNode
  def initialize sub
    super sub
  end

  def evaluate
    $calc.memory = $calc.memory - @subTree.evaluate
  end

  def compile
    $calc.memory = $calc.memory - @subTree.evaluate
    line = @subTree.compile
    return line + "\t\t\t\t# MinusNode\n\t\t\t\tR1 := M[SP+0]\n\t\t\t\tmemory := memory - R1\n\t\t\t\tM[SP+0] := memory\n"  
  end
end

class RecallNode
  def evaluate
    $calc.memory
  end
  def compile
    return "\t\t\t\t# RecallNode\n\t\t\t\tSP := SP - ONE\n\t\t\t\tM[SP+0] := memory\n";
  end
end 

class CleanNode
  def evaluate
    $calc.memory = 0
  end

  def compile
    $calc.memory = 0
    return "\t\t\t\t# CleanNode\n\t\t\t\tmemory := ZERO\n\t\t\t\tSP := SP - ONE\n\t\t\t\tM[SP+0] := memory\n"
  end
end
 
class AssignableNode < UnaryNode
  def initialize id,sub
    super sub
    @id = id
  end

  def evaluate
    $calc.vars[@id]= @subTree.evaluate
  end

  def compile
    line = @subTree.compile
    $calc.vars[@id]= @subTree.evaluate
    return "\t\t\t\t" + line + "\t\t\t\t# AssignableNode\n\t\t\t\t" + @id + " := M[SP+1]\n"
  end

end

class IdentifierNode
  def initialize id
    @id = id
  end
  def evaluate
    unless ($calc.vars.key?(@id))
      return 0
    end
    return $calc.vars[@id]
  end

  def compile
    evaluate
    return "\t\t\t\t# IdentifierNode(" + @id + ")\n\t\t\t\tSP := SP - ONE\n\t\t\t\tR0 := " + @id + "\n\t\t\t\tM[SP+0] := R0\n"
  end
end

class Token
  attr_reader :type, :line, :col

  def initialize(type=:eof,line = 0,col = 0)
    @type = type
    @line = line
    @col = col
  end
end

class LexicalToken < Token
  attr_reader :lex

  def initialize(type,lex,line,col)
    super(type,line,col)

    @lex = lex
  end
end

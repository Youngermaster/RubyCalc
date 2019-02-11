require 'stringio'
require 'calcex'

class Scanner
  def initialize inStream
    @istream = inStream
    @keywords = Set.new(["S", "R", "M", "C", "P", "let"])
    @lineCount = 1
    @colCount = -1
    @needToken = true
    @lastToken = nil
  end

  def putBackToken
    @needToken = false
  end

  def getToken
    unless @needToken
      @needToken = true
      return @lastToken
    end

    state = 0
    foundOne = false
    
    if @istream.eof 
      @lastToken = Token.new(:eof,@lineCount,@colCount)
      return @lastToken
    end
    
    c = @istream.getc

    until foundOne
      @colCount = @colCount + 1
      case state
      when 0
        lex = ""
        column = @colCount
        line = @lineCount
        if isLetter(c) then state=1
        elsif isDigit(c) then state=2
        elsif c == ?+ then state = 3
        elsif c == ?- then state = 4
        elsif c == ?* then state = 5
        elsif c == ?/ then state = 6
        elsif c == ?( then state = 7
        elsif c == ?) then state = 8
        elsif c == ?% then state = 9
        elsif c == ?= then state = 10
        elsif c == ?\n then
          @colCount = -1
          @lineCount = @lineCount+1
        elsif isWhiteSpace(c) then state = state #ignore whitespace
        elsif @istream.eof or c.nil? 
          foundOne = true
          type = :eof
        else
          puts "* Scanner error"
          raise UnrecognizedTokenException # "Unrecognized Token"
      end
      when 1
        if isLetter(c) or isDigit(c) then state = 1
        elsif @keywords.include?(lex) then
          foundOne = true
          type = :keyword
        else
          foundOne = true
          type = :identifier
        end
      when 2
        if isDigit(c) then state = 2
        else
          type = :number
          foundOne = true
        end
      when 3
        type = :add
        foundOne = true
      when 4
        type = :sub
        foundOne = true
      when 5
        type = :times
        foundOne = true
      when 6
        type = :divide
        foundOne = true
      when 7
        type = :lparen
        foundOne = true
      when 8
        type = :rparent
        foundOne = true
      when 9
        type = :module
        foundOne = true 
      when 10
        type = :equal
        foundOne = true
      end
      unless foundOne
        lex.concat c
        c = @istream.getc
      end
    end

    @istream.ungetc(c)
    @colCount = @colCount - 1
    if type == :number or type == :identifier or type == :keyword then
      t = LexicalToken.new(type,lex,line,column)
    else
      t = Token.new(type,line,column)
    end

    @lastToken = t
    return t
  end

  private
  def isLetter c
    
    !c.nil? and ((?a <= c and c <= ?z) or (?A <= c and c <= ?Z))
  end

  def isDigit(c)
    !c.nil? and (?0 <= c and c <= ?9)
  end

  def isWhiteSpace(c)
    !c.nil? and (c == ?\  or c == ?\n or c == ?\t)
  end
end

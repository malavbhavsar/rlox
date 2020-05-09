# frozen_string_literal: true

class Scanner
  attr_accessor :source, :tokens, :start, :current, :line

  def initialize(source)
    @source = source
    @tokens = []
    @start = 0
    @current = 0
    @line = 1
  end

  def scan_tokens
    while !is_at_end?
      self.start = current
      scan_token
    end

    tokens << Token.new(Token::TYPE[:EOF], "", nil, line)

    tokens
  end

  private

  def is_at_end?
    current >= source.length
  end

  def advance
    self.current += 1
    source[current-1]
  end

  def add_token(type, literal = nil)
    text = source[start...current]
    tokens << Token.new(type, text, literal, line)
  end

  def scan_token
    char = advance

    case char
    when '('
      add_token(Token::TYPE[:LEFT_PAREN])
    when ')'
      add_token(Token::TYPE[:RIGHT_PAREN])
    when '{'
      add_token(Token::TYPE[:LEFT_BRACE])
    when '}'
      add_token(Token::TYPE[:RIGHT_BRACE])
    when ','
      add_token(Token::TYPE[:COMMA])
    when '.'
      add_token(Token::TYPE[:DOT])
    when '-'
      add_token(Token::TYPE[:MINUS])
    when '+'
      add_token(Token::TYPE[:PLUS])
    when ';'
      add_token(Token::TYPE[:SEMICOLON])
    when '*'
      add_token(Token::TYPE[:STAR])
    end
  end
end

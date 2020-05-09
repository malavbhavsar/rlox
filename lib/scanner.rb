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

  def is_at_end?(offset = 0)
    (current + offset) >= source.length
  end

  def peek(offset = 0)
    return '\0' if is_at_end?(offset)
    source[current + offset]
  end

  def advance
    self.current += 1
    source[current-1]
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
    when '#' # I like Ruby style comments
      while peek != "\n" && !is_at_end? # Note: "\n" != '\n'
        advance
      end
    when '!'
      add_token(second_char_match?('=') ? Token::TYPE[:BANG_EQUAL] : Token::TYPE[:BANG])
    when '='
      add_token(second_char_match?('=') ? Token::TYPE[:EQUAL_EQUAL] : Token::TYPE[:EQUAL])
    when '<'
      add_token(second_char_match?('=') ? Token::TYPE[:LESS_EQUAL] : Token::TYPE[:LESS])
    when '>'
      add_token(second_char_match?('=') ? Token::TYPE[:GREATER_EQUAL] : Token::TYPE[:GREATER])
    when '/'
      if second_char_match?('/')
        while peek != "\n" && !is_at_end? # Note: "\n" != '\n'
          advance
        end
      else
        add_token(Token::TYPE[:SLASH])
      end
    when ' ', "\r", "\t"
      # no op
    when "\n"
      self.line += 1
    when '"'
      string
    when *(0..9).map(&:to_s)
      number
    else
      Rlox.error(line, "Unexpected character #{char}")
    end
  end

  def second_char_match?(expected)
    return false if is_at_end?
    return false unless source[current] == expected

    self.current += 1
    true
  end

  def add_token(type, literal = nil)
    text = source[start...current]
    tokens << Token.new(type, text, literal, line)
  end

  def string
    while peek != '"' && !is_at_end?
      self.line += 1 if peek == "\n"
      advance
    end

    Rlox.error(line, "Untemrinated string.") if is_at_end?

    # closing "
    advance

    # trim the surrounding quotes
    literal = source[(start+1)...(current-1)]
    add_token(Token::TYPE[:STRING], literal)
  end

  def number
    advance while is_digit?(peek)

    if peek == '.' && is_digit?(peek(1))
      # consume '.'
      advance

      advance while is_digit?(peek)

      add_token(Token::TYPE[:NUMBER], source[start...current].to_f)
    else
      add_token(Token::TYPE[:NUMBER], source[start...current].to_i)
    end


  end

  def is_digit?(char)
    char >= '0' && char <= '9'
  end
end

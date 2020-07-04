# frozen_string_literal: true

class Scanner
  DIGITS = (0..9).map(&:to_s)
  ALPHAS = ("a".."z").to_a + ("A".."Z").to_a + ["_"]

  attr_accessor :source, :tokens, :start, :current, :line

  def initialize(source)
    @source = source
    @tokens = []
    @start = 0
    @current = 0
    @line = 1
  end

  def scan_tokens
    until at_end?
      self.start = current
      scan_token
    end

    tokens << Token.new(Token::TYPE[:EOF], "", nil, line)

    tokens
  end

  private

  def at_end?(offset = 0)
    (current + offset) >= source.length
  end

  def peek(offset = 0)
    return '\0' if at_end?(offset)

    source[current + offset]
  end

  def advance
    self.current += 1
    source[current - 1]
  end

  def scan_token
    char = advance

    case char
    when "("
      add_token(Token::TYPE[:LEFT_PAREN])
    when ")"
      add_token(Token::TYPE[:RIGHT_PAREN])
    when "{"
      add_token(Token::TYPE[:LEFT_BRACE])
    when "}"
      add_token(Token::TYPE[:RIGHT_BRACE])
    when ","
      add_token(Token::TYPE[:COMMA])
    when "."
      add_token(Token::TYPE[:DOT])
    when "-"
      add_token(Token::TYPE[:MINUS])
    when "+"
      add_token(Token::TYPE[:PLUS])
    when ";"
      add_token(Token::TYPE[:SEMICOLON])
    when "*"
      add_token(Token::TYPE[:STAR])
    when "#" # I like Ruby style comments
      advance while peek != "\n" && !at_end?
    when "!"
      add_token(second_char_match?("=") ? Token::TYPE[:BANG_EQUAL] : Token::TYPE[:BANG])
    when "="
      add_token(second_char_match?("=") ? Token::TYPE[:EQUAL_EQUAL] : Token::TYPE[:EQUAL])
    when "<"
      add_token(second_char_match?("=") ? Token::TYPE[:LESS_EQUAL] : Token::TYPE[:LESS])
    when ">"
      add_token(second_char_match?("=") ? Token::TYPE[:GREATER_EQUAL] : Token::TYPE[:GREATER])
    when "/"
      if second_char_match?("/")
        advance while peek != "\n" && !at_end?
      else
        add_token(Token::TYPE[:SLASH])
      end
    when " ", "\r", "\t"
      # no op
    when "\n"
      self.line += 1
    when '"'
      string
    when *DIGITS
      number
    when *ALPHAS
      identifier
    else
      Rlox.error(line, "Unexpected character #{char}.")
    end
  end

  def second_char_match?(expected)
    return false if at_end?
    return false unless source[current] == expected

    self.current += 1
    true
  end

  def add_token(type, literal = nil)
    text = source[start...current]
    tokens << Token.new(type, text, literal, line)
  end

  def string
    while peek != '"' && !at_end?
      self.line += 1 if peek == "\n"
      advance
    end

    Rlox.error(line, "Unterminated string.") if at_end?

    # closing "
    advance

    # trim the surrounding quotes
    literal = source[(start + 1)...(current - 1)]
    add_token(Token::TYPE[:STRING], literal)
  end

  def number
    advance while digit?(peek)

    if peek == "." && digit?(peek(1))
      # consume '.'
      advance

      advance while digit?(peek)

      add_token(Token::TYPE[:NUMBER], source[start...current].to_f)
    else
      add_token(Token::TYPE[:NUMBER], source[start...current].to_i)
    end
  end

  def identifier
    advance while alphanumeric? peek

    type_sym = Token::RESERVED_KEYWORD_LEXEME_TO_TYPE[source[start...current]] || :IDENTIFIER
    add_token(Token::TYPE[type_sym])
  end

  def digit?(char)
    char >= "0" && char <= "9"
  end

  def alpha?(char)
    (char >= "a" && char <= "z") || char >= "A" && char <= "Z" || char == "_"
  end

  def alphanumeric?(char)
    digit?(char) || alpha?(char)
  end
end

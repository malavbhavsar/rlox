# frozen_string_literal: true

class Token
  SINGLE_CHAR_TYPE = {
    LEFT_PAREN: 1, RIGHT_PAREN: 2, LEFT_BRACE: 3, RIGHT_BRACE: 4,
    COMMA: 5, DOT: 6, MINUS: 7, PLUS: 8, SEMICOLON: 9, SLASH: 10, STAR: 11
  }.freeze

  SINGLE_OR_DOUBLE_CHAR_TYPE = {
    BANG: 12, BANG_EQUAL: 13,
    EQUAL: 14, EQUAL_EQUAL: 15,
    GREATER: 16, GREATER_EQUAL: 17,
    LESS: 18, LESS_EQUAL: 19
  }.freeze

  LITERAL_TYPE = {
    IDENTIFIER: 20, STRING: 21, NUMBER: 22
  }.freeze

  RESERVED_KEYWORD_TYPE = {
    AND: 23, CLASS: 24, ELSE: 25, FALSE: 26, FUN: 27, FOR: 28, IF: 29, NIL: 30, OR: 31,
    PRINT: 32, RETURN: 33, SUPER: 34, THIS: 35, TRUE: 36, VAR: 37, WHILE: 38
  }.freeze

  TYPE = {
    TOKEN_TYPE_DO_NOT_USE: 0,
    **SINGLE_CHAR_TYPE,
    **SINGLE_OR_DOUBLE_CHAR_TYPE,
    **LITERAL_TYPE,
    **RESERVED_KEYWORD_TYPE,
    EOF: 39
  }.freeze

  RESERVED_KEYWORD_LEXEME_TO_TYPE = RESERVED_KEYWORD_TYPE.map { |k, _| [k.to_s.downcase, k] }.to_h.freeze

  attr_reader :type, :lexeme, :literal, :line

  def initialize(type, lexeme, literal, line)
    @type = type
    @lexeme = lexeme
    @literal = literal
    @line = line
  end

  def to_s
    "#{TYPE.invert[type]} #{lexeme} #{literal}"
  end
end

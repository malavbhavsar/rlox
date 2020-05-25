# frozen_string_literal: true

class Parser
  ParseError = Class.new(RuntimeError)

  attr_reader :tokens, :current

  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def parse
    expression
  rescue ParseError => e
    nil
  end

  private

  ####################################
  # Recursive Descent hierarchy
  ####################################

  def expression
    equality
  end

  def equality
    expr = comparision

    while match(Token::TYPE[:BANG_EQUAL], Token::TYPE[:EQUAL_EQUAL])
      operator = previous
      right = comparision
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  def comparision
    expr = addition

    while match(Token::TYPE[:GREATER], Token::TYPE[:GREATER_EQUAL], Token::TYPE[:LESS], Token::TYPE[:LESS_EQUAL])
      operator = previous
      right = addition
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  def addition
    expr = multiplication

    while match(Token::TYPE[:MINUS], Token::TYPE[:PLUS])
      operator = previous
      right = multiplication
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  def multiplication
    expr = unary

    while match(Token::TYPE[:STAR], Token::TYPE[:SLASH])
      operator = previous
      right = unary
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  def unary
    if match(Token::TYPE[:BANG], Token::TYPE[:MINUS])
      operator = previous
      right = unary
      Expr::Unary.new(operator, right)
    else
      primary
    end
  end

  def primary
    return Expr::Literal.new(false) if match(Token::TYPE[:FALSE])
    return Expr::Literal.new(true) if match(Token::TYPE[:TRUE])
    return Expr::Literal.new(nil) if match(Token::TYPE[:NIL])
    return Expr::Literal.new(previous.literal) if match(Token::TYPE[:NUMBER], Token::TYPE[:STRING])

    if match(Token::TYPE[:LEFT_PAREN])
      expr = expression
      consume(Token::TYPE[:RIGHT_PAREN], "Expect ')' after expression.");
      return Expr::Grouping.new(expr)
    end

    raise error(peek, "Expect expression.")
  end

  ####################################
  # Helper methods
  ####################################

  def match(*types)
    match_found = check(*types)

    advance if match_found

    match_found
  end

  def check(*types)
    return false if is_at_end?
    return types.include?(peek.type)
  end

  def advance
    @current += 1 unless is_at_end?
    previous
  end

  def is_at_end?
    peek.type == Token::TYPE[:EOF]
  end

  def peek
    tokens[current]
  end

  def previous
    tokens[current - 1]
  end

  def consume(type, message)
    return advance if check(type)

    raise error(peek, message)
  end

  def error(token, message)
    Rlox.error(token, message)

    ParseError.new
  end
end
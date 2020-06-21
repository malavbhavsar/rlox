# frozen_string_literal: true

class Parser
  ParseError = Class.new(RuntimeError)

  attr_reader :tokens, :current

  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def parse
    statements = []
    statements << declaration until at_end?
    statements
  end

  private

  ####################################
  # Recursive Descent hierarchy
  ####################################

  def declaration
    return var_declaration if match(Token::TYPE[:VAR])

    statement
  rescue ParseError => e
    puts "error happened #{e}. TODO: implement synchronize"
    # synchronize # TODO: implement synchronize method
    nil
  end

  def var_declaration
    name = consume(Token::TYPE[:IDENTIFIER], "Expect variable name.")
    initializer = match(Token::TYPE[:EQUAL]) ? expression : nil

    consume(Token::TYPE[:SEMICOLON], "Expect ';' after variable declaration.")

    Stmt::Var.new(name, initializer)
  end

  def statement
    return for_statement if match(Token::TYPE[:FOR])
    return if_statement if match(Token::TYPE[:IF])
    return print_statement if match(Token::TYPE[:PRINT])
    return while_statement if match(Token::TYPE[:WHILE])
    return block_statement if match(Token::TYPE[:LEFT_BRACE])

    expression_statement
  end

  def for_statement
    consume(Token::TYPE[:LEFT_PAREN], "Expect '(' after for.")

    initializer = if match(Token::TYPE[:SEMICOLON])
                    nil
                  elsif match(Token::TYPE[:VAR])
                    var_declaration
                  else
                    expression_statement
    end

    condition = expression unless check(Token::TYPE[:SEMICOLON])
    consume(Token::TYPE[:SEMICOLON], "Expect ';' after loop condition.")

    increment = expression unless check(Token::TYPE[:RIGHT_PAREN])
    consume(Token::TYPE[:RIGHT_PAREN], "Expect ')' after for clauses.")

    body = statement

    body = Stmt::Block.new([body, Stmt::Expression.new(increment)]) unless increment.nil?

    condition = Expr::Literal.new(true) if condition.nil?
    body = Stmt::While.new(condition, body)

    body = Stmt::Block.new([initializer, body]) unless initializer.nil?

    body
  end

  def if_statement
    consume(Token::TYPE[:LEFT_PAREN], "Expect '(' after if.")
    condition = expression
    consume(Token::TYPE[:RIGHT_PAREN], "Expect ')' after if condition.")
    then_branch = statement
    else_branch = statement if match(Token::TYPE[:ELSE])

    Stmt::If.new(condition, then_branch, else_branch)
  end

  def print_statement
    value = expression
    consume(Token::TYPE[:SEMICOLON], "Expect ';' after value.")
    Stmt::Print.new(value)
  end

  def while_statement
    consume(Token::TYPE[:LEFT_PAREN], "Expect '(' after 'while'.")
    condition = expression
    consume(Token::TYPE[:RIGHT_PAREN], "Expect ')' after condition.")
    body = statement

    Stmt::While.new(condition, body)
  end

  def block_statement
    statements = []

    statements.push(declaration) while !check(Token::TYPE[:RIGHT_BRACE]) && !at_end?

    consume(Token::TYPE[:RIGHT_BRACE], "Expect '}' after block.")

    Stmt::Block.new(statements)
  end

  def expression_statement
    expr = expression
    consume(Token::TYPE[:SEMICOLON], "Expect ';' after expression.")
    Stmt::Expression.new(expr)
  end

  def expression
    assignment
  end

  def assignment
    expr = lox_or

    if match(Token::TYPE[:EQUAL])
      operator = previous
      right = assignment

      return Expr::Assign.new(expr.name, right) if expr.is_a?(Expr::Variable)

      error(operator, "Invalid assignment target.")
    end

    expr
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

  def lox_or
    expr = lox_and

    while match(Token::TYPE[:OR])
      operator = previous
      right = lox_and

      expr = Expr::Logical.new(expr, operator, right)
    end

    expr
  end

  def lox_and
    expr = equality

    while match(Token::TYPE[:AND])
      operator = previous
      right = equality

      expr = Expr::Logical(expr, operator, right)
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
    return Expr::Variable.new(previous) if match(Token::TYPE[:IDENTIFIER])

    if match(Token::TYPE[:LEFT_PAREN])
      expr = expression
      consume(Token::TYPE[:RIGHT_PAREN], "Expect ')' after expression.")
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
    return false if at_end?

    types.include?(peek.type)
  end

  def advance
    @current += 1 unless at_end?
    previous
  end

  def at_end?
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

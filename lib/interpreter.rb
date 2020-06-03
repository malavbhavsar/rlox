# frozen_string_literal: true

class Interpreter
  include Expr::Visitor
  include Stmt::Visitor

  def initialize
  end

  def interpret(statements)
    statements.each do |statement|
      execute(statement)
    end
  rescue RloxRuntimeError => error
    Rlox.runtime_error(error)
  end

  def execute(stmt)
    stmt.accept(self)
  end

  def evaluate(expr)
    expr.accept(self)
  end

  def visit_expression_stmt(stmt)
    evaluate(stmt.expression)
  end

  def visit_print_stmt(stmt)
    value = evaluate(stmt.expression)
    puts value
  end

  def visit_binary_expr(expr)
    operator = expr.operator
    left = evaluate(expr.left)
    right = evaluate(expr.right)

    # Ruby handles most of these operations sufficiently well without needing typecast. e.g.
    # 2.7.0 :001 > (3 * 3).class
    #  => Integer
    # 2.7.0 :002 > (3 * 3.0).class
    #  => Float
    #
    # This is probably nounced than I am giving it thought. I am sure a seasoned language designer would scoff at this
    # approach but I think it is okay for learning!
    #
    # I have similar dilemma about equality operator. Book tries to build the equality close to Java. Should I be
    # rebuilding that in ruby? Or should I just follow what Object#== does? What is difference between Java equality and
    # Object#== ? These are hard questions to answer for a newcomer. For now, sticking to Object#==.

    case operator.type
    when Token::TYPE[:GREATER]
      check_number_operands(operator, left, right)
      return left > right
    when Token::TYPE[:GREATER_EQUAL]
      check_number_operands(operator, left, right)
      return left >= right
    when Token::TYPE[:LESS]
      check_number_operands(operator, left, right)
      return left < right
    when Token::TYPE[:LESS_EQUAL]
      check_number_operands(operator, left, right)
      return left <= right
    when Token::TYPE[:MINUS]
      check_number_operands(operator, left, right)
      return left - right
    when Token::TYPE[:PLUS]
      if ((left.is_a?(Integer) || left.is_a?(Float)) && (right.is_a?(Integer) || right.is_a?(Float))) ||
        (left.is_a?(String) && right.is_a?(String))
        return left + right
      end
      raise RloxRuntimeError.new(operator, "Operands must be numbers.")
    when Token::TYPE[:SLASH]
      check_number_operands(operator, left, right)
      return left / right
    when Token::TYPE[:STAR]
      check_number_operands(operator, left, right)
      return left * right
    when Token::TYPE[:BANG_EQUAL]
      return left != right
    when Token::TYPE[:EQUAL_EQUAL]
      return left == right
    end
  end

  def visit_grouping_expr(expr)
    evaluate(expr.expression)
  end

  def visit_literal_expr(expr)
    expr.value
  end

  def visit_unary_expr(expr)
    right = evaluate(expr.right)

    case expr.operator.type
    when Token::TYPE[:MINUS]
      check_number_operands(expr.operator, right)
      return -right.to_f
    when Token::TYPE[:BANG]
      return !is_truthy?(right)
    end

    nil
  end

  private

  def check_number_operands(operator, *operands)
    return if operands.all? { |operand| operand.is_a?(Integer) || operand.is_a?(Float) }
    raise RloxRuntimeError.new(operator, "Operands must be numbers.")
  end

  def is_truthy?(expr)
    !!expr.value # Lox follows Ruby's rule for truthiness
  end
end

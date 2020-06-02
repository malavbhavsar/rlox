# frozen_string_literal: true

class Interpreter < Visitor
  def initialize
  end

  def evaluate(expression)
    expression.accept(self)
  end

  def visit_binary_expr(expr)
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

    case expr.operator.type
    when Token::TYPE[:GREATER]
      return left > right
    when Token::TYPE[:GREATER_EQUAL]
      return left >= right
    when Token::TYPE[:LESS]
      return left < right
    when Token::TYPE[:LESS_EQUAL]
      return left <= right
    when Token::TYPE[:MINUS]
      return left - right
    when Token::TYPE[:PLUS]
      if ((left.is_a?(Integer) || left.is_a?(Float)) && (right.is_a?(Integer) || right.is_a?(Float))) ||
        (left.is_a?(String) && right.is_a?(String))
        return left + right
      end
    when Token::TYPE[:SLASH]
      return left / right
    when Token::TYPE[:STAR]
      return left * right
    when Token::TYPE[:BANG_EQUAL]
      return left != right
    when Token::TYPE[:EQUAL_EQUAL]
      return left == right
    end
  end

  def visit_grouping_expr(expr)
    evaluate(expr)
  end

  def visit_literal_expr(expr)
    expr.value
  end

  def visit_unary_expr(expr)
    right = expr.right

    case expr.operator.type
    when Token::TYPE[:MINUS]
      return -right.to_f
    when Token::TYPE[:BANG]
      return !is_truthy?(right)
    end

    nil
  end

  private

  def is_truthy?(expr)
    !!expr.value # Lox follows Ruby's rule for truthiness
  end

  def parenthesize(name, *exprs)
    output = String.new

    output << '('
    output << name
    exprs.each do |expr|
      output << ' '
      output << expr.accept(self)
    end
    output << ')'

    output
  end
end

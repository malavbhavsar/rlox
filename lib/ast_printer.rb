# frozen_string_literal: true

class AstPrinter < Visitor
  def initialize
  end

  def print(expression)
    expression.accept(self)
  end

  def visit_binary_expr(expr)
    parenthesize(expr.operator.lexeme, expr.left, expr.right)
  end

  def visit_grouping_expr(expr)
    parenthesize("group", expr.expression)
  end

  def visit_literal_expr(expr)
    return "nil" if expr.value == nil
    expr.value.to_s
  end

  def visit_unary_expr(expr)
    parenthesize(expr.operator.lexeme, expr.right)
  end

  private
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

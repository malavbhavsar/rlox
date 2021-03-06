# frozen_string_literal: true

class Interpreter
  include Expr::Visitor
  include Stmt::Visitor

  attr_accessor :environment
  attr_accessor :globals

  def initialize
    @globals = Environment.new
    @environment = @globals

    clock = RloxCallable.new
    clock.instance_eval do
      def arity
        0
      end

      def call(_interpreter, _arguments)
        Time.now.to_i
      end

      def to_s
        '<native fn>'
      end
    end

    @globals.define('clock', clock)
  end

  def interpret(statements)
    statements.each do |statement|
      execute(statement)
    end
  rescue RloxRuntimeError => e
    Rlox.runtime_error(e)
  end

  def evaluate(expr)
    expr.accept(self)
  end

  def execute(stmt)
    stmt.accept(self)
  end

  def execute_block(statements, given_environment)
    previous_environment = self.environment
    self.environment = given_environment
    statements.each { |statement| execute(statement) }
  ensure
    self.environment = previous_environment
  end

  def visit_block_stmt(stmt)
    execute_block(stmt.statements, Environment.new(self.environment))
    nil
  end

  def visit_expression_stmt(stmt)
    evaluate(stmt.expression)
  end

  def visit_function_stmt(stmt)
    function = RloxFunction.new(stmt, self.environment)
    self.environment.define(stmt.name.lexeme, function)
    nil
  end

  def visit_if_stmt(stmt)
    if truthy?(evaluate(stmt.condition))
      execute(stmt.then_branch)
    elsif stmt.else_branch
      execute(stmt.else_branch)
    end
  end

  def visit_print_stmt(stmt)
    value = evaluate(stmt.expression)
    puts stringify(value)
  end

  def visit_return_stmt(stmt)
    value = nil
    value = evaluate(stmt.value) unless stmt.value.nil?

    raise Return.new(value)
  end

  def visit_var_stmt(stmt)
    value = stmt.initializer ? evaluate(stmt.initializer) : nil
    self.environment.define(stmt.name.lexeme, value)
  end

  def visit_while_stmt(stmt)
    execute(stmt.body) while truthy?(evaluate(stmt.condition))
    nil
  end

  def visit_assign_expr(expr)
    value = evaluate(expr.value)

    self.environment.assign(expr.name, value)
    value
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
      left > right
    when Token::TYPE[:GREATER_EQUAL]
      check_number_operands(operator, left, right)
      left >= right
    when Token::TYPE[:LESS]
      check_number_operands(operator, left, right)
      left < right
    when Token::TYPE[:LESS_EQUAL]
      check_number_operands(operator, left, right)
      left <= right
    when Token::TYPE[:MINUS]
      check_number_operands(operator, left, right)
      left - right
    when Token::TYPE[:PLUS]
      if ((left.is_a?(Integer) || left.is_a?(Float)) && (right.is_a?(Integer) || right.is_a?(Float))) ||
         (left.is_a?(String) && right.is_a?(String))
        return left + right
      end

      raise RloxRuntimeError.new(operator, "Operands must be two numbers or two strings.")
    when Token::TYPE[:SLASH]
      check_number_operands(operator, left, right)
      left / right
    when Token::TYPE[:STAR]
      check_number_operands(operator, left, right)
      left * right
    when Token::TYPE[:BANG_EQUAL]
      left != right
    when Token::TYPE[:EQUAL_EQUAL]
      left == right
    end
  end

  def visit_call_expr(expr)
    callee = evaluate(expr.callee)

    arguments = expr.arguments.map do |argument|
      evaluate(argument)
    end

    raise RloxRuntimeError.new(expr.paren, "Can only call functions and classes.") unless callee.is_a? RloxCallable
    function = callee

    unless function.arity == arguments.size
      raise RloxRuntimeError.new(expr.paren, "Expected #{function.arity} arguments but got #{arguments.size}.")
    end

    function.call(self, arguments)
  end

  def visit_grouping_expr(expr)
    evaluate(expr.expression)
  end

  def visit_literal_expr(expr)
    expr.value
  end

  def visit_logical_expr(expr)
    left = evaluate(expr.left)
    if expr.operator.type == Token::TYPE[:OR]
      return left if truthy?(left)
    else
      return left unless truthy?(left)
    end

    evaluate(expr.right)
  end

  def visit_unary_expr(expr)
    right = evaluate(expr.right)

    case expr.operator.type
    when Token::TYPE[:MINUS]
      check_number_operands(expr.operator, right)
      return -right.to_f
    when Token::TYPE[:BANG]
      return !truthy?(right)
    end

    nil
  end

  def visit_variable_expr(expr)
    self.environment.get(expr.name)
  end

  private

  def check_number_operands(operator, *operands)
    return if operands.all? { |operand| operand.is_a?(Integer) || operand.is_a?(Float) }

    msg = operands.length > 1 ? 'Operands must be numbers.' : 'Operand must be a number.'
    raise RloxRuntimeError.new(operator, msg)
  end

  def truthy?(val)
    !!val # Lox follows Ruby's rule for truthiness
  end

  def stringify(val)
    return "nil" if val.nil?

    # Hack. Work around Ruby adding ".0" to integer-valued doubles.
    if val.is_a? Numeric
      text = val.to_s
      if text.end_with?(".0")
        text = text[0...-2]
        return text
      end
    end

    return val.to_s
  end
end

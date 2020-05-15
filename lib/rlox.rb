# frozen_string_literal: true

require 'readline'
require 'singleton'
require 'byebug'

require File.expand_path("../internals/util", __FILE__)
require File.expand_path("../scanner", __FILE__)
require File.expand_path("../token", __FILE__)
require File.expand_path("../grammer", __FILE__)
require File.expand_path("../expr", __FILE__)

# Hacky test for AstPrinter
#
# require File.expand_path("../visitor", __FILE__)
# require File.expand_path("../ast_printer", __FILE__)
#
# expression = Expr::Binary.new(
#                Expr::Unary.new(
#                  Token.new(Token::TYPE[:STAR], "-", nil, 1),
#                  Expr::Literal.new(123)
#                ),
#                Token.new(Token::TYPE[:STAR], "*", nil, 1),
#                Expr::Grouping.new(
#                  Expr::Literal.new(45.67)
#                )
#              )
#
# puts AstPrinter.new.print(expression)

class Rlox
  class HadError
    include Singleton

    attr_accessor :value

    def initialize
      @value = false
    end
  end

  def self.print_usage
    puts "# Usage: rlox [FILE]"
  end

  def self.run_file(file)
    file_content = File.read file
    run(file_content)

    # Error in code
    exit(65) if HadError.instance.value
  end

  def self.run_prompt
    while true
      buffer = Readline.readline("> ", true)
      run(buffer)
      HadError.instance.value = false
    end
  end

  def self.error(line, message)
    report(line, "", message)
  end

  private_class_method def self.run(code)
    scanner = Scanner.new(code)
    scanner.scan_tokens.each { |token| puts token }
  end

  private_class_method def self.report(line, where, message)
    puts "[line #{line}] Error #{where}: #{message}"
    HadError.instance.value = true
  end
end

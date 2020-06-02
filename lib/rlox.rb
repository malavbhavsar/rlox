# frozen_string_literal: true

require 'readline'
require 'singleton'
require 'byebug'

require File.expand_path("../internals/util", __FILE__)
require File.expand_path("../scanner", __FILE__)
require File.expand_path("../token", __FILE__)
require File.expand_path("../grammer", __FILE__)
require File.expand_path("../expr", __FILE__)
require File.expand_path("../parser", __FILE__)
require File.expand_path("../visitor", __FILE__)
require File.expand_path("../ast_printer", __FILE__)
require File.expand_path("../interpreter", __FILE__)

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

  def self.error(line_or_token, message)
    if line_or_token.is_a?(Token)
      token = line_or_token
      line = token.line
      where = if token.type == Token::TYPE[:EOF]
        " at end"
      else
        " at '#{token.lexeme}'"
      end
    else
      line = line_or_token
      where = ""
    end
    report(line, where, message)
  end

  private_class_method def self.run(code)
    scanner = Scanner.new(code)
    tokens = scanner.scan_tokens
    parser = Parser.new(tokens)
    expression = parser.parse

    return if HadError.instance.value

    puts "AST: #{AstPrinter.new.print(expression)}"

    puts Interpreter.new.evaluate(expression)
  end

  private_class_method def self.report(line, where, message)
    puts "[line #{line}] Error#{where}: #{message}"
    HadError.instance.value = true
  end
end

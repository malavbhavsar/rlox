# frozen_string_literal: true

require "readline"
require "singleton"
require "byebug"

require File.expand_path("internals/util", __dir__)
require File.expand_path("scanner", __dir__)
require File.expand_path("token", __dir__)
require File.expand_path("grammar", __dir__)
require File.expand_path("ast", __dir__)
require File.expand_path("parser", __dir__)
require File.expand_path("environment", __dir__)
require File.expand_path("ast_printer", __dir__)
require File.expand_path("interpreter", __dir__)
require File.expand_path("rlox_callable", __dir__)
require File.expand_path("rlox_function", __dir__)
require File.expand_path("return", __dir__)
require File.expand_path("rlox_runtime_error", __dir__)

class Rlox
  class HadError
    include Singleton

    attr_accessor :value

    def initialize
      @value = false
    end
  end

  class HadRuntimeError
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
    exit(70) if HadRuntimeError.instance.value
  end

  def self.run_prompt
    loop do
      buffer = Readline.readline("> ", true)
      run(buffer)
      HadError.instance.value = false
      HadRuntimeError.instance.value = false # not needed to check during .run, but hey why not?
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
    HadError.instance.value = true
  end

  def self.runtime_error(error)
    report(error.token.line, "", error.message)
    HadRuntimeError.instance.value = true
  end

  private_class_method def self.run(code)
    scanner = Scanner.new(code)
    tokens = scanner.scan_tokens
    parser = Parser.new(tokens)
    statements = parser.parse

    return if HadError.instance.value

    # puts "AST: #{AstPrinter.new.print(expression)}" TODO: support printing AST of full program

    Interpreter.new.interpret(statements)
  end

  private_class_method def self.report(line, where, message)
    puts "[line #{line}] Error#{where}: #{message}"
  end
end

# frozen_string_literal: true

require 'readline'
require 'singleton'
require 'byebug'

require File.expand_path("../scanner", __FILE__)
require File.expand_path("../token", __FILE__)

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
    scanner.scan_tokens.each { |token| p token }
  end

  private_class_method def self.report(line, where, message)
    p "[line #{line}] Error #{where}: #{message}"
    HadError.instance.value = true
  end
end

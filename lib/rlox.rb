# frozen_string_literal: true

require 'readline'
require File.expand_path("../scanner", __FILE__)

class Rlox
  def self.run_file(file)
    file_content = File.read file
    run(file_content)
  end

  def self.run_prompt
    while true
      buffer = Readline.readline("> ", true)
      run(buffer)
    end
  end

  def self.print_usage
    puts "# Usage: rlox [FILE]"
  end

  def self.run(code)
    scanner = Scanner.new(code)
    scanner.scan_tokens.each { |token| p token }
  end
end

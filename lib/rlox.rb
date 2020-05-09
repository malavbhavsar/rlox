# frozen_string_literal: true

require 'readline'

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
    p code
  end
end

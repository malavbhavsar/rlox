# frozen_string_literal: true

class Scanner
  attr_reader :source

  def initialize(source)
    @source = source
  end

  def scan_tokens
    [source]
  end
end

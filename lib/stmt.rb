# frozen_string_literal: true

module Stmt
  class Base; end;

  Grammar::STMT.each do |k, v|
    self.class_eval <<-EVAL
      class #{k} < Base
        attr_reader #{v.map { |vv| ":#{vv[:name]}" }.join(', ')}

        def initialize(#{v.map { |vv| "#{vv[:name]}" }.join(', ')})
          #{v.map { |vv| "raise \"#{vv[:name]} must be of type #{Util.grammar_to_internal_type(vv[:type])}\" unless #{vv[:name]}.nil? || #{vv[:name]}.is_a?(#{Util.grammar_to_internal_type(vv[:type])})" }.join("\n") }

          #{v.map { |vv| "@#{vv[:name]} = #{vv[:name]}" }.join("\n") }
        end

        def accept(visitor)
          raise "visitor is not of type Visitor" unless visitor.is_a?(Visitor)
          visitor.visit_#{Util.underscore k}_stmt(self)
        end
      end
    EVAL
  end
end

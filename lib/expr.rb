# frozen_string_literal: true

class Expr
  Grammar::EXPR.each do |k, v|
    self.class_eval <<-EVAL
      class #{k} < Expr
        attr_reader #{v.map { |vv| ":#{vv[:name]}" }.join(', ')}

        def initialize(#{v.map { |vv| "#{vv[:name]}" }.join(', ')})
          #{v.map { |vv| "raise \"#{vv[:name]} must be of type #{vv[:type]}\" unless #{vv[:name]}.is_a?(#{vv[:type]})" }.join("\n") }

          #{v.map { |vv| "@#{vv[:name]} = #{vv[:name]}" }.join("\n") }
        end

        def accept(visitor)
          raise "visitor is not of type Visitor" unless visitor.is_a?(Visitor)
          visitor.visit_#{Util.underscore k}_expr(self)
        end
      end
    EVAL
  end
end

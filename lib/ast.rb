# frozen_string_literal: true

module AstGenerationHelper
  class << self
    def visitor_module_eval_string(rule_type, rule_head)
      <<-EVAL
        def visit_#{Util.underscore rule_head}_#{Util.underscore rule_type}(_#{Util.underscore rule_type})
          raise NotImplementedError
        end
      EVAL
    end

    def class_eval_string(rule_type, rule_head, rule_body)
      <<-EVAL
        class #{rule_head} < Base
          attr_reader #{rule_body.map { |body_part| ":#{body_part[:name]}" }.join(', ')}

          def initialize(#{rule_body.map { |body_part| (body_part[:name]).to_s }.join(', ')})
            #{rule_body.map { |body_part| body_part_type_check(body_part) }.join("\n")}

            #{rule_body.map { |body_part| "@#{body_part[:name]} = #{body_part[:name]}" }.join("\n")}
          end

          def accept(visitor)
            raise "visitor is not of type Visitor" unless visitor.is_a?(Visitor)
            visitor.visit_#{Util.underscore rule_head}_#{Util.underscore rule_type}(self)
          end
        end
      EVAL
    end

    private

    def body_part_type_check(body_part)
      if body_part[:zero_or_more]
        "raise \"All #{body_part[:name]} must be of type #{grammar_type(body_part)}\" "\
          "unless "\
            "#{body_part[:name]}.nil? "\
            "|| "\
            "( "\
              "#{body_part[:name]}.is_a?(Array) "\
              "&& "\
              "#{body_part[:name]}.all? {|elem| elem.is_a?(#{grammar_type(body_part)}) }"\
            ")"
      else
        "raise \"#{body_part[:name]} must be of type #{grammar_type(body_part)}\" "\
          "unless "\
            "#{body_part[:name]}.nil? "\
            "|| "\
            "#{body_part[:name]}.is_a?(#{grammar_type(body_part)})"
      end
    end

    def grammar_type(body_part)
      type = body_part[:type]
      type += "::Base" if %w[Stmt Expr].include? type
      type
    end
  end
end

module Expr
  module Visitor
    Grammar::EXPR.each do |rule_head, _rule_body|
      module_eval AstGenerationHelper.visitor_module_eval_string("Expr", rule_head)
    end
  end

  class Base; end

  Grammar::EXPR.each do |rule_head, rule_body|
    class_eval AstGenerationHelper.class_eval_string("Expr", rule_head, rule_body)
  end
end

module Stmt
  module Visitor
    Grammar::STMT.each do |rule_head, _rule_body|
      module_eval AstGenerationHelper.visitor_module_eval_string("Stmt", rule_head)
    end
  end

  class Base; end

  Grammar::STMT.each do |rule_head, rule_body|
    class_eval AstGenerationHelper.class_eval_string("Stmt", rule_head, rule_body)
  end
end

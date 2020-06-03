# frozen_string_literal: true

module Expr
  module Visitor
    def visit_binary_expr(_expr)
      raise NotImplementedError
    end

    def visit_grouping_expr(_expr)
      raise NotImplementedError
    end

    def visit_literal_expr(_expr)
      raise NotImplementedError
    end

    def visit_unary_expr(_expr)
      raise NotImplementedError
    end
  end
end

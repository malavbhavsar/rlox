# frozen_string_literal: true

module Stmt
  module Visitor
    def visit_block_stmt(_stmt)
      raise NotImplementedError
    end

    def visit_expression_stmt(_stmt)
      raise NotImplementedError
    end

    def visit_if_stmt(_stmt)
      raise NotImplementedError
    end

    def visit_print_stmt(_stmt)
      raise NotImplementedError
    end

    def visit_var_stmt(_stmt)
      raise NotImplementedError
    end
  end
end

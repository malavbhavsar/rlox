# frozen_string_literal: true

module Grammar
  EXPR = {
    "Binary"   => [{ type: "Expr", name: "left" }, { type: "Token", name: "operator" }, { type: "Expr", name: "right" }],
    "Grouping" => [{ type: "Expr", name: "expression" }],
    "Literal"  => [{ type: "Object", name: "value" }],
    "Unary"    => [{ type: "Token", name: "operator" }, { type: "Expr", name: "right" }],
  }.freeze

  STMT = {
    "Expression" => [{ type: "Expr", name: "expression" }],
    "Print"      => [{ type: "Expr", name: "expression" }],
  }
end

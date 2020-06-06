# frozen_string_literal: true

module Grammar
  EXPR = {
    "Assign"   => [{ type: "Token", name: "name" }, { type: "Expr", name: "value" }],
    "Binary"   => [{ type: "Expr", name: "left" }, { type: "Token", name: "operator" }, { type: "Expr", name: "right" }],
    "Grouping" => [{ type: "Expr", name: "expression" }],
    "Literal"  => [{ type: "Object", name: "value" }],
    "Unary"    => [{ type: "Token", name: "operator" }, { type: "Expr", name: "right" }],
    "Variable" => [{ type: "Token", name: "name" }]
  }.freeze

  STMT = {
    "Block"      => [{ type: "Stmt", name: "statements", zero_or_more: true }],
    "Expression" => [{ type: "Expr", name: "expression" }],
    "Print"      => [{ type: "Expr", name: "expression" }],
    "Var"        => [{ type: "Token", name: "name" }, { type: "Expr", name: "initializer" }]
  }
end

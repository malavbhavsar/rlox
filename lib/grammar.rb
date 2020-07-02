# frozen_string_literal: true

module Grammar
  EXPR = {
    "Assign" => [{ type: "Token", name: "name" }, { type: "Expr", name: "value" }],
    "Binary" => [{ type: "Expr", name: "left" }, { type: "Token", name: "operator" }, { type: "Expr", name: "right" }],
    "Call" => [{ type: "Expr", name: "callee" }, { type: "Token", name: "paren" }, { type: "Expr", name: "arguments", zero_or_more: true }],
    "Grouping" => [{ type: "Expr", name: "expression" }],
    "Literal" => [{ type: "Object", name: "value" }],
    "Logical" => [{ type: "Expr", name: "left" }, { type: "Token", name: "operator" }, { type: "Expr", name: "right" }],
    "Unary" => [{ type: "Token", name: "operator" }, { type: "Expr", name: "right" }],
    "Variable" => [{ type: "Token", name: "name" }]
  }.freeze

  STMT = {
    "Block" => [{ type: "Stmt", name: "statements", zero_or_more: true }],
    "Expression" => [{ type: "Expr", name: "expression" }],
    "If" => [{ type: "Expr", name: "condition" }, { type: "Stmt", name: "then_branch" }, { type: "Stmt", name: "else_branch" }],
    "Function" => [{ type: "Token", name: "name" }, { type: "Token", name: "parameters", zero_or_more: true }, { type: "Stmt", name: "body", zero_or_more: true }],
    "Print" => [{ type: "Expr", name: "expression" }],
    "Return" => [{ type: "Token", name: "keyword" }, { type: "Expr", name: "value" }],
    "Var" => [{ type: "Token", name: "name" }, { type: "Expr", name: "initializer" }],
    "While" => [{ type: "Expr", name: "condition" }, { type: "Stmt", name: "body" }]
  }.freeze
end

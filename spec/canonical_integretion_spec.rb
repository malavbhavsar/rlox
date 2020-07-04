# frozen_string_literal: true

require "spec_helper"
require "open3"

# expected_error_pattern = RegExp(r"// (Error.*)");
# error_line_pattern = RegExp(r"// \[((java|c) )?line (\d+)\] (Error.*)");
# expected_runtime_error_pattern = RegExp(r"// expect runtime error: (.+)");
# syntax_error_pattern = RegExp(r"\[.*line (\d+)\] (Error.+)");
# stack_trace_pattern = RegExp(r"\[line (\d+)\]");
# non_test_pattern = RegExp(r"// nontest");

def parse_file(file)
  expected_output_pattern = /\/\/ expect: ?(.*)/
  expected_error_pattern = /\/\/ (Error.*)/
  expected_line_error_pattern = /\/\/ \[line (\d+)\] (Error.*)/
  expected_runtime_error_pattern = /\/\/ expect runtime error: (.+)/

  expected_outputs = {}
  expected_errors = []
  expected_exit_code = 0
  expected_runtime_error_lineno = nil
  expected_runtime_error = nil

  File.readlines(file).each_with_index do |line, lineno|
    matchdata = line.match(expected_output_pattern)
    if matchdata
      expected_outputs[lineno] = matchdata[1]
    end

    matchdata = line.match(expected_error_pattern)
    if matchdata
      expected_errors << "[line #{lineno + 1}] #{matchdata[1]}"
      # If we expect a compile error, it should exit with EX_DATAERR.
      expected_exit_code = 65
    end

    matchdata = line.match(expected_line_error_pattern)
    if matchdata
      expected_errors << "[line #{matchdata[1]}] #{matchdata[2]}"
      # If we expect a compile error, it should exit with EX_DATAERR.
      expected_exit_code = 65
    end

    matchdata = line.match(expected_runtime_error_pattern)
    if matchdata
      expected_runtime_error_lineno = lineno + 1
      expected_runtime_error = "[line #{lineno + 1}] Error: #{matchdata[1]}"
      expected_exit_code = 70
    end
  end

  {
    expected_outputs: expected_outputs,
    expected_errors: expected_errors,
    expected_runtime_error_lineno: expected_runtime_error_lineno,
    expected_runtime_error: expected_runtime_error,
    expected_exit_code: expected_exit_code,
  }
end

RSpec.describe "rlox" do
  early_chapters = {
    "fixtures/canonical/scanning/identifiers.lox" => "skip",
    "fixtures/canonical/scanning/keywords.lox" => "skip",
    "fixtures/canonical/scanning/numbers.lox" => "skip",
    "fixtures/canonical/scanning/punctuators.lox" => "skip",
    "fixtures/canonical/scanning/strings.lox" => "skip",
    "fixtures/canonical/scanning/whitespace.lox" => "skip",
    "fixtures/canonical/expressions/evaluate.lox" => "skip",
    "fixtures/canonical/expressions/parse.lox" => "skip",
  }

  benchmarks = {
    "fixtures/canonical/benchmark/binary_trees.lox" => "skip",
    "fixtures/canonical/benchmark/equality.lox" => "skip",
    "fixtures/canonical/benchmark/fib.lox" => "skip",
    "fixtures/canonical/benchmark/instantiation.lox" => "skip",
    "fixtures/canonical/benchmark/invocation.lox" => "skip",
    "fixtures/canonical/benchmark/method_call.lox" => "skip",
    "fixtures/canonical/benchmark/properties.lox" => "skip",
    "fixtures/canonical/benchmark/string_equality.lox" => "skip",
    "fixtures/canonical/benchmark/trees.lox" => "skip",
    "fixtures/canonical/benchmark/zoo.lox" => "skip",
  }

  nan_equality = {
    "fixtures/canonical/number/nan_equality.lox" => "skip",
  }

  no_limits = {
    "fixtures/canonical/limit/loop_too_large.lox" => "skip",
    "fixtures/canonical/limit/no_reuse_constants.lox" => "skip",
    "fixtures/canonical/limit/too_many_constants.lox" => "skip",
    "fixtures/canonical/limit/too_many_locals.lox" => "skip",
    "fixtures/canonical/limit/too_many_upvalues.lox" => "skip",

    # Rely on JVM for stack overflow checking.
    "fixtures/canonical/limit/stack_overflow.lox" => "skip",
  }

  no_resolution = {
    "fixtures/canonical/closure/assign_to_shadowed_later.lox" => "skip",
    "fixtures/canonical/function/local_mutual_recursion.lox" => "skip",
    "fixtures/canonical/variable/collide_with_parameter.lox" => "skip",
    "fixtures/canonical/variable/duplicate_local.lox" => "skip",
    "fixtures/canonical/variable/duplicate_parameter.lox" => "skip",
    "fixtures/canonical/variable/early_bound.lox" => "skip",

    "fixtures/canonical/return/at_top_level.lox" => "skip",
    "fixtures/canonical/variable/use_local_in_initializer.lox" => "skip",
  }

  no_classes = {
    "fixtures/canonical/assignment/to_this.lox" => "skip",
    "fixtures/canonical/call/object.lox" => "skip",
    "fixtures/canonical/class/empty.lox" => "skip",
    "fixtures/canonical/class/inherit_self.lox" => "skip",
    "fixtures/canonical/class/inherited_method.lox" => "skip",
    "fixtures/canonical/class/local_inherit_other.lox" => "skip",
    "fixtures/canonical/class/local_inherit_self.lox" => "skip",
    "fixtures/canonical/class/local_reference_self.lox" => "skip",
    "fixtures/canonical/class/reference_self.lox" => "skip",
    "fixtures/canonical/closure/close_over_method_parameter.lox" => "skip",
    "fixtures/canonical/constructor/arguments.lox" => "skip",
    "fixtures/canonical/constructor/call_init_early_return.lox" => "skip",
    "fixtures/canonical/constructor/call_init_explicitly.lox" => "skip",
    "fixtures/canonical/constructor/default.lox" => "skip",
    "fixtures/canonical/constructor/default_arguments.lox" => "skip",
    "fixtures/canonical/constructor/early_return.lox" => "skip",
    "fixtures/canonical/constructor/extra_arguments.lox" => "skip",
    "fixtures/canonical/constructor/init_not_method.lox" => "skip",
    "fixtures/canonical/constructor/missing_arguments.lox" => "skip",
    "fixtures/canonical/constructor/return_in_nested_function.lox" => "skip",
    "fixtures/canonical/constructor/return_value.lox" => "skip",
    "fixtures/canonical/field/call_function_field.lox" => "skip",
    "fixtures/canonical/field/call_nonfunction_field.lox" => "skip",
    "fixtures/canonical/field/get_and_set_method.lox" => "skip",
    "fixtures/canonical/field/get_on_bool.lox" => "skip",
    "fixtures/canonical/field/get_on_class.lox" => "skip",
    "fixtures/canonical/field/get_on_function.lox" => "skip",
    "fixtures/canonical/field/get_on_nil.lox" => "skip",
    "fixtures/canonical/field/get_on_num.lox" => "skip",
    "fixtures/canonical/field/get_on_string.lox" => "skip",
    "fixtures/canonical/field/many.lox" => "skip",
    "fixtures/canonical/field/method.lox" => "skip",
    "fixtures/canonical/field/method_binds_this.lox" => "skip",
    "fixtures/canonical/field/on_instance.lox" => "skip",
    "fixtures/canonical/field/set_evaluation_order.lox" => "skip",
    "fixtures/canonical/field/set_on_bool.lox" => "skip",
    "fixtures/canonical/field/set_on_class.lox" => "skip",
    "fixtures/canonical/field/set_on_function.lox" => "skip",
    "fixtures/canonical/field/set_on_nil.lox" => "skip",
    "fixtures/canonical/field/set_on_num.lox" => "skip",
    "fixtures/canonical/field/set_on_string.lox" => "skip",
    "fixtures/canonical/field/undefined.lox" => "skip",
    "fixtures/canonical/inheritance/constructor.lox" => "skip",
    "fixtures/canonical/inheritance/inherit_from_function.lox" => "skip",
    "fixtures/canonical/inheritance/inherit_from_nil.lox" => "skip",
    "fixtures/canonical/inheritance/inherit_from_number.lox" => "skip",
    "fixtures/canonical/inheritance/inherit_methods.lox" => "skip",
    "fixtures/canonical/inheritance/parenthesized_superclass.lox" => "skip",
    "fixtures/canonical/inheritance/set_fields_from_base_class.lox" => "skip",
    "fixtures/canonical/method/arity.lox" => "skip",
    "fixtures/canonical/method/empty_block.lox" => "skip",
    "fixtures/canonical/method/extra_arguments.lox" => "skip",
    "fixtures/canonical/method/missing_arguments.lox" => "skip",
    "fixtures/canonical/method/not_found.lox" => "skip",
    "fixtures/canonical/method/print_bound_method.lox" => "skip",
    "fixtures/canonical/method/refer_to_name.lox" => "skip",
    "fixtures/canonical/method/too_many_arguments.lox" => "skip",
    "fixtures/canonical/method/too_many_parameters.lox" => "skip",
    "fixtures/canonical/number/decimal_point_at_eof.lox" => "skip",
    "fixtures/canonical/number/trailing_dot.lox" => "skip",
    "fixtures/canonical/operator/equals_class.lox" => "skip",
    "fixtures/canonical/operator/equals_method.lox" => "skip",
    "fixtures/canonical/operator/not_class.lox" => "skip",
    "fixtures/canonical/regression/394.lox" => "skip",
    "fixtures/canonical/super/bound_method.lox" => "skip",
    "fixtures/canonical/super/call_other_method.lox" => "skip",
    "fixtures/canonical/super/call_same_method.lox" => "skip",
    "fixtures/canonical/super/closure.lox" => "skip",
    "fixtures/canonical/super/constructor.lox" => "skip",
    "fixtures/canonical/super/extra_arguments.lox" => "skip",
    "fixtures/canonical/super/indirectly_inherited.lox" => "skip",
    "fixtures/canonical/super/missing_arguments.lox" => "skip",
    "fixtures/canonical/super/no_superclass_bind.lox" => "skip",
    "fixtures/canonical/super/no_superclass_call.lox" => "skip",
    "fixtures/canonical/super/no_superclass_method.lox" => "skip",
    "fixtures/canonical/super/parenthesized.lox" => "skip",
    "fixtures/canonical/super/reassign_superclass.lox" => "skip",
    "fixtures/canonical/super/super_at_top_level.lox" => "skip",
    "fixtures/canonical/super/super_in_closure_in_inherited_method.lox" => "skip",
    "fixtures/canonical/super/super_in_inherited_method.lox" => "skip",
    "fixtures/canonical/super/super_in_top_level_function.lox" => "skip",
    "fixtures/canonical/super/super_without_dot.lox" => "skip",
    "fixtures/canonical/super/super_without_name.lox" => "skip",
    "fixtures/canonical/super/this_in_superclass_method.lox" => "skip",
    "fixtures/canonical/this/closure.lox" => "skip",
    "fixtures/canonical/this/nested_class.lox" => "skip",
    "fixtures/canonical/this/nested_closure.lox" => "skip",
    "fixtures/canonical/this/this_at_top_level.lox" => "skip",
    "fixtures/canonical/this/this_in_method.lox" => "skip",
    "fixtures/canonical/this/this_in_top_level_function.lox" => "skip",
    "fixtures/canonical/return/in_method.lox" => "skip",
    "fixtures/canonical/variable/local_from_method.lox" => "skip",
  }

  all_fixtures = Hash[Dir.glob("fixtures/canonical/**/*.lox").map { |file| [file, 'ok'] }]

  overrides = early_chapters.merge(benchmarks, nan_equality, no_limits, no_resolution, no_classes)

  test_fixtures = all_fixtures.merge(overrides)

  test_fixtures.each do |file, expected|
    test_description = file.match(/fixtures\/canonical\/(.*)\.lox/)[1].split('/').map { |name| name.split('_').join(' ') }.join(' | ')

    case expected
    when 'ok'
      it "#{test_description}" do
        expectation = parse_file(file)
        stdouts, stderrs, status = Open3.capture3('bin/rlox', file)

        actual_outputs = stdouts.split("\n")
        actual_errors = stderrs.split("\n")

        expectation[:expected_outputs].each_with_index do |(lineno, expected_output), idx|
          expect(actual_outputs[idx]).to eq(expected_output), lambda { "expected output #{expected_output} on #{file}:#{lineno}, got #{actual_outputs[idx]}" }
        end

        expectation[:expected_errors].each_with_index do |expected_error, idx|
          expect(actual_errors[idx]).to eq(expected_error), lambda { "expected error #{expected_error} on #{file}, got #{actual_errors[idx]}" }
        end

        if expectation[:expected_runtime_error]
          expect(actual_errors[0]).to eq(expectation[:expected_runtime_error])
        end

        expect(status.exitstatus).to eq(expectation[:expected_exit_code])
      end
    when 'skip'
      pending "#{test_description}"
    end
  end
end

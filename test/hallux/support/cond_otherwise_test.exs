defmodule Hallux.Checks.CondOtherwiseTest do
  use Credo.Test.Case

  alias Hallux.Checks.CondOtherwise

  Code.require_file("dev/hallux/checks/cond_otherwise.ex")

  test "no default case" do
    """
    defmodule M do
      def ok(x, y) do
        cond do
          x > y -> :yes
          x <= y -> :no
        end
      end
    end
    """
    |> to_source_file()
    |> run_check(CondOtherwise)
    |> refute_issues()
  end

  test "default case | otherwise" do
    """
    defmodule M do
      def ok(x, y) do
        cond do
          x > y -> :yes
          :otherwise -> :no
        end
      end
    end
    """
    |> to_source_file()
    |> run_check(CondOtherwise)
    |> refute_issues()
  end

  test "default case | true" do
    """
    defmodule M do
      def ok(x, y) do
        cond do
          x > y -> :yes
          true -> :no
        end
      end
    end
    """
    |> to_source_file()
    |> run_check(CondOtherwise)
    |> assert_issue(fn issue ->
      assert issue.line_no == 3

      assert issue.message ==
               "The default clause for `cond` should be `:otherwise`, not `true` or other literals"
    end)
  end

  test "default case | something else" do
    """
    defmodule M do
      def ok(x, y) do
        cond do
          x > y -> :yes
          :something_else -> :no
        end
      end
    end
    """
    |> to_source_file()
    |> run_check(CondOtherwise)
    |> assert_issue(fn issue ->
      assert issue.line_no == 3

      assert issue.message ==
               "The default clause for `cond` should be `:otherwise`, not `true` or other literals"
    end)
  end
end

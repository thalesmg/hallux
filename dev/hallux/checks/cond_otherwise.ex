defmodule Hallux.Checks.CondOtherwise do
  use Credo.Check,
    base_priority: :high,
    category: :design,
    exit_status: 1

  @moduledoc """
  Checks whether the default case of a `cond` expression is `true` or
  some other literal instead of `:otherwise`
  """

  @explanation [
    check: @moduledoc
  ]

  @doc false
  @impl true
  def run(%SourceFile{} = source_file, params) do
    # IssueMeta helps us pass down both the source_file and params of a check
    # run to the lower levels where issues are created, formatted and returned
    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.prewalk(source_file, &analyze(&1, &2, issue_meta))
  end

  defp analyze(ast = {:cond, cond_meta, [[do: clauses]]}, issues, issue_meta) do
    single_literal_clauses =
      Enum.filter(
        clauses,
        &match?({:->, _, [[atom] | _]} when is_atom(atom), &1)
      )

    literal_clause? = length(single_literal_clauses) > 0

    true? =
      Enum.any?(
        clauses,
        &match?({:->, _, [[true] | _]}, &1)
      )

    otherwise? =
      Enum.any?(
        clauses,
        &match?({:->, _, [[:otherwise] | _]}, &1)
      )

    if literal_clause? and (true? or not otherwise?) do
      new_issue =
        issue_for(
          issue_meta,
          cond_meta[:line]
        )

      {ast, [new_issue | issues]}
    else
      {ast, issues}
    end
  end

  defp analyze(ast, issues, _issue_meta) do
    {ast, issues}
  end

  defp issue_for(issue_meta, line_no) do
    format_issue(
      issue_meta,
      message:
        "The default clause for `cond` should be `:otherwise`, not `true` or other literals",
      line_no: line_no
    )
  end
end

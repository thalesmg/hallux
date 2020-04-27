defmodule Hallux.Mixfile do
  use Mix.Project

  @version "1.1.0"

  def project do
    [
      app: :hallux,
      name: "Hallux",
      version: @version,
      description: "Provides an implementation for Finger Trees in Elixir",
      package: package(),
      source_url: "https://github.com/thalesmg/hallux",
      homepage_url: "https://github.com/thalesmg/hallux",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:stream_data, "~> 0.4", only: :test}
    ]
  end

  defp package() do
    [
      name: "hallux",
      licenses: ["GNU GPLv3"],
      maintainers: ["Thales Macedo Garitezi", "Diego Vinícius e Souza"],
      links: %{github: "https://github.com/thalesmg/hallux"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs() do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: ["README.md"],
      groups_for_modules: [
        "Data Structures": [
          Hallux.IntervalMap,
          Hallux.Seq,
        ],
        Protocols: [
          Hallux.Protocol.Measured,
          Hallux.Protocol.Monoid,
          Hallux.Protocol.Reduce
        ],
        Internal: [
          Hallux.Internal.Digit,
          Hallux.Internal.Digit.One,
          Hallux.Internal.Digit.Two,
          Hallux.Internal.Digit.Three,
          Hallux.Internal.Digit.Four,
          Hallux.Internal.Elem,
          Hallux.Internal.FingerTree,
          Hallux.Internal.FingerTree.Empty,
          Hallux.Internal.FingerTree.Single,
          Hallux.Internal.FingerTree.Deep,
          Hallux.Internal.Interval,
          Hallux.Internal.IntInterval,
          Hallux.Internal.IntInterval.IntInterval,
          Hallux.Internal.IntInterval.NoInterval,
          Hallux.Internal.Node,
          Hallux.Internal.Node.Node2,
          Hallux.Internal.Node.Node3,
          Hallux.Internal.Size,
          Hallux.Internal.Split
        ]
      ],
      nest_modules_by_prefix: [
        Hallux.Internal,
        Hallux.Internal.Digit,
        Hallux.Internal.FingerTree,
        Hallux.Internal.IntInterval,
        Hallux.Internal.Node,
        Hallux.Protocol
      ]
    ]
  end
end

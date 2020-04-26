defmodule Hallux.Mixfile do
  use Mix.Project

  @version "1.0.0"

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

  defp docs() do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: ["README.md"]
    ]
  end
end

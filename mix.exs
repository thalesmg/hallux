defmodule Hallux.Mixfile do
  use Mix.Project

  def project do
    [
      app: :hallux,
      name: "Hallux",
      version: "0.1.0",
      description: "Provides an implementation for Finger Trees in Elixir",
      package: package(),
      source_url: "https://github.com/thalesmg/hallux",
      homepage_url: "https://github.com/thalesmg/hallux",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
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
end

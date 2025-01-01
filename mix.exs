defmodule KuzuNif.MixProject do
  use Mix.Project

  @version "0.5.0"
  @source_url "https://github.com/bgoosmanviz/kuzu_nif"

  def project do
    [
      app: :kuzu_nif,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rustler_precompiled, "~> 0.8.2"},
      {:rustler, "~> 0.34.0", optional: true}
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "native",
        "checksum-*.exs",
        "mix.exs"
      ],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end

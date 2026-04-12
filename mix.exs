defmodule Nulid.MixProject do
  use Mix.Project

  @version "0.2.0"
  @source_url "https://github.com/kakilangit/nulid_ex"

  def project do
    [
      app: :nulid,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      source_url: @source_url,
      homepage_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.37.3", runtime: false},
      {:ecto, "~> 3.12", optional: true},
      {:ex_doc, "~> 0.35", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Nanosecond-Precision Universally Lexicographically Sortable Identifier (NULID) for Elixir, powered by Rust NIF."
  end

  defp package do
    [
      name: "nulid",
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Rust crate" => "https://github.com/kakilangit/nulid"
      },
      files:
        ~w(lib native/nulid_nif/src native/nulid_nif/Cargo.toml .formatter.exs mix.exs README.md CHANGELOG.md LICENSE)
    ]
  end

  defp docs do
    [
      main: "Nulid",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end

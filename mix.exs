defmodule Babieca.MixProject do
  use Mix.Project

  def project do
    [
      name: "babieca-q",
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]


  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc, "~> 0.19", only: :dev},
      {:distillery, "~> 2.0"}
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end
end

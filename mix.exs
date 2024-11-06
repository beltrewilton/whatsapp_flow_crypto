defmodule WhatsappFlowCrypto.MixProject do
  use Mix.Project

  @source_url "https://github.com/zookzook/whatsapp_flow_crypto"
  @version "0.1.0"

  def project do
    [
      app: :whatsapp_flow_crypto,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      name: "WhatsApp-Flow-Crypto",
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.34.0"},
      {:ex_doc, "~> 0.32.2", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.4"}
    ]
  end

  defp docs do
    [
      extras: [
        "README.md",
        "CHANGELOG.md",
        "LICENSE"
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end

  defp package do
    [
      description: "Todo",
      maintainers: ["Michael Maier"],
      licenses: ["Apache-2.0"],
      links: %{
        "Changelog" => "https://hexdocs.pm/whatsapp_flow_crypto/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end
end

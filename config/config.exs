import Config

# Configures the endpoint
config :invoice_generator, InvoiceGeneratorWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: InvoiceGeneratorWeb.ErrorHTML, json: InvoiceGeneratorWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: InvoiceGenerator.PubSub,
  live_view: [signing_salt: "YOUR_LIVE_VIEW_SIGNING_SALT"]

# Configures ChromicPDF
config :chromic_pdf, :chrome_args, ["--no-sandbox"]

config :esbuild,
  version: "0.17.11",
  invoice_generator: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  invoice_generator: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

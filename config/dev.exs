import Config

config :invoice_generator, InvoiceGeneratorWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "Px0ogkgyyau9LL4/ZYOREAN8VZk4Pn5BQoVEuwuEvbp+ef63jFuuzpK8quQKaNee",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:invoice_generator, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:invoice_generator, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :invoice_generator, InvoiceGeneratorWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/invoice_generator_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Include HEEx debug annotations as HTML comments in rendered markup
  debug_heex_annotations: true,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true

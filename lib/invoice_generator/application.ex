defmodule InvoiceGenerator.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {ChromicPDF, []},
      {Phoenix.PubSub, name: InvoiceGenerator.PubSub},
      InvoiceGeneratorWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: InvoiceGenerator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    InvoiceGeneratorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

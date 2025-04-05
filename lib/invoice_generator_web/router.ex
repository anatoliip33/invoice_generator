defmodule InvoiceGeneratorWeb.Router do
  use InvoiceGeneratorWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {InvoiceGeneratorWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", InvoiceGeneratorWeb do
    pipe_through :browser

    live "/", InvoiceLive
    get "/download/:filename", DownloadController, :show
  end
end

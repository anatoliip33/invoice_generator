defmodule InvoiceGeneratorWeb.DownloadController do
  use InvoiceGeneratorWeb, :controller

  def show(conn, %{"filename" => filename}) do
    # Ensure the file is from the system's temporary directory for security
    if String.starts_with?(filename, System.tmp_dir!()) do
      send_file(conn, 200, filename)
    else
      send_resp(conn, 403, "Forbidden")
    end
  end
end

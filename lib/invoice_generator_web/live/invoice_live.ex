defmodule InvoiceGeneratorWeb.InvoiceLive do
  use InvoiceGeneratorWeb, :live_view

  defmodule LineItem do
    defstruct [:id, :description, :quantity, :price]
  end

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       line_items: [],
       next_id: 1
     )}
  end

  def handle_event("add-line-item", _params, socket) do
    new_line_item = %LineItem{
      id: socket.assigns.next_id,
      description: "",
      quantity: 1,
      price: Decimal.new(0)
    }

    {:noreply,
     socket
     |> assign(
       line_items: socket.assigns.line_items ++ [new_line_item],
       next_id: socket.assigns.next_id + 1
     )}
  end

  def handle_event("update-line-item", %{"id" => id, "field" => field, "value" => value}, socket) do
    id = String.to_integer(id)
    line_items = update_line_item(socket.assigns.line_items, id, field, value)
    {:noreply, assign(socket, line_items: line_items)}
  end

  def handle_event("remove-line-item", %{"id" => id}, socket) do
    id = String.to_integer(id)
    line_items = Enum.reject(socket.assigns.line_items, &(&1.id == id))
    {:noreply, assign(socket, line_items: line_items)}
  end

  def handle_event("generate-pdf", _params, socket) do
    html = generate_invoice_html(socket.assigns)
    filename = Path.join(System.tmp_dir!(), "invoice-#{System.system_time()}.pdf")


    ChromicPDF.print_to_pdf(
      {:html, html},
      output: filename,
      print_options: %{
        preferCSSPageSize: true,
        displayHeaderFooter: false,
        printBackground: true,
        margin: %{
          top: "1cm",
          bottom: "1cm",
          left: "1cm",
          right: "1cm"
        }
      }
    )

    {:noreply,
     socket
     |> push_event("download-file", %{filename: filename})}
  end

  defp update_line_item(line_items, id, field, value) do
    Enum.map(line_items, fn item ->
      if item.id == id do
        case field do
          "description" -> %{item | description: value}
          "quantity" -> %{item | quantity: parse_integer(value)}
          "price" -> %{item | price: parse_decimal(value)}
        end
      else
        item
      end
    end)
  end

  defp parse_integer(value) do
    case Integer.parse(value) do
      {int, _} -> max(1, int)
      :error -> 1
    end
  end

  defp parse_decimal(value) do
    case Decimal.parse(value) do
      {decimal, ""} -> decimal
      {decimal, _} -> decimal
      :error -> Decimal.new(0)
    end
  end

  defp calculate_total(line_items) do
    line_items
    |> Enum.map(fn item ->
      Decimal.mult(item.price, Decimal.new(item.quantity))
    end)
    |> Enum.reduce(Decimal.new(0), &Decimal.add/2)
  end

  defp format_decimal(decimal) do
    Decimal.round(decimal, 2) |> Decimal.to_string()
  end

  defp calculate_line_total(item) do
    Decimal.mult(item.price, Decimal.new(item.quantity))
  end

  defp generate_invoice_html(assigns) do
    """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <style>
        @page {
          size: A4;
          margin: 0;
        }
        body {
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
          margin: 0;
          padding: 40px;
          box-sizing: border-box;
        }
        .invoice-header {
          margin-bottom: 40px;
        }
        table {
          width: 100%;
          border-collapse: collapse;
          margin: 20px 0;
        }
        th, td {
          padding: 12px;
          text-align: left;
          border-bottom: 1px solid #ddd;
        }
        th {
          background-color: #f8f9fa;
          font-weight: 600;
        }
        .total {
          margin-top: 30px;
          text-align: right;
          font-size: 1.2em;
          font-weight: bold;
        }
        .currency {
          font-family: monospace;
        }
      </style>
    </head>
    <body>
      <div class="invoice-header">
        <h1>Invoice</h1>
        <p>Date: #{Date.utc_today()}</p>
      </div>
      <table>
        <thead>
          <tr>
            <th>Description</th>
            <th>Quantity</th>
            <th>Price</th>
            <th>Total</th>
          </tr>
        </thead>
        <tbody>
          #{for item <- assigns.line_items do
      """
      <tr>
        <td>#{item.description}</td>
        <td>#{item.quantity}</td>
        <td class="currency">$#{format_decimal(item.price)}</td>
        <td class="currency">$#{format_decimal(calculate_line_total(item))}</td>
      </tr>
      """
    end}
        </tbody>
      </table>
      <div class="total">
        Total: <span class="currency">$#{format_decimal(calculate_total(assigns.line_items))}</span>
      </div>
    </body>
    </html>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-6">
      <h1 class="text-2xl font-bold mb-6">Invoice Generator</h1>

      <div class="bg-white shadow rounded-lg p-6">
        <div class="space-y-4">
          <%= for item <- @line_items do %>
            <div class="flex items-center gap-4">
              <div class="flex-1">
                <input
                  type="text"
                  placeholder="Description"
                  value={item.description}
                  class="w-full px-3 py-2 border rounded"
                  phx-blur="update-line-item"
                  phx-value-id={item.id}
                  phx-value-field="description"
                />
              </div>
              <div class="w-24">
                <input
                  type="number"
                  min="1"
                  value={item.quantity}
                  class="w-full px-3 py-2 border rounded"
                  phx-blur="update-line-item"
                  phx-value-id={item.id}
                  phx-value-field="quantity"
                />
              </div>
              <div class="w-32">
                <input
                  type="number"
                  step="0.01"
                  min="0"
                  value={format_decimal(item.price)}
                  class="w-full px-3 py-2 border rounded"
                  phx-blur="update-line-item"
                  phx-value-id={item.id}
                  phx-value-field="price"
                />
              </div>
              <button
                phx-click="remove-line-item"
                phx-value-id={item.id}
                class="text-red-600 hover:text-red-800"
              >
                Remove
              </button>
            </div>
          <% end %>
        </div>

        <div class="mt-4">
          <button
            phx-click="add-line-item"
            class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
          >
            Add Line Item
          </button>
        </div>

        <div class="mt-6 pt-4 border-t">
          <div class="text-xl font-bold">
            Total: $<%= format_decimal(calculate_total(@line_items)) %>
          </div>
        </div>

        <div class="mt-6">
          <button
            phx-click="generate-pdf"
            class="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600"
          >
            Export as PDF
          </button>
        </div>
      </div>
    </div>

    <.link id="download-link" download class="hidden" phx-hook="DownloadFile">
      Download PDF
    </.link>
    """
  end
end

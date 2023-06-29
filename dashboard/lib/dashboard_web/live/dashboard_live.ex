defmodule DashboardWeb.DashboardLive do
  use DashboardWeb, :live_view

  alias Dashboard.WeatherConditions

  def mount(_params, _session, socket) do
    if connected?(socket), do: WeatherConditions.subscribe()

    readings = WeatherConditions.list_readings(12)

    values =
      readings
      |> Enum.map(fn reading -> celsius_to_fahrenheit(reading.temperature_c) end)

    labels =
      readings
      |> Enum.map(fn reading -> format_date(reading.timestamp) end)

    {:ok,
     assign(socket,
       chart_data: %{
         labels: labels,
         values: values
       },
       current_reading: %{
         label: hd(labels),
         value: hd(values)
       }
     )}
  end

  def handle_info({:weather_condition_created, weather_condition}, socket) do
    new_reading = %{
      label: format_date(weather_condition.timestamp),
      value: celsius_to_fahrenheit(weather_condition.temperature_c)
    }

    socket =
      socket
      |> assign(:current_reading, new_reading)

    {:noreply, add_point(socket)}
  end

  def handle_info(:update, socket) do
    {:noreply, add_point(socket)}
  end

  defp celsius_to_fahrenheit(celsius) do
    celsius
    |> Decimal.mult(Decimal.new(1, 18, -1))
    |> Decimal.add(32)
  end

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%b %d, %y | %I:%M %p")
  end

  defp add_point(socket) do
    point = %{
      label: socket.assigns.current_reading.label,
      value: socket.assigns.current_reading.value
    }

    push_event(socket, "new-point", point)
  end

  def render(assigns) do
    ~H"""
    <div id="charting">
      <div id="line-chart-area" phx-update="ignore">
        <canvas
          id="chart-canvas"
          phx-hook="LineChart"
          data-chart-data={Jason.encode!(@chart_data)}
        >
        </canvas>
      </div>
    </div>
    """
  end
end

defmodule DashboardWeb.DashboardLive do
  use DashboardWeb, :live_view

  alias Dashboard.WeatherConditions

  alias DashboardWeb.Components.Charts
  alias Decimal, as: D

  def mount(_params, _session, socket) do
    # Set decimal precision to 3
    D.Context.set(%D.Context{D.Context.get() | precision: 3})

    if connected?(socket), do: WeatherConditions.subscribe()

    readings = WeatherConditions.list_readings(20)

    latest_ambient_light_reading =
      readings
      |> hd()
      |> Map.get(:light_lumens)

    temp_values =
      readings
      |> Enum.map(fn reading -> celsius_to_fahrenheit(reading.temperature_c) end)

    voc_values =
      readings
      |> Enum.map(fn reading -> reading.voc_index end)

    date_labels =
      readings
      |> Enum.map(fn reading -> format_date(reading.timestamp) end)

    {:ok,
     assign(socket,
       temp_data: %{
         labels: date_labels,
         values: temp_values
       },
       current_temp_reading: %{
         label: hd(date_labels),
         value: hd(temp_values)
       },
       voc_data: %{
         labels: date_labels,
         values: voc_values
       },
       current_voc_reading: %{
         label: hd(date_labels),
         value: hd(voc_values)
       },
       last_update: hd(date_labels),
       current_ambient_light_reading: latest_ambient_light_reading
     )}
  end

  def handle_info({:weather_condition_created, weather_condition}, socket) do
    new_date = format_date(weather_condition.timestamp)

    new_temp_reading = %{
      label: new_date,
      value: celsius_to_fahrenheit(weather_condition.temperature_c)
    }

    new_voc_reading = %{
      label: new_date,
      value: weather_condition.voc_index
    }

    socket =
      socket
      |> assign(:current_temp_reading, new_temp_reading)
      |> assign(:current_voc_reading, new_voc_reading)

    {:noreply, add_point(socket)}
  end

  def handle_info(:update, socket) do
    {:noreply, add_point(socket)}
  end

  defp readings_to_assigns_map(readings) do
    Enum.map(readings, fn reading ->
      %{
        label: format_date(reading.timestamp),
        value: celsius_to_fahrenheit(reading.temperature_c)
      }
    end)
  end

  defp celsius_to_fahrenheit(celsius) do
    celsius
    |> Decimal.mult(Decimal.new(1, 18, -1))
    |> Decimal.add(32)
  end

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%b %d, %I:%M %P")
  end

  defp format_lumens(lumens) do
    lumens
    |> Decimal.mult(Decimal.new(1, 18, -1))
    |> Decimal.round(2)
  end

  defp add_point(socket) do
    point = %{
      label: socket.assigns.current_temp_reading.label,
      value: socket.assigns.current_temp_reading.value
    }

    push_event(socket, "new-point", point)
  end

  defp voc_score(voc_index) when voc_index in 0..99, do: "Excellent"
  defp voc_score(voc_index) when voc_index in 100..150, do: "Good"
  defp voc_score(voc_index) when voc_index in 151..200, do: "Average"
  defp voc_score(voc_index) when voc_index in 201..300, do: "Questionable"
  defp voc_score(voc_index) when voc_index in 301..500, do: "Bad"
  defp voc_score(_), do: "Unknown"

  slot(:inner_block, required: false)

  def card_grid(assigns) do
    ~H"""
    <div class="flex flex-wrap items-stretch items-start gap-6 px-12 bg-white justify-items-start">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  slot(:inner_block, required: true)

  def card(assigns) do
    ~H"""
    <div class="p-px grow rounded-2xl bg-gradient-to-b from-blue-300 to-pink-300 drop-shadow">
      <div class="group rounded-[calc(1rem-1.5px)] justify-center flex flex-col py-8 px-6 bg-white h-full">
        <div class="flex flex-col items-center gap-2 text-gray-700">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  def chart_card(assigns) do
    ~H"""
    <div class="p-px grow rounded-2xl bg-gradient-to-b from-blue-300 to-pink-300 drop-shadow">
      <div class="group rounded-[calc(1rem-1.5px)] pl-3 pr-8 py-8 bg-white h-full">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  def card_temp(%{:temp => temp} = assigns) do
    ~H"""
    <.card>
      <.icon name="hero-sun" class="w-24 h-24" />
      <div>
        <h1 class="overflow-visible text-6xl whitespace-nowrap"><%= temp %> °F</h1>
      </div>
    </.card>
    """
  end

  def card_voc_index(%{:voc_index => voc_index} = assigns) do
    ~H"""
    <.card>
      <.icon name="hero-cloud" class="w-24 h-24" />
      <span class="overflow-visible text-5xl whitespace-nowrap"><%= voc_score(voc_index) %></span>
      <span class="overflow-visible text-3xl whitespace-nowrap">AQ: <%= voc_index %>/500</span>
    </.card>
    """
  end

  def card_ambient_light(%{:lumens => lumens} = assigns) do
    ~H"""
    <.card>
      <.icon name="hero-light-bulb" class="w-24 h-24" />
      <span class="overflow-visible text-5xl whitespace-nowrap"><%= format_lumens(lumens) %></span>
      <span class="overflow-visible text-3xl whitespace-nowrap">Lumens</span>
    </.card>
    """
  end

  def card_humidity(assigns) do
    humidity = "80%"

    ~H"""
    <.card>
      <.icon name="hero-beaker" class="w-24 h-24" />
      <span class="overflow-visible text-5xl whitespace-nowrap"><%= humidity %></span>
      <span class="overflow-visible text-3xl whitespace-nowrap">Humidity</span>
    </.card>
    """
  end

  def chart_wrapper(assigns) do
    ~H"""
    <.chart_card>
        <Charts.timeline chart_data={assigns.temp_data} id="temp-chart" />
    </.chart_card>
    """
  end

  def last_updated(%{:date => date} = assigns) do
    time_ago =
      date
      |> Timex.parse!("%b %d, %I:%M %P", :strftime)
      |> Timex.from_now()

    ~H"""
    <div class="flex flex-wrap gap-2 px-12 mb-6">
      <span class="overflow-visible text-base whitespace-nowrap">Last updated: <%= time_ago %></span>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div id="dashboard-main">
      <.last_updated date={@current_temp_reading.label} />
      <.card_grid>
        <.card_temp temp={@current_temp_reading.value} />
        <.card_humidity />
        <.card_voc_index voc_index={@current_voc_reading.value} />
        <.card_ambient_light lumens={@current_ambient_light_reading} />
        <.chart_wrapper current_temp_reading={@current_temp_reading} temp_data={@temp_data} />
      </.card_grid>
    </div>
    """
  end
end

defmodule Dashboard.WeatherConditionsController do
  use DashboardWeb, :controller

  require Logger
  alias Dashboard.{WeatherConditions, WeatherConditions.WeatherCondition}

  def create(conn, params) do
    IO.inspect(params)

    case WeatherConditions.create_entry(params) do
      {:ok, weather_condition} = %WeatherCondition{}} ->
        Logger.debug("Successfully reated a weather condition entry.")

        conn
        |> put_status(:created)
        |> json(weather_condition)

      error ->
        Logger.warn("Failed to create a weather condition entry: #{inspect(error)}")

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{message: "Poorly formatted payload"})
    end
  end
end

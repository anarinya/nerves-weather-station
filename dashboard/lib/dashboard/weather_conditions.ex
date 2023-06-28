defmodule Dashboard.WeatherConditions do
  alias Dashboard.{Repo, WeatherConditions.WeatherCondition}

  import Ecto.Query, warn: false

  @topic inspect(__MODULE__)
  @pubsub Dashboard.PubSub

  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  def broadcast({:ok, weather_condition}, tag) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {tag, weather_condition})
    {:ok, weather_condition}
  end

  def list_readings(limit) do
    Repo.all(
      from(reading in WeatherCondition, order_by: [desc: reading.timestamp], limit: ^limit)
    )
  end

  def list_readings do
    Repo.all(from(reading in WeatherCondition, order_by: [desc: reading.timestamp]))
  end

  def create_entry(attrs) do
    %WeatherCondition{}
    |> WeatherCondition.create_changeset(attrs)
    |> Repo.insert()
    |> broadcast(:weather_condition_created)
  end
end

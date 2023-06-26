defmodule Dashboard.WeatherConditions do
  alias Dashboard.{Repo, WeatherConditions.WeatherCondition}

  def create_entry(attrs) do
    %WeatherCondition{}
    |> WeatherCondition.create_changeset(attrs)
    |> Repo.insert()
  end
end

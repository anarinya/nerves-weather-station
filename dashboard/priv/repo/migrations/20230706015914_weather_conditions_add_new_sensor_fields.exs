defmodule Dashboard.Repo.Migrations.WeatherConditionsAddNewSensorFields do
  use Ecto.Migration

  def change do
    alter table(:weather_conditions) do
      add(:dew_point_c, :decimal, null: true)
      add(:gas_resistance_ohms, :decimal, null: true)
      add(:humidity_rh, :decimal, null: true)
    end
  end
end

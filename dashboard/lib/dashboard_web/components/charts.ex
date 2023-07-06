defmodule DashboardWeb.Components.Charts do
  use Phoenix.Component

  alias Decimal, as: D

  def timeline(assigns) do
    ~H"""
    <div id={"#{@id}-charting"}>
      <div id={"#{@id}-line-chart-area"} phx-update="ignore">
        <div class="flex flex-col items-center flex-grow gap-2 overflow-hidden text-gray-700" >
          <div class="max-w-5xl grow shrink md:h-[calc(45vh-20rem)] w-[calc(60vw-1rem)] lg:w-[calc(100%-1vw)] lg:h-[calc(55vh-20rem)]">
          <canvas
            id={@id}
            class="relative"
            phx-hook="LineChart"
            data-chart-data={Jason.encode!(@chart_data)}
          >
          </canvas>
        </div>
        </div>
      </div>
    </div>
    """
  end
end

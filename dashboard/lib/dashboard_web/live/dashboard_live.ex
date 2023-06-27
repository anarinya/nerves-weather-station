defmodule DashboardWeb.DashboardLive do
  use DashboardWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center h-screen">
      <h1 class="text-4xl font-bold">Hello, world!</h1>
      <p class="mt-4 text-gray-500">Welcome to Phoenix LiveView!</p>
    </div>
    """
  end
end

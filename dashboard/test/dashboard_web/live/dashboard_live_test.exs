defmodule DashboardWeb.DashboardLiveTest do
  use DashboardWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "initial render", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")

    assert html =~ "Hello, world!"
    assert render(view) =~ "Hello, world!"
  end
end

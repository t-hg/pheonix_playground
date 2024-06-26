defmodule PheonixPlaygroundWeb.PageControllerTest do
  use PheonixPlaygroundWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Welcome"
  end
end

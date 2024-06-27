defmodule PhxPlaygroundWeb.PageControllerTest do
  use PhxPlaygroundWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    response = html_response(conn, 302)
    assert response =~ ~p"/users/log_in"
  end
end

defmodule Hexpm.Web.LoginController do
  use Hexpm.Web, :controller

  plug :nillify_params, ["return"]

  def show(conn, _params) do
    if logged_in?(conn) do
      username = get_session(conn, "username")
      path = conn.params["return"] || user_path(conn, :show, username)
      redirect(conn, to: path)
    else
      render_show(conn)
    end
  end

  def create(conn, %{"username" => username, "password" => password}) do
    case password_auth(username, password) do
      {:ok, user} ->
        path = conn.params["return"] || user_path(conn, :show, user)

        conn
        |> configure_session(renew: true)
        |> put_session("username", user.username)
        |> redirect(to: path)
      {:error, reason} ->
        conn
        |> put_flash(:error, auth_error_message(reason))
        |> put_status(400)
        |> render_show
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session("username")
    |> redirect(to: page_path(Hexpm.Web.Endpoint, :index))
  end

  defp render_show(conn) do
    render conn, "show.html", [
      title: "Log in",
      container: "container page login",
      return: conn.params["return"]
    ]
  end
end

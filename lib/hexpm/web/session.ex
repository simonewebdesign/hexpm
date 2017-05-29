defmodule Hexpm.Web.Session do
  import Ecto.Query

  alias Hexpm.Accounts.Session
  alias Hexpm.Repo

  @behaviour Plug.Session.Store
  @fake_token <<0::96*8>>

  def init(_opts) do
    :ok
  end

  def get(_conn, cookie, _opts) do
    {id, token} = parse_cookie(cookie)
    session = Repo.get(Session, id)
    if session && Plug.Crypto.secure_compare(token, session.token) do
      {id, session.data}
    else
      {nil, %{}}
    end
  end

  def put(_conn, nil, data, _opts) do
    session = Repo.insert!(Session.build(data))
    build_cookie(session)
  end

  def put(_conn, id, data, _opts) do
    result = Repo.update_all(
      from(s in Session, where: [id: ^id]),
      [set: [
        data: data,
        updated_at: NaiveDateTime.utc_now()
      ]],
      returning: true)

    case result do
      {1, [session]} ->
        build_cookie(session)
      {0, []} ->
        build_cookie(0, @fake_token)
    end
  end

  def delete(_conn, id, _opts) do
    Repo.delete_all(from(s in Session, where: [id: ^id]))
  end

  defp build_cookie(session) do
    build_cookie(session.id, session.token)
  end

  defp build_cookie(id, token) do
    "#{id}++#{Base.url_encode64(token)}"
  end

  defp parse_cookie(sid) do
    [id, token] = String.split(sid, "++", parts: 2)
    {id, token}
  end
end

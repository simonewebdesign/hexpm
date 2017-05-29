defmodule Hexpm.Web.Session do
  alias Hexpm.Accounts.Session
  alias Hexpm.Repo

  @behaviour Plug.Session.Store

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
    session =
      if session = Repo.get(Session, id) do
        Repo.update!(Session.update(session, data))
      else
        Repo.insert!(Session.build(data))
      end
    build_cookie(session)
  end

  def delete(_conn, id, _opts) do
    if session = Repo.get(Session, id) do
      Repo.delete!(session)
    end
    :ok
  end

  defp build_cookie(session) do
    "#{session.id}++#{Base.url_encode64(session.token)}"
  end

  defp parse_cookie(sid) do
    [id, token] = String.split(sid, "++", parts: 2)
    {id, token}
  end
end

defmodule Hexpm.Web.Session do
  import Ecto.Query
  alias Hexpm.Accounts.Session
  alias Hexpm.Repo

  @behaviour Plug.Session.Store

  def init(_opts) do
    :ok
  end

  def get(_conn, sid, _opts) do
    if session = Repo.get(Session, sid) do
      {sid, session.data}
    else
      {nil, %{}}
    end
  end

  def put(_conn, nil, data, _opts) do
    session = Repo.insert!(%Session{data: data})
    session.id
  end

  def put(_conn, sid, data, _opts) do
    Repo.update_all(from(Session, where: [id: ^sid]), set: [data: data, updated_at: NaiveDateTime.utc_now()])
    sid
  end

  def delete(_conn, sid, _opts) do
    Repo.delete_all(from(Session, where: [id: ^sid]))
    :ok
  end
end

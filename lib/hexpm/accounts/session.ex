defmodule Hexpm.Accounts.Session do
  use Hexpm.Web, :schema

  schema "sessions" do
    field :token, :binary
    field :data, :map
    timestamps()
  end

  def build(data) do
    change(%Session{}, data: data, token: :crypto.strong_rand_bytes(96))
  end

  def update(session, data) do
    change(session, data: data)
  end

  def by_user(query, user) do
    from(s in query, where: fragment("?->>'username'", s.data) == ^user.username)
  end
end

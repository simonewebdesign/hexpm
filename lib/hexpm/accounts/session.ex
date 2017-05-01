defmodule Hexpm.Accounts.Session do
  use Hexpm.Web, :schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "sessions" do
    field :data, :map
    timestamps()
  end

  def by_user(query, user) do
    from(s in query, where: fragment("?->>'username'", s.data) == ^user.username)
  end
end

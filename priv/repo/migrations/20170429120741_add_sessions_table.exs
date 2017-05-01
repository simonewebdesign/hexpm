defmodule Hexpm.Repo.Migrations.AddSessionsTable do
  use Ecto.Migration

  def up do
    create table(:sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :data, :jsonb, null: false

      timestamps()
    end

    create index(:sessions, ["(data->>'username')"])

    alter table(:users) do
      remove :session_key
    end
  end

  def down do
    drop table(:sessions)

    alter table(:users) do
      add :session_key, :string
    end
  end
end

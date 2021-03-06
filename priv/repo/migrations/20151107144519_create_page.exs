defmodule Wiki.Repo.Migrations.CreatePage do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :title, :string
      add :content, :text

      timestamps
    end
    create index(:pages, [:title], unique: true)
  end
end

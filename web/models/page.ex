defmodule Wiki.Page do
  use Wiki.Web, :model
  import Ecto.Query

  schema "pages" do
    field :title, :string
    field :content, :string

    timestamps
  end

  @required_fields ~w(title content)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def by_titles(query, titles) do
    from p in query,
    where: p.title in ^titles
  end

end

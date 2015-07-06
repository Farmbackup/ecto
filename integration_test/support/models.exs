defmodule Ecto.Integration.Model do
  defmacro __using__(_) do
    quote do
      use Ecto.Model

      type =
        Application.get_env(:ecto, :primary_key_type) ||
        raise ":primary_key_type not set in :ecto application"
      @primary_key {:id, type, autogenerate: true}
      @foreign_key_type type
    end
  end

  def pdict_store(changeset, key, val) do
    Process.put(key, val)
    changeset
  end
end

defmodule Ecto.Integration.Post do
  @moduledoc """
  This module is used to test:

    * Overall functionality
    * Overall types
    * Non-null timestamps
    * Relationships
    * Dependent callbacks

  """
  use Ecto.Integration.Model

  schema "posts" do
    field :counter, :id # Same as integer
    field :title, :string
    field :text, :binary
    field :temp, :string, default: "temp", virtual: true
    field :public, :boolean, default: true
    field :cost, :decimal
    field :visits, :integer
    field :intensity, :float
    field :bid, :binary_id
    field :uuid, Ecto.UUID, autogenerate: true
    field :meta, :map
    has_many :comments, Ecto.Integration.Comment, on_delete: :delete_all
    has_one :permalink, Ecto.Integration.Permalink, on_delete: :fetch_and_delete
    has_many :comments_authors, through: [:comments, :author]
    belongs_to :author, Ecto.Integration.User
    timestamps
  end
end

defmodule Ecto.Integration.PostUsecTimestamps do
  @moduledoc """
  This module is used to test:

    * Usec timestamps

  """
  use Ecto.Integration.Model

  schema "posts" do
    field :title, :string
    timestamps usec: true
  end
end

defmodule Ecto.Integration.Comment do
  @moduledoc """
  This module is used to test:

    * Optimistic lock
    * Relationships
    * Dependent callbacks

  """
  use Ecto.Integration.Model

  schema "comments" do
    field :text, :string
    field :posted, :datetime
    field :lock_version, :integer, default: 1
    belongs_to :post, Ecto.Integration.Post
    belongs_to :author, Ecto.Integration.User
    has_one :post_permalink, through: [:post, :permalink]
  end

  optimistic_lock :lock_version
  before_delete Ecto.Integration.Model, :pdict_store, [__MODULE__, :on_delete]
end

defmodule Ecto.Integration.Permalink do
  @moduledoc """
  This module is used to test:

    * Relationships
    * Dependent callbacks

  """
  use Ecto.Integration.Model

  schema "permalinks" do
    field :url, :string
    belongs_to :post, Ecto.Integration.Post
    has_many :post_comments_authors, through: [:post, :comments_authors]
  end

  before_delete Ecto.Integration.Model, :pdict_store, [__MODULE__, :on_delete]
end

defmodule Ecto.Integration.User do
  @moduledoc """
  This module is used to test:

    * Timestamps
    * Relationships
    * Dependent callbacks

  """
  use Ecto.Integration.Model

  schema "users" do
    field :name, :string
    has_many :comments, Ecto.Integration.Comment, foreign_key: :author_id, on_delete: :nilify_all
    has_many :posts, Ecto.Integration.Post, on_delete: :nothing, foreign_key: :author_id
    belongs_to :custom, Ecto.Integration.Custom, references: :bid, type: :binary_id
    timestamps
  end
end

defmodule Ecto.Integration.Custom do
  @moduledoc """
  This module is used to test:

    * binary_id primary key
    * Tying another schemas to an existing model

  Due to the second item, it must be a subset of posts.
  """
  use Ecto.Integration.Model

  @primary_key {:bid, :binary_id, autogenerate: true}
  schema "customs" do
  end
end

defmodule Ecto.Integration.Barebone do
  @moduledoc """
  This module is used to test:

    * A model wthout primary keys
    * Embedding

  """
  use Ecto.Integration.Model

  @primary_key false
  schema "barebones" do
    field :num, :integer
  end
end

defmodule Ecto.Integration.Tag do
  @moduledoc """
  This module is used to test:

    * The array type

  """
  use Ecto.Integration.Model

  schema "tags" do
    field :ints, {:array, :integer}
    field :uuids, {:array, Ecto.UUID}
  end
end

defmodule Ecto.Integration.Item do
  @moduledoc """
  This module is used to test:

    * Embedding

  """
  use Ecto.Integration.Model

  # TODO decide what to do with source here
  schema "whatever" do
    field :price, :integer
  end
end

defmodule Ecto.Integration.Order do
  @moduledoc """
  This module is used to test:

    * Embedding

  """
  use Ecto.Integration.Model

  schema "orders" do
    embeds_one :item, Ecto.Integration.Item
    embeds_many :items, Ecto.Integration.Item
  end
end

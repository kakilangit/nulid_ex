if Code.ensure_loaded?(Ecto.Type) do
  defmodule Nulid.Ecto do
    @moduledoc """
    An Ecto type for NULID identifiers.

    NULIDs are stored as 16-byte binaries in the database and represented
    as 26-character Crockford Base32 strings in Elixir.

    ## Schema Usage

        @primary_key {:id, Nulid.Ecto, autogenerate: true}
        @foreign_key_type Nulid.Ecto

        schema "my_table" do
          field :name, :string
          timestamps()
        end

    ## Migration

        create table(:my_table, primary_key: false) do
          add :id, :binary, primary_key: true, size: 16
          add :name, :string
          timestamps()
        end
    """

    use Ecto.Type

    @type t :: String.t()

    @impl true
    def type, do: :binary

    @impl true
    def cast(<<_::128>> = raw) do
      Nulid.encode(raw)
    end

    def cast(string) when is_binary(string) and byte_size(string) == 26 do
      case Nulid.decode(string) do
        {:ok, _binary} -> {:ok, string}
        {:error, _} -> :error
      end
    end

    def cast(_), do: :error

    @impl true
    def dump(string) when is_binary(string) and byte_size(string) == 26 do
      Nulid.decode(string)
    end

    def dump(<<_::128>> = raw), do: {:ok, raw}
    def dump(_), do: :error

    @impl true
    def load(<<_::128>> = raw) do
      Nulid.encode(raw)
    end

    def load(_), do: :error

    @doc false
    @impl true
    def autogenerate do
      {:ok, nulid} = Nulid.generate()
      nulid
    end
  end
end

defmodule Nulid.Generator do
  @moduledoc """
  Monotonic NULID generator.

  Guarantees that each generated ID is strictly greater than the previous one,
  even when multiple IDs are generated within the same nanosecond or when
  clock skew occurs.

  The generator holds a NIF resource reference internally. It is thread-safe
  and can be shared across processes (the Rust side uses a Mutex).

  ## Single-Node Usage

      gen = Nulid.Generator.new()
      {:ok, id1} = Nulid.Generator.generate(gen)
      {:ok, id2} = Nulid.Generator.generate(gen)
      id1 < id2  # always true

  ## Distributed Usage

  For multi-node deployments, use a node ID (0-65535) to guarantee
  uniqueness across nodes even with identical timestamps and RNG seeds:

      gen = Nulid.Generator.new(node_id: 1)
      {:ok, id} = Nulid.Generator.generate(gen)
  """

  @enforce_keys [:ref, :type]
  defstruct [:ref, :type]

  @type t :: %__MODULE__{ref: reference(), type: :default | :distributed}

  @doc """
  Creates a new monotonic generator.

  ## Options

    * `:node_id` - Optional 16-bit node identifier (0-65535) for distributed
      deployments. When set, 16 bits of the random component are reserved for
      the node ID, leaving 44 bits for randomness.

  ## Examples

      # Single-node
      gen = Nulid.Generator.new()

      # Distributed
      gen = Nulid.Generator.new(node_id: 42)
  """
  @spec new(keyword()) :: t()
  def new(opts \\ []) do
    case Keyword.get(opts, :node_id) do
      nil ->
        %__MODULE__{ref: Nulid.Native.generator_new(), type: :default}

      node_id when is_integer(node_id) and node_id >= 0 and node_id <= 65535 ->
        %__MODULE__{ref: Nulid.Native.distributed_generator_new(node_id), type: :distributed}
    end
  end

  @doc """
  Generates a monotonically increasing NULID string from the generator.

  ## Examples

      gen = Nulid.Generator.new()
      {:ok, id} = Nulid.Generator.generate(gen)
  """
  @spec generate(t()) :: {:ok, String.t()} | {:error, String.t()}
  def generate(%__MODULE__{ref: ref, type: :default}) do
    {:ok, Nulid.Native.generator_generate(ref)}
  rescue
    e -> {:error, Exception.message(e)}
  end

  def generate(%__MODULE__{ref: ref, type: :distributed}) do
    {:ok, Nulid.Native.distributed_generator_generate(ref)}
  rescue
    e -> {:error, Exception.message(e)}
  end

  @doc """
  Generates a monotonically increasing NULID binary from the generator.

  ## Examples

      gen = Nulid.Generator.new()
      {:ok, binary} = Nulid.Generator.generate_binary(gen)
      byte_size(binary)  # => 16
  """
  @spec generate_binary(t()) :: {:ok, Nulid.t()} | {:error, String.t()}
  def generate_binary(%__MODULE__{ref: ref, type: :default}) do
    {:ok, Nulid.Native.generator_generate_binary(ref)}
  rescue
    e -> {:error, Exception.message(e)}
  end

  def generate_binary(%__MODULE__{ref: ref, type: :distributed}) do
    {:ok, Nulid.Native.distributed_generator_generate_binary(ref)}
  rescue
    e -> {:error, Exception.message(e)}
  end
end

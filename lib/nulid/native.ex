defmodule Nulid.Native do
  @moduledoc false

  use Rustler,
    otp_app: :nulid,
    crate: "nulid_nif",
    path: "native/nulid_nif"

  # Generation
  def new(), do: :erlang.nif_error(:nif_not_loaded)
  def new_binary(), do: :erlang.nif_error(:nif_not_loaded)

  # Encoding
  def encode(_binary), do: :erlang.nif_error(:nif_not_loaded)
  def decode(_string), do: :erlang.nif_error(:nif_not_loaded)

  # Inspection
  def nanos(_binary), do: :erlang.nif_error(:nif_not_loaded)
  def millis(_binary), do: :erlang.nif_error(:nif_not_loaded)
  def random(_binary), do: :erlang.nif_error(:nif_not_loaded)
  def is_nil(_binary), do: :erlang.nif_error(:nif_not_loaded)

  # Generator (single-node, monotonic)
  def generator_new(), do: :erlang.nif_error(:nif_not_loaded)
  def generator_generate(_ref), do: :erlang.nif_error(:nif_not_loaded)
  def generator_generate_binary(_ref), do: :erlang.nif_error(:nif_not_loaded)

  # Generator (distributed, monotonic)
  def distributed_generator_new(_node_id), do: :erlang.nif_error(:nif_not_loaded)
  def distributed_generator_generate(_ref), do: :erlang.nif_error(:nif_not_loaded)
  def distributed_generator_generate_binary(_ref), do: :erlang.nif_error(:nif_not_loaded)
end

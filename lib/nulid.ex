defmodule Nulid do
  @moduledoc """
  Nanosecond-Precision Universally Lexicographically Sortable Identifier (NULID).

  A 128-bit identifier with:
  - 68 bits for nanoseconds since Unix epoch (~9,356 years lifespan)
  - 60 bits for cryptographically secure randomness

  NULIDs are represented internally as 16-byte binaries (big-endian `u128`).
  String representation uses 26-character Crockford Base32 encoding.

  ## Quick Start

      # Generate a new NULID as a string
      {:ok, nulid} = Nulid.generate()

      # Generate as raw binary
      {:ok, binary} = Nulid.generate_binary()

      # Parse a string back to binary
      {:ok, nulid} = Nulid.generate()
      {:ok, binary} = Nulid.decode(nulid)
      {:ok, ^nulid} = Nulid.encode(binary)

  ## Monotonic Generator

  For guaranteed monotonically increasing IDs (even within the same nanosecond):

      gen = Nulid.Generator.new()
      {:ok, id1} = Nulid.Generator.generate(gen)
      {:ok, id2} = Nulid.Generator.generate(gen)
      id1 < id2  # always true
  """

  @type t :: <<_::128>>

  @doc """
  Generates a new NULID and returns it as a 26-character Crockford Base32 string.

  ## Examples

      iex> {:ok, nulid} = Nulid.generate()
      iex> String.length(nulid)
      26
  """
  @spec generate() :: {:ok, String.t()} | {:error, String.t()}
  def generate do
    {:ok, Nulid.Native.new()}
  rescue
    e -> {:error, Exception.message(e)}
  end

  @doc """
  Generates a new NULID and returns it as a 16-byte binary.

  ## Examples

      iex> {:ok, binary} = Nulid.generate_binary()
      iex> byte_size(binary)
      16
  """
  @spec generate_binary() :: {:ok, t()} | {:error, String.t()}
  def generate_binary do
    {:ok, Nulid.Native.new_binary()}
  rescue
    e -> {:error, Exception.message(e)}
  end

  @doc """
  Encodes a 16-byte NULID binary to a 26-character Crockford Base32 string.

  ## Examples

      iex> {:ok, binary} = Nulid.generate_binary()
      iex> {:ok, string} = Nulid.encode(binary)
      iex> String.length(string)
      26
  """
  @spec encode(t()) :: {:ok, String.t()} | {:error, String.t()}
  def encode(<<_::128>> = binary) do
    {:ok, Nulid.Native.encode(binary)}
  rescue
    e -> {:error, Exception.message(e)}
  end

  @doc """
  Decodes a 26-character Crockford Base32 string to a 16-byte NULID binary.

  ## Examples

      iex> {:ok, nulid} = Nulid.generate()
      iex> {:ok, binary} = Nulid.decode(nulid)
      iex> byte_size(binary)
      16
  """
  @spec decode(String.t()) :: {:ok, t()} | {:error, String.t()}
  def decode(string) when is_binary(string) do
    {:ok, Nulid.Native.decode(string)}
  rescue
    e -> {:error, Exception.message(e)}
  end

  @doc """
  Extracts the timestamp in nanoseconds since Unix epoch from a NULID binary.

  ## Examples

      iex> {:ok, binary} = Nulid.generate_binary()
      iex> {:ok, ns} = Nulid.nanos(binary)
      iex> is_integer(ns)
      true
  """
  @spec nanos(t()) :: {:ok, non_neg_integer()} | {:error, String.t()}
  def nanos(<<_::128>> = binary) do
    {:ok, Nulid.Native.nanos(binary)}
  rescue
    e -> {:error, Exception.message(e)}
  end

  @doc """
  Extracts the timestamp in milliseconds since Unix epoch from a NULID binary.

  ## Examples

      iex> {:ok, binary} = Nulid.generate_binary()
      iex> {:ok, ms} = Nulid.millis(binary)
      iex> is_integer(ms)
      true
  """
  @spec millis(t()) :: {:ok, non_neg_integer()} | {:error, String.t()}
  def millis(<<_::128>> = binary) do
    {:ok, Nulid.Native.millis(binary)}
  rescue
    e -> {:error, Exception.message(e)}
  end

  @doc """
  Extracts the 60-bit random component from a NULID binary.

  ## Examples

      iex> {:ok, binary} = Nulid.generate_binary()
      iex> {:ok, rand} = Nulid.random(binary)
      iex> is_integer(rand)
      true
  """
  @spec random(t()) :: {:ok, non_neg_integer()} | {:error, String.t()}
  def random(<<_::128>> = binary) do
    {:ok, Nulid.Native.random(binary)}
  rescue
    e -> {:error, Exception.message(e)}
  end

  @doc """
  Returns `true` if the NULID binary is nil (all zeros).

  ## Examples

      iex> Nulid.nil?(<<0::128>>)
      {:ok, true}
  """
  @spec nil?(t()) :: {:ok, boolean()} | {:error, String.t()}
  def nil?(<<_::128>> = binary) do
    {:ok, Nulid.Native.is_nil(binary)}
  rescue
    e -> {:error, Exception.message(e)}
  end
end

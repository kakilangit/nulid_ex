defmodule Nulid.EctoTest do
  use ExUnit.Case

  describe "type/0" do
    test "returns :binary" do
      assert Nulid.Ecto.type() == :binary
    end
  end

  describe "cast/1" do
    test "casts a valid NULID string" do
      {:ok, nulid} = Nulid.generate()
      assert {:ok, ^nulid} = Nulid.Ecto.cast(nulid)
    end

    test "casts a 16-byte binary to string" do
      {:ok, binary} = Nulid.generate_binary()
      {:ok, string} = Nulid.encode(binary)
      assert {:ok, ^string} = Nulid.Ecto.cast(binary)
    end

    test "rejects invalid strings" do
      assert :error = Nulid.Ecto.cast("not-a-nulid")
    end

    test "rejects wrong-length strings" do
      assert :error = Nulid.Ecto.cast("too-short")
      assert :error = Nulid.Ecto.cast(String.duplicate("A", 27))
    end

    test "rejects non-binary values" do
      assert :error = Nulid.Ecto.cast(123)
      assert :error = Nulid.Ecto.cast(nil)
      assert :error = Nulid.Ecto.cast(:atom)
    end

    test "casts nil NULID binary" do
      {:ok, string} = Nulid.Ecto.cast(<<0::128>>)
      assert String.length(string) == 26
    end
  end

  describe "dump/1" do
    test "dumps a valid NULID string to binary" do
      {:ok, nulid} = Nulid.generate()
      {:ok, binary} = Nulid.Ecto.dump(nulid)
      assert byte_size(binary) == 16
    end

    test "dumps a raw binary as-is" do
      {:ok, binary} = Nulid.generate_binary()
      assert {:ok, ^binary} = Nulid.Ecto.dump(binary)
    end

    test "round-trips through dump and load" do
      {:ok, nulid} = Nulid.generate()
      {:ok, binary} = Nulid.Ecto.dump(nulid)
      {:ok, loaded} = Nulid.Ecto.load(binary)
      assert nulid == loaded
    end

    test "rejects invalid values" do
      assert :error = Nulid.Ecto.dump(123)
      assert :error = Nulid.Ecto.dump(nil)
    end
  end

  describe "load/1" do
    test "loads a 16-byte binary to string" do
      {:ok, binary} = Nulid.generate_binary()
      {:ok, string} = Nulid.Ecto.load(binary)
      assert is_binary(string)
      assert String.length(string) == 26
    end

    test "rejects non-16-byte values" do
      assert :error = Nulid.Ecto.load("not-binary")
      assert :error = Nulid.Ecto.load(nil)
    end
  end

  describe "autogenerate/0" do
    test "returns a valid NULID string" do
      nulid = Nulid.Ecto.autogenerate()
      assert is_binary(nulid)
      assert String.length(nulid) == 26
    end

    test "generates unique values" do
      id1 = Nulid.Ecto.autogenerate()
      id2 = Nulid.Ecto.autogenerate()
      assert id1 != id2
    end

    test "generated value can be dumped" do
      nulid = Nulid.Ecto.autogenerate()
      assert {:ok, binary} = Nulid.Ecto.dump(nulid)
      assert byte_size(binary) == 16
    end
  end

  describe "Ecto.Type compliance" do
    test "implements Ecto.Type behaviour" do
      behaviours =
        Nulid.Ecto.__info__(:attributes)
        |> Keyword.get_values(:behaviour)
        |> List.flatten()

      assert Ecto.Type in behaviours
    end
  end
end

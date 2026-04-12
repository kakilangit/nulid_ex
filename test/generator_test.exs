defmodule Nulid.GeneratorTest do
  use ExUnit.Case

  describe "new/0" do
    test "creates a default generator" do
      gen = Nulid.Generator.new()
      assert %Nulid.Generator{type: :default} = gen
    end
  end

  describe "new/1 with node_id" do
    test "creates a distributed generator" do
      gen = Nulid.Generator.new(node_id: 42)
      assert %Nulid.Generator{type: :distributed} = gen
    end
  end

  describe "generate/1" do
    test "returns a 26-character string" do
      gen = Nulid.Generator.new()
      assert {:ok, id} = Nulid.Generator.generate(gen)
      assert String.length(id) == 26
    end

    test "generates monotonically increasing IDs" do
      gen = Nulid.Generator.new()
      {:ok, id1} = Nulid.Generator.generate(gen)
      {:ok, id2} = Nulid.Generator.generate(gen)
      {:ok, id3} = Nulid.Generator.generate(gen)

      assert id1 < id2
      assert id2 < id3
    end

    test "works with distributed generator" do
      gen = Nulid.Generator.new(node_id: 1)
      {:ok, id1} = Nulid.Generator.generate(gen)
      {:ok, id2} = Nulid.Generator.generate(gen)

      assert id1 < id2
    end
  end

  describe "generate_binary/1" do
    test "returns 16-byte binary" do
      gen = Nulid.Generator.new()
      assert {:ok, binary} = Nulid.Generator.generate_binary(gen)
      assert byte_size(binary) == 16
    end

    test "generates monotonically increasing binaries" do
      gen = Nulid.Generator.new()
      {:ok, b1} = Nulid.Generator.generate_binary(gen)
      {:ok, b2} = Nulid.Generator.generate_binary(gen)
      {:ok, b3} = Nulid.Generator.generate_binary(gen)

      assert b1 < b2
      assert b2 < b3
    end

    test "works with distributed generator" do
      gen = Nulid.Generator.new(node_id: 100)
      assert {:ok, binary} = Nulid.Generator.generate_binary(gen)
      assert byte_size(binary) == 16
    end
  end

  describe "different node IDs produce different IDs" do
    test "same timestamp different nodes" do
      gen1 = Nulid.Generator.new(node_id: 1)
      gen2 = Nulid.Generator.new(node_id: 2)

      {:ok, id1} = Nulid.Generator.generate(gen1)
      {:ok, id2} = Nulid.Generator.generate(gen2)

      assert id1 != id2
    end
  end
end

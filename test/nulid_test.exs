defmodule NulidTest do
  use ExUnit.Case

  describe "generate/0" do
    test "returns a 26-character string" do
      assert {:ok, nulid} = Nulid.generate()
      assert is_binary(nulid)
      assert String.length(nulid) == 26
    end

    test "generates unique values" do
      {:ok, id1} = Nulid.generate()
      {:ok, id2} = Nulid.generate()
      assert id1 != id2
    end
  end

  describe "generate_binary/0" do
    test "returns a 16-byte binary" do
      assert {:ok, binary} = Nulid.generate_binary()
      assert is_binary(binary)
      assert byte_size(binary) == 16
    end

    test "generates unique values" do
      {:ok, b1} = Nulid.generate_binary()
      {:ok, b2} = Nulid.generate_binary()
      assert b1 != b2
    end
  end

  describe "encode/1 and decode/1" do
    test "round-trips correctly" do
      {:ok, binary} = Nulid.generate_binary()
      {:ok, string} = Nulid.encode(binary)
      {:ok, decoded} = Nulid.decode(string)
      assert binary == decoded
    end

    test "string from generate matches encode of binary" do
      {:ok, binary} = Nulid.generate_binary()
      {:ok, string} = Nulid.encode(binary)
      assert String.length(string) == 26
    end
  end

  describe "nanos/1" do
    test "returns positive integer for non-nil" do
      {:ok, binary} = Nulid.generate_binary()
      {:ok, ns} = Nulid.nanos(binary)
      assert is_integer(ns)
      assert ns > 0
    end

    test "returns 0 for nil NULID" do
      {:ok, ns} = Nulid.nanos(<<0::128>>)
      assert ns == 0
    end
  end

  describe "millis/1" do
    test "returns positive integer for non-nil" do
      {:ok, binary} = Nulid.generate_binary()
      {:ok, ms} = Nulid.millis(binary)
      assert is_integer(ms)
      assert ms > 0
    end
  end

  describe "random/1" do
    test "returns integer" do
      {:ok, binary} = Nulid.generate_binary()
      {:ok, rand} = Nulid.random(binary)
      assert is_integer(rand)
    end
  end

  describe "nil?/1" do
    test "returns true for nil NULID" do
      {:ok, result} = Nulid.nil?(<<0::128>>)
      assert result == true
    end

    test "returns false for non-nil NULID" do
      {:ok, binary} = Nulid.generate_binary()
      {:ok, result} = Nulid.nil?(binary)
      assert result == false
    end
  end
end

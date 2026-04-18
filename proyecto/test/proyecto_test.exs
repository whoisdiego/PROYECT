defmodule FiniteAutomatonTest do
  use ExUnit.Case

  # Helpers
  defp nfa, do: FiniteAutomaton.nfa_example()
  defp dfa, do: FiniteAutomaton.determinize(nfa())

  # --- determinize: estructura general ---

  test "el DFA tiene 4 estados" do
    {q, _, _, _, _} = dfa()
    assert length(q) == 4
  end

  test "el estado inicial es {0}" do
    {_, _, _, q0, _} = dfa()
    assert q0 == MapSet.new([0])
  end

  test "hay exactamente un estado final" do
    {_, _, _, _, f} = dfa()
    assert length(f) == 1
  end

  test "el estado final contiene al estado 3 del NFA" do
    {_, _, _, _, f} = dfa()
    assert MapSet.member?(hd(f), 3)
  end

  # --- transiciones ---

  test "δ({0}, :a) = {0,1}" do
    {_, _, delta, q0, _} = dfa()
    assert Map.get(delta, {q0, :a}) == MapSet.new([0, 1])
  end

  test "δ({0}, :b) = {0}" do
    {_, _, delta, q0, _} = dfa()
    assert Map.get(delta, {q0, :b}) == MapSet.new([0])
  end

  test "δ({0,1}, :b) = {0,2}" do
    {_, _, delta, _, _} = dfa()
    state = MapSet.new([0, 1])
    assert Map.get(delta, {state, :b}) == MapSet.new([0, 2])
  end

  test "δ({0,2}, :b) = {0,3}" do
    {_, _, delta, _, _} = dfa()
    state = MapSet.new([0, 2])
    assert Map.get(delta, {state, :b}) == MapSet.new([0, 3])
  end

  # --- propiedades del DFA ---

  test "no hay transiciones vacías" do
    {_, _, delta, _, _} = dfa()

    assert Enum.all?(delta, fn {_, target} ->
      MapSet.size(target) > 0
    end)
  end

  test "todas las transiciones son MapSet" do
    {_, _, delta, _, _} = dfa()

    assert Enum.all?(delta, fn {_, target} ->
      is_struct(target, MapSet)
    end)
  end
end

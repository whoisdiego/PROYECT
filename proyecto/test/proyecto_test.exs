defmodule FiniteAutomatonTest do
  use ExUnit.Case

  # ---------------------------
  # Helpers
  # ---------------------------

  defp nfa, do: FiniteAutomaton.nfa_example()
  defp dfa, do: FiniteAutomaton.determinize(nfa())

  defp nfa_eps do
    {
      [0, 1, 2, 3, 4],
      [:a],
      %{
        {0, :eps} => [1, 2],
        {1, :eps} => [3],
        {3, :eps} => [4],
        {2, :a}   => [4]
      },
      0,
      [4]
    }
  end

  defp dfa_eps, do: FiniteAutomaton.e_determinize(nfa_eps())

  # ---------------------------
  # NFA sin epsilon
  # ---------------------------

  test "DFA tiene 4 estados" do
    {q, _, _, _, _} = dfa()
    assert length(q) == 4
  end

  test "estado inicial es {0}" do
    {_, _, _, q0, _} = dfa()
    assert q0 == MapSet.new([0])
  end

  test "estado final contiene 3" do
    {_, _, _, _, f} = dfa()
    assert length(f) == 1
    assert MapSet.member?(hd(f), 3)
  end

  test "δ({0}, :a) = {0,1}" do
    {_, _, delta, q0, _} = dfa()
    assert Map.get(delta, {q0, :a}) == MapSet.new([0, 1])
  end

  test "δ({0,1}, :b) = {0,2}" do
    {_, _, delta, _, _} = dfa()
    state = MapSet.new([0, 1])
    assert Map.get(delta, {state, :b}) == MapSet.new([0, 2])
  end

  # ---------------------------
  # ε-closure
  # ---------------------------

  test "e_closure desde 0 incluye todos por eps" do
    closure = FiniteAutomaton.e_closure(nfa_eps(), [0])

    assert closure == MapSet.new([0, 1, 2, 3, 4])
  end

  test "e_closure desde 2 solo es 2" do
    closure = FiniteAutomaton.e_closure(nfa_eps(), [2])

    assert closure == MapSet.new([2])
  end

  # ---------------------------
  # NFA con epsilon
  # ---------------------------

  test "DFA con epsilon tiene al menos un estado" do
    {q, _, _, _, _} = dfa_eps()
    assert length(q) > 0
  end

  test "estado inicial incluye cierre epsilon" do
    {_, _, _, q0, _} = dfa_eps()

    assert q0 == MapSet.new([0, 1, 2, 3, 4])
  end

  test "hay al menos un estado final" do
    {_, _, _, _, f} = dfa_eps()

    assert length(f) >= 1
  end

  test "transición con :a desde estado inicial funciona" do
    {_, _, delta, q0, _} = dfa_eps()

    next = Map.get(delta, {q0, :a})

    # desde {0,1,2,3,4} con :a → solo 2 tiene transición a 4
    # luego cierre epsilon de 4 = {4}
    assert next == MapSet.new([4])
  end

  # ---------------------------
  # Propiedades generales
  # ---------------------------

  test "todas las transiciones son MapSet" do
    {_, _, delta, _, _} = dfa()

    assert Enum.all?(delta, fn {_, target} ->
      is_struct(target, MapSet)
    end)
  end

  test "no hay transiciones vacías en DFA normal" do
    {_, _, delta, _, _} = dfa()

    assert Enum.all?(delta, fn {_, target} ->
      MapSet.size(target) > 0
    end)
  end
end

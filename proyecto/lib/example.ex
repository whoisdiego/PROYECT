defmodule FiniteAutomaton do
  def nfa_example() do
    q      = [0, 1, 2, 3]
    sigma  = [:a, :b]
    delta  = %{
      {0, :a} => [0, 1],
      {0, :b} => [0],
      {1, :b} => [2],
      {2, :b} => [3]
    }
    q0     = 0
    f      = [3]

    {q, sigma, delta, q0, f}
  end

  def determinize({_q, sigma, delta, q0, f}) do
    start_set = MapSet.new([q0])

    {dfa_states, dfa_delta} = explore([start_set], sigma, delta, MapSet.new([start_set]), %{})

    f_set = MapSet.new(f)
    dfa_f =
      dfa_states
      |> Enum.filter(fn state_set -> not MapSet.disjoint?(state_set, f_set) end)

    dfa_q  = dfa_states
    dfa_q0 = start_set

    {dfa_q, sigma, dfa_delta, dfa_q0, dfa_f}
  end

  def explore([], _sigma, _delta, _visited, acc_delta), do: {MapSet.to_list(_visited), acc_delta}

  def explore([current_set | rest], sigma, delta, visited, acc_delta) do
    {new_sets, new_delta} =
      Enum.reduce(sigma, {[], acc_delta}, fn symbol, {new_acc, delta_acc} ->
        target_set =
          current_set
          |> MapSet.to_list()
          |> Enum.flat_map(fn q -> Map.get(delta, {q, symbol}, []) end)
          |> MapSet.new()

        updated_delta = Map.put(delta_acc, {current_set, symbol}, target_set)

        if MapSet.member?(visited, target_set) or MapSet.size(target_set) == 0 do
          {new_acc, updated_delta}
        else
          {[target_set | new_acc], updated_delta}
        end
      end)

    new_visited = Enum.reduce(new_sets, visited, &MapSet.put(&2, &1))
    explore(rest ++ new_sets, sigma, delta, new_visited, new_delta)
  end


end

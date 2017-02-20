defmodule ANNEx.Signal do
  alias ANNEx.{Random, Signal}

  defstruct [:value, :weight]

  @io %{random: Random}

  @doc """
  Builds signals.
  """
  def build(input, io \\ @io)
  def build([_|_]=values, io) do
    Enum.map(values, &(Signal.build(&1, io)))
  end
  def build(value, io) do
    %Signal{value: value, weight: io.random.weight}
  end

  @doc """
  Updates signals.
  """
  def update([_|_]=signals, [_|_]=changes) do
    signals
    |> Enum.zip(changes)
    |> Enum.map(fn {signal, change} -> Signal.update(signal, change) end)
  end
  def update(%Signal{}=signal, %{}=changes) do
    Map.merge(signal, changes)
  end

  @doc """
  Sums signal values and bias.
  """
  def sum(signals, bias) do
    sum = signals |> Enum.reduce(0, &(&2 + (&1.value * &1.weight)))
    sum + bias
  end

  @doc """
  Returns weights of given signals.
  """
  def get_weights(signals), do: Enum.map(signals, &(Map.get(&1, :weight)))
end

defmodule ANNEx.Training do
  alias ANNEx.{Network, Training.Config, Training.Log}

  @doc """
  Trains network - returns new network state.
  """
  def train(%Network{}=network, %Config{}=config, training_datasets, log_opts \\ []) do
    %{method: method, epochs: epochs, params: params} = config
    {network, _} = Enum.reduce(1..epochs, {network, 1}, fn (_, {network, epoch}) ->
      {network, errors} = epoch(network, method, params, training_datasets, log_opts)
      Log.epoch(log_opts, epoch, errors)
      {network, epoch+1}
    end)
    network
  end

  defp epoch(network, method, params, [_|_]=training_datasets, log_opts) do
    Enum.reduce(training_datasets, {network, []}, fn (dataset, {network, errors}) ->
      {network, error} = iteration(network, method, params, dataset, log_opts)
      {network, [error|errors]}
    end)
  end
  defp epoch(network, method, params, training_dataset, log_opts) do
    {network, error} = iteration(network, method, params, training_dataset, log_opts)
    {network, [error]}
  end

  defp iteration(network, method, params, {input, exp_output}, log_opts) do
    {network, output} = Network.process(network, input)
    network = method.process(network, output, exp_output, params)
    {_, output_after_training} = Network.process(network, input)
    total_error = calculate_total_error(output_after_training, exp_output)
    Log.iteration(log_opts, input, output_after_training, exp_output, total_error)
    {network, total_error}
  end

  defp calculate_total_error(output, exp_output) do
    output
    |> Enum.zip(exp_output)
    |> Enum.map(fn {output, exp_output} ->
       0.5*:math.pow(exp_output - output, 2)
    end)
    |> Enum.reduce(0, &(&2 + &1))
  end
end
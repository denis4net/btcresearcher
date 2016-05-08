defmodule Btcresearcher.Dist do
  import Btcresearcher.Helpers
  require Logger

  @timeout 300000
  @jobs_count 8

  def compute_volution_job(tx_ids) do
    {:ok, pid} = Gold.start_link(Btcresearcher.Bitcoind.get_config())
    Btcresearcher.Helpers.compute_volution!(pid, tx_ids)
  end

  def distributed_compute_volution!(tx_ids, jobs_count \\ @jobs_count) do
    bunch = round(length(tx_ids) / jobs_count)
    tasks = Enum.map(0..jobs_count-1, fn i ->
       Task.Supervisor.async({Btcresearcher.App, Enum.random(Application.get_env(:btcresearcher, :compute_nodes))},
                              Btcresearcher.Dist, :compute_volution_job, [Enum.slice(tx_ids, bunch * i, bunch)]) # fun should be tupple
     end)
    Enum.sum((Enum.map(0..length(tasks), fn i -> Task.await(Enum.at(tasks, i), @timeout) end)))
  end
end

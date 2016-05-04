defmodule Btcresearcher.Task do
  import Btcresearcher.Helpers
  require Logger

  @timeout 300000
  @jobs_count 8

  def async_map(fun, count) do
    {:ok, spid} = Task.Supervisor.start_link([restart: :transient])

    tasks = Enum.map(0..count-1, fn i ->
       Task.Supervisor.async spid, fn ->
         fun.(i)
       end

       # # In the client
       # Task.Supervisor.async({Btcresearcher.App, Application.get_env(:btcresearcher, :compute_nodes)}, Btcresearcher, :function, [])
     end)

    List.flatten(Enum.map(0..count-1, fn i -> Task.await(Enum.at(tasks, i), @timeout) end))
  end

  def get_transactions!(index, count, jobs_count \\ @jobs_count) do
    bunch = round(count / jobs_count)
    {:ok, pid} = Gold.start_link(Btcresearcher.Bitcoind.get_config())
    first = if index > 0, do: index, else: Gold.getblockcount!(pid) + index

    job = fn i ->
      first_local = first + bunch * i
      {:ok, pid} = Gold.start_link(Btcresearcher.Bitcoind.get_config())
      Btcresearcher.Helpers.get_block_transactions!(pid, first_local, bunch)
    end

    async_map(job, jobs_count)
  end

  def compute_volution!(tx_ids, jobs_count \\ @jobs_count) do
    bunch = round(length(tx_ids) / jobs_count)
    job = fn i ->
      {:ok, pid} = Gold.start_link(Btcresearcher.Bitcoind.get_config())
      Btcresearcher.Helpers.compute_volution!(pid, Enum.slice(tx_ids, bunch * i, bunch))
    end
    Enum.sum async_map(job, jobs_count)
  end

  # def async_distributed_map(fun, count) do
  #   tasks = Enum.map(0..count-1, fn i ->
  #      Task.Supervisor.async({Btcresearcher.App, Enum.random(Application.get_env(:btcresearcher, :compute_nodes))},
  #                             Btcresearcher, fun, [i]) # fun should be tupple
  #    end)
  #
  #   List.flatten(Enum.map(0..count-1, fn i -> Task.await(Enum.at(tasks, i), @timeout) end))
  # end
  #
  # def compute_volution_job(i) do
  #   {:ok, pid} = Gold.start_link(Btcresearcher.Bitcoind.get_config())
  #   Btcresearcher.Helpers.compute_volution!(pid, Enum.slice(tx_ids, bunch * i, bunch))
  # end
  #
  # def distributed_compute_volution!(tx_ids, jobs_count \\ @jobs_count) do
  #   bunch = round(length(tx_ids) / jobs_count)
  #   Enum.sum async_distributed_map(compute_volution_job, jobs_count)
  # end
end

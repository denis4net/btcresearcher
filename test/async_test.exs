defmodule Btcresearcher.TaskTest do
  use ExUnit.Case

  require Gold
  require Btcresearcher.Bitcoind
  require Btcresearcher.Helpers
  require Btcresearcher.App
  require Logger

  @tag timeout: 240000
  test "destributed_volution" do
    jobs_count = 8
    blocks = 32

    tx_ids = Btcresearcher.Task.get_transactions!(- blocks, blocks, jobs_count)
    Logger.info("Fetched #{length(tx_ids)} transaction ids")
    volution = Btcresearcher.Task.compute_volution!(tx_ids, jobs_count)
    Logger.info("Last #{blocks} have moved #{volution} BTC")
  end
end

defmodule BtcresearcherTest do
  use ExUnit.Case
  require Gold
  require Btcresearcher.Bitcoind
  require Btcresearcher.Helpers
  require Btcresearcher.App
  require Logger

  test "one transaction volution" do
    tx = "d93d2317ab0a1714e785ca22fe6f906fbafa3242bba251d8bc3a4a057475bec4"
    {:ok, pid} = Btcresearcher.Bitcoind.start_link()
    volution = Btcresearcher.Helpers.compute_volution!(pid, [tx])
    Logger.info("Tx #{tx} volution is #{volution}")
  end

  test "destributed volution" do
    jobs_count = 4
    blocks = 64

    tx_ids = Btcresearcher.Task.get_transactions!(- blocks, blocks, jobs_count)
    Logger.info("Fetched #{length(tx_ids)} transaction ids")
    volution = Btcresearcher.Task.compute_volution!(tx_ids, jobs_count)
    Logger.info("Last #{blocks} have moved #{volution} BTC")
  end

end

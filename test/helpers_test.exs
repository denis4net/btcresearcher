defmodule Btcresearcher.HelpersTest do
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

  test "get_blocks" do
    {:ok, pid} = Btcresearcher.Bitcoind.start_link()
    blocks = Btcresearcher.Helpers.get_blocks!(pid, Gold.getblockhash!(pid, 4096), 1024)
    Logger.info("Fetched #{length(blocks)} blocks")
  end
end

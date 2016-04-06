defmodule BtcresearcherTest do
  use ExUnit.Case
  require Gold
  doctest Btcresearcher

  test "getinfo" do
      pid = Btcresearcher.start_link!()
      block_hash = Gold.getblockhash!(pid, 0)
      block = Gold.getblock!(pid, block_hash)

      IO.puts "Block #{block_hash}"
  end
end

  defmodule BtcresearcherTest do
  use ExUnit.Case
  require Gold
  doctest Btcresearcher

  test "getblockhash" do
      pid = Btcresearcher.start_link!()
      block_hash = Gold.getblockhash!(pid, 0)
      IO.puts "Block #{block_hash}"
  end

  test "gettransactions" do
    pid = Btcresearcher.start_link!
    transactions = Btcresearcher.get_transactions! pid, 1..5
  end

end

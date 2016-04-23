  defmodule BtcresearcherTest do
  use ExUnit.Case
  require Gold
  require Logger
  doctest Btcresearcher

  test "getblockhash" do
      pid = Btcresearcher.start_link!()
      block_hash = Gold.getblockhash!(pid, 0)
      IO.puts "Block #{block_hash}"
  end

  test "gettransactions" do
    pid = Btcresearcher.start_link!
    count = Gold.getblockcount!(pid)
    length = 128

    transactions = Btcresearcher.get_block_transactions! pid, count - length, length
    IO.puts("Transactions length: #{length(transactions)}")
  end
end

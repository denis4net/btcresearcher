defmodule Btcresearcher do
  require Gold
  require Gold.Config

  def init do
    {:ok, pid} = Gold.start_link(%Gold.Config{hostname: "localhost", port: 8332, user: "bitcoinrpc", password: "changeme"})
    Gold.getbalance(pid)
  end
end

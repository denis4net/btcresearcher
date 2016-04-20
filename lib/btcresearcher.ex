defmodule Btcresearcher do
  require Gold
  require Gold.Config

  def start_link do
    node_config = Enum.at(Application.get_env(:btcresearcher, :bitcoind_nodes), 0)
    config = %Gold.Config{hostname: node_config[:hostname], port: node_config[:port], user: node_config[:user], password: node_config[:password]}
    Gold.start_link(config)
  end

  def start_link! do
    {:ok, pid} = start_link()
    pid
  end

  def get_transactions!(pid, index) when is_integer(index) do
    hash = Gold.getblockhash! pid, index
    blk = Gold.getblock! pid, hash
    blk[:transactions]
  end

  def get_transactions!(pid, range) do
    Enum.map range, fn index ->
      get_transactions! pid, index
    end
  end
end

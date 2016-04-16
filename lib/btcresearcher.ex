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
end

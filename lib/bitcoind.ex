defmodule Btcresearcher.Bitcoind do
  import Supervisor.Spec
  require Gold
  require Gold.Config

  def get_config() do
    node_config = Enum.random(Application.get_env(:btcresearcher, :bitcoind_nodes))
    %Gold.Config{hostname: node_config[:hostname], port: node_config[:port], user: node_config[:user], password: node_config[:password]}
  end

  def start_link() do
    Gold.start_link(get_config())
  end
end

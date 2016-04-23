defmodule Btcresearcher do
  require Gold
  require Gold.Config
  require Logger
  @retries_count 10

  def start_link do
    node_config = Enum.random(Application.get_env(:btcresearcher, :bitcoind_nodes))
    config = %Gold.Config{hostname: node_config[:hostname], port: node_config[:port], user: node_config[:user], password: node_config[:password]}
    Gold.start_link(config)
  end

  def start_link! do
    {:ok, pid} = start_link()
    pid
  end

  @doc """
    Get all transaction in a block, the block will be found by the height/index
  """
  def get_transactions!(pid, index, retries_count) when is_integer(index) do
    try do
      hash = Gold.getblockhash! pid, index
      blk = Gold.getblock! pid, hash
      blk["transactions"]
    rescue
      e in MatchError -> if retries_count > 0, do: get_transactions!(pid, index, retries_count - 1), else: raise e
    end
  end

  @doc """
    Get all block transactions in a block, the block will be found by the hash
  """
  def get_transactions!(pid, hash, retries_count \\ @retries_count) when is_binary(hash) do
    try do
      blk = Gold.getblock! pid, hash
      blk["transactions"]
    rescue
      e in MatchError -> if retries_count > 0, do: get_transactions!(pid, hash, retries_count - 1), else: raise e
    end
  end

  def get_block_transactions!(pid, hash, count, retries_count) when is_binary(hash) do
    try do
      blk = Gold.getblock!(pid, hash)

      if count > 1 do
        blk["tx"] ++  get_block_transactions!(pid, blk["nextblockhash"], count-1, retries_count)
      else
        blk["tx"]
      end
    rescue
      _ in MatchError -> if retries_count > 0, do: get_block_transactions!(pid, hash, retries_count - 1, count), else: raise "RPC request failed"
    end
  end

  def get_block_transactions!(pid, first_block_index, count, retries_count \\ @retries_count)  when is_integer(first_block_index) and is_integer(count) do
    hash = Gold.getblockhash!(pid, first_block_index)
    get_block_transactions!(pid, hash, count, retries_count)
  end

end

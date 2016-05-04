defmodule Btcresearcher.Helpers do
  require Gold
  require Gold.Config
  require Logger

  @retries_count 10

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

  def get_block_transactions!(pid, hash, count, retries_count) when is_binary(hash)  do
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

  def get_block_transactions!(pid, first_block_index, count, retries_count \\ @retries_count)
  when is_integer(first_block_index) and is_integer(count)
  do
      hash = Gold.getblockhash!(pid, first_block_index)
      get_block_transactions!(pid, hash, count, retries_count)
  end

  def get_blocks!(pid, hash, count) do
    # IO.puts :stderr, "requesting block #{hash} #{count}"
    blk = Gold.getblock!(pid, hash)
    if count > 1 do
      [blk] ++ get_blocks!(pid, blk["nextblockhash"], count - 1)
    else
      [blk]
    end
  end

  @doc "compute transactions volution"
  def compute_volution!(pid, tx_ids) do
    tx_volutions = Enum.map tx_ids, fn tx_id ->
      tx = Gold.getrawtransaction!(pid, tx_id)
      tx_volution = Enum.reduce tx["vout"], 0, fn (vout, acc) ->
        vout["value"] + acc
      end

      tx_volution
    end
    # sum volutions of all transactions
    Enum.sum tx_volutions
  end
end

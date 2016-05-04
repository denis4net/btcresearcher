defmodule Btcresearcher.App do
  use Application
  use Supervisor

  require OptionParser
  require Btcresearcher.Helpers
  require Btcresearcher.Bitcoind
  require Logger

  def get_block_stat(hash, count) do
    {:ok, pid} = Btcresearcher.Bitcoind.start_link()
    blocks = Btcresearcher.Helpers.get_blocks!(pid, hash, count)

    IO.puts("Time, TXCount")
    Enum.each blocks, fn block ->
      IO.puts("#{block["time"]}, #{length(block["tx"])}")
    end
  end

  def start(_type, _args) do
    Logger.info("Starting supervisor")
    Task.Supervisor.start_link(name: __MODULE__)
  end

  def show_help() do
    IO.puts :stderr, "[--help][--action block_stat --hash <hash> --count <int>]"
  end

  def main(args) do
    {options, _, _} = OptionParser.parse(args)

    case options do
      [action: "block_stat", count: count_str, hash: hash] ->
        get_block_stat(hash, elem(Integer.parse(count_str, 10), 0))
      [help: true] -> show_help()
      _ -> show_help()
    end

  end

end

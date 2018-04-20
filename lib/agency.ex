defmodule Agency do

  use GenServer

  @ets_table :chat
  @process_lifetime_ms 1_000
  @endpoint Application.get_env(:agency, :endpoint)
  @key Application.get_env(:agency, :key)
  @method "getUpdates"


  def start_link(), do: GenServer.start_link(__MODULE__, 0, name: __MODULE__)

  def init(args) do

      # Application.ensure_all_started(:inets)
      # Application.ensure_all_started(:ssl)

      :ets.new(@ets_table, [:set, :public, :named_table, {:read_concurrency, true}])

      Process.send_after(self(), :read_chat, @process_lifetime_ms)
      {:ok, args}
  end

  def handle_info(:read_chat, state) do

    url = "#{@endpoint}/#{@key}/#{@method}?offset=#{state}"

    IO.puts "go for ulr #{url}"

    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(url)

    with {:ok, %{"ok" => true, "result" => result}} <- body
                                                        |> Jason.decode,
        state <- parse_result(state, result)
    do
      Process.send_after(self(), :read_chat, @process_lifetime_ms)
      {:noreply, state}
    end
  end

  def parse_result(state, result) do
    result
      |> Enum.reduce(state, fn(message, _) ->
        Agency.Telega.start_process(message["message"])
        message["update_id"] + 1
      end)
  end

end

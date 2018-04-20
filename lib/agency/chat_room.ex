defmodule Agency.ChatRoom do

  require Logger
  use GenServer

  @process_lifetime_ms 5_000
  @account_registry_name :chat_room

  def start_link(storage_name) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(storage_name))
  end

  def init([]) do
    Process.send_after(self(), :answer_message, @process_lifetime_ms)
    {:ok, []}
  end

  defp via_tuple(storage_name), do: {:via, Registry, {@account_registry_name, storage_name}}

  # def handle_call(:pop, _from, [h | t]) do
  #   {:reply, h, t}
  # end

  # def handle_call(:pop, _from, state), do: {:reply, nil, state}

  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:push, message}, state) do
    {:noreply, state ++ [message]}
  end

  def handle_info(:answer_message, [msg | state]) do

    _say_answer(msg)
      |> Process.send_after(:answer_message, @process_lifetime_ms)

    {:noreply, state}
  end

  def handle_info(:answer_message, []) do
    Process.send_after(self(), :answer_message, @process_lifetime_ms)
    {:noreply, []}
  end


  #### api ####

  def list_session(storage_name) do
    GenServer.call(via_tuple(storage_name), :list)
  end

  # def pop_session(storage_name) do
  #   GenServer.call(via_tuple(storage_name), :pop)
  # end

  def push_message(storage_name, message) do
    GenServer.cast(via_tuple(storage_name), {:push, message})
  end

  defp _say_answer(%{}) do
  end


end
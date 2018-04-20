defmodule Agency.Telega do
  use DynamicSupervisor

  require Logger

  def start_link(), do: DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_process(message) do

    chat_room = message["chat"]["id"]
    child_spec = {Agency.ChatRoom, chat_room}

    result = case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:ok, _pid} -> {:ok, chat_room}
      {:error, {:already_started, _pid}} -> {:error, :process_already_exists}
      undefined -> {:error, undefined}
    end

    Agency.ChatRoom.push_message(chat_room, message)
  end

end
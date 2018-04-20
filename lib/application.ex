defmodule Agency.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec

  def start(_type, _args) do

    # List all child processes to be supervised
    children = [
      worker(Agency, []),
      worker(Agency.Telega, []),
      supervisor(Registry, [:unique, :chat_room], id: :chat_room),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Agency.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
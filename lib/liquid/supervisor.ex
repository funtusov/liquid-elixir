defmodule Liquid.Supervisor do
  @moduledoc """
  Supervisor for Liquid processes (currently empty)
  """
  use Supervisor

  @doc """
  Starts the liquid supervisor
  """
  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  Actual supervisor init with no child processes to supervise yet
  """
  def init(stack) do
    {:ok, stack}
  end
end

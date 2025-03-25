defmodule Market.Cache do
    use GenServer

    def start do
        GenServer.start(__MODULE__, nil, name: :cache_server)
    end

    def return_server_pid(cache_pid, name_process) do
        GenServer.call(cache_pid, {:return_server_pid, name_process})
    end

    @impl GenServer
    def init(_) do
        Market.Database.start
        {:ok, HashDict.new}
    end

    @impl GenServer
    def handle_call({:return_server_pid, name_process}, _from, cache) do
        case HashDict.fetch(cache, name_process) do
            {:ok, pid_process} ->
                {
                    :reply,
                    pid_process,
                    cache
                }
            :error ->
                {:ok, pid_process} = Market.Stock.start(name_process)
                {
                    :reply,
                    pid_process,
                    HashDict.put(cache, name_process, pid_process)
                }
        end
    end
end
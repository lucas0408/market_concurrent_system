defmodule Market.Database do
    use GenServer

    @db_folder "./persist"

    def start do
        GenServer.start(__MODULE__, nil, name: __MODULE__)
    end

    def get(key) do
        key
        |> chose_worker()
        |> Market.DatabaseWorker.get(key)
    end

    def store(key, data) do
        key
        |> chose_worker()
        |> Market.DatabaseWorker.store(key, data)
    end

    defp chose_worker(key) do
        GenServer.call(__MODULE__, {:chose_worker, key})
    end

    @impl GenServer
    def init(_) do
        File.mkdir_p(@db_folder)
        {:ok, gen_workers()}
    end

    @impl GenServer
    def handle_call({:chose_worker, key}, _from, workers) do
        index = :erlang.phash2(key, 3)
        pid_worker = Map.get(workers, index)
        {:reply, pid_worker, workers}
    end

    defp gen_workers() do
        for index <- 1..3, into: %{} do
            {:ok, pid} = Market.DatabaseWorker.start(@db_folder)
            {index - 1, pid}
        end
    end

end